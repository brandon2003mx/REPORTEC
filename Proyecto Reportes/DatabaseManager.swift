import Foundation
import SQLite3
import UserNotifications

struct Usuario: Identifiable {
    var id: Int
    var numeroControl: String
    var contrasena: String
}

struct Responsable: Identifiable {
    var id: Int
    var usuario: String
    var contrasena: String
}

struct Reporte: Identifiable, Hashable {
    var id: Int
    var tipo: String
    var ubicacion: String
    var descripcion: String
    var estatus: String
}

struct MensajeChat: Identifiable {
    var id: Int
    var reporteId: Int
    var remitente: String   // "usuario" o "bot"
    var contenido: String
    var fecha: String
    var leido: Bool
}

class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private var db: OpaquePointer?
    
    private init() {
        openDatabase()
        createTables()
    }
    
    // MARK: - Ruta de base de datos
    
    func getDatabasePath() -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory.appendingPathComponent("reportecBD.sqlite").path
    }
    
    // MARK: - Abrir base de datos
    
    func openDatabase() {
        if sqlite3_open(getDatabasePath(), &db) == SQLITE_OK {
            print("Base de datos conectada correctamente")
        } else {
            print("Error al conectar la base de datos")
        }
    }
    
    // MARK: - Crear tablas
    
    func createTables() {
        
        let tablaUsuarios = """
        CREATE TABLE IF NOT EXISTS usuarios(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            numeroControl TEXT UNIQUE,
            contrasena TEXT
        );
        """
        
        let tablaReportes = """
        CREATE TABLE IF NOT EXISTS reportes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo TEXT,
            ubicacion TEXT,
            descripcion TEXT,
            estatus TEXT
        );
        """
        
        let tablaResponsables = """
        CREATE TABLE IF NOT EXISTS responsables(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario TEXT UNIQUE,
            contrasena TEXT
        );
        """

        let tablaMensajes = """
        CREATE TABLE IF NOT EXISTS mensajes_chat(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            reporte_id INTEGER,
            remitente TEXT,
            contenido TEXT,
            fecha TEXT,
            leido INTEGER DEFAULT 0
        );
        """

        execute(query: tablaUsuarios)
        execute(query: tablaReportes)
        execute(query: tablaResponsables)
        execute(query: tablaMensajes)
        insertarResponsablesDefecto()
    }
    
    // MARK: - Ejecutar consulta simple
    
    func execute(query: String) {
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Consulta ejecutada correctamente")
            } else {
                print("Error al ejecutar consulta")
            }
            
        } else {
            print("Error al preparar consulta")
        }
        
        sqlite3_finalize(statement)
    }
    
    // MARK: - Insertar responsables por defecto
    
    func insertarResponsablesDefecto() {
        let query = "INSERT OR IGNORE INTO responsables (usuario, contrasena) VALUES (?, ?);"
        let usuarios = [("recursosmat", "rm123"), ("mantenimiento", "m123")]
        for (usuario, contrasena) in usuarios {
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, (usuario as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 2, (contrasena as NSString).utf8String, -1, nil)
                sqlite3_step(statement)
            }
            sqlite3_finalize(statement)
        }
    }
    
    // MARK: - Área asignada según tipo de incidencia
    
    func areaParaTipo(_ tipo: String) -> String {
        let lower = tipo.lowercased()
        if lower.contains("sillas") || lower.contains("mesas") || lower.contains("agua")
            || lower.contains("fuga") || lower.contains("baño") {
            return "recursosmat"
        }
        return "mantenimiento"
    }
    
    // MARK: - Iniciar sesión responsable
    
    func iniciarSesionResponsable(usuario: String, contrasena: String) -> String? {
        let query = "SELECT usuario FROM responsables WHERE usuario = ? AND contrasena = ?;"
        var statement: OpaquePointer?
        var usuarioLogueado: String? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (usuario as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (contrasena as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let usuarioTexto = sqlite3_column_text(statement, 0)
                usuarioLogueado = usuarioTexto != nil ? String(cString: usuarioTexto!) : usuario
            }
        }
        sqlite3_finalize(statement)
        return usuarioLogueado
    }
    
    // MARK: - Obtener reportes filtrados por área
    
    func obtenerReportesDeArea(_ area: String) -> [Reporte] {
        return obtenerReportes().filter { areaParaTipo($0.tipo) == area }
    }
    
    // MARK: - Registrar usuario
    
    func registrarUsuario(numeroControl: String, contrasena: String) -> Bool {
        let query = "INSERT INTO usuarios (numeroControl, contrasena) VALUES (?, ?);"
        var statement: OpaquePointer?
        var registrado = false
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(statement, 1, (numeroControl as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (contrasena as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Usuario registrado correctamente")
                registrado = true
            } else {
                print("Error al registrar usuario")
            }
            
        } else {
            print("Error al preparar registro de usuario")
        }
        
        sqlite3_finalize(statement)
        return registrado
    }
    
    // MARK: - Iniciar sesión
    
    func iniciarSesion(numeroControl: String, contrasena: String) -> Bool {
        let query = "SELECT * FROM usuarios WHERE numeroControl = ? AND contrasena = ?;"
        var statement: OpaquePointer?
        var existeUsuario = false
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(statement, 1, (numeroControl as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (contrasena as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                print("Inicio de sesión correcto")
                existeUsuario = true
            } else {
                print("Número de control o contraseña incorrectos")
            }
            
        } else {
            print("Error al preparar inicio de sesión")
        }
        
        sqlite3_finalize(statement)
        return existeUsuario
    }
    
    // MARK: - Actualizar contraseña
    
    func actualizarContrasena(numeroControl: String, nuevaContrasena: String) -> Bool {
        let query = "UPDATE usuarios SET contrasena = ? WHERE numeroControl = ?;"
        var statement: OpaquePointer?
        var actualizado = false
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(statement, 1, (nuevaContrasena as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (numeroControl as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                if sqlite3_changes(db) > 0 {
                    print("Contraseña actualizada correctamente")
                    actualizado = true
                } else {
                    print("Número de control no encontrado")
                }
            } else {
                print("Error al actualizar contraseña")
            }
            
        } else {
            print("Error al preparar actualización de contraseña")
        }
        
        sqlite3_finalize(statement)
        return actualizado
    }
    
    // MARK: - Obtener usuarios
    
    func obtenerUsuarios() -> [Usuario] {
        let query = "SELECT id, numeroControl, contrasena FROM usuarios;"
        var statement: OpaquePointer?
        var usuarios: [Usuario] = []
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            
            while sqlite3_step(statement) == SQLITE_ROW {
                
                let id = Int(sqlite3_column_int(statement, 0))
                
                let numeroControlTexto = sqlite3_column_text(statement, 1)
                let contrasenaTexto = sqlite3_column_text(statement, 2)
                
                let numeroControl = numeroControlTexto != nil ? String(cString: numeroControlTexto!) : ""
                let contrasena = contrasenaTexto != nil ? String(cString: contrasenaTexto!) : ""
                
                let usuario = Usuario(
                    id: id,
                    numeroControl: numeroControl,
                    contrasena: contrasena
                )
                
                usuarios.append(usuario)
            }
            
        } else {
            print("Error al obtener usuarios")
        }
        
        sqlite3_finalize(statement)
        return usuarios
    }
    
    // MARK: - Eliminar usuario
    
    func eliminarUsuario(id: Int) -> Bool {
        let query = "DELETE FROM usuarios WHERE id = ?;"
        var statement: OpaquePointer?
        var eliminado = false
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(statement, 1, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Usuario eliminado correctamente")
                eliminado = true
            } else {
                print("Error al eliminar usuario")
            }
            
        } else {
            print("Error al preparar eliminación")
        }
        
        sqlite3_finalize(statement)
        return eliminado
    }
    
    // MARK: - Insertar reporte
    
    func insertarReporte(tipo: String, ubicacion: String, descripcion: String, estatus: String = "NUEVO") -> Int? {
        let query = "INSERT INTO reportes (tipo, ubicacion, descripcion, estatus) VALUES (?, ?, ?, ?);"
        var statement: OpaquePointer?
        var nuevoId: Int? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(statement, 1, (tipo as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (ubicacion as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (descripcion as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (estatus as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Reporte guardado correctamente")
                nuevoId = Int(sqlite3_last_insert_rowid(db))
            } else {
                print("Error al guardar reporte")
            }
            
        } else {
            print("Error al preparar reporte")
        }
        
        sqlite3_finalize(statement)
        return nuevoId
    }
    
    // MARK: - Obtener reportes
    
    func obtenerReportes() -> [Reporte] {
        let query = "SELECT id, tipo, ubicacion, descripcion, estatus FROM reportes;"
        var statement: OpaquePointer?
        var reportes: [Reporte] = []
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            
            while sqlite3_step(statement) == SQLITE_ROW {
                
                let id = Int(sqlite3_column_int(statement, 0))
                
                let tipoTexto = sqlite3_column_text(statement, 1)
                let ubicacionTexto = sqlite3_column_text(statement, 2)
                let descripcionTexto = sqlite3_column_text(statement, 3)
                let estatusTexto = sqlite3_column_text(statement, 4)
                
                let tipo = tipoTexto != nil ? String(cString: tipoTexto!) : ""
                let ubicacion = ubicacionTexto != nil ? String(cString: ubicacionTexto!) : ""
                let descripcion = descripcionTexto != nil ? String(cString: descripcionTexto!) : ""
                let estatus = estatusTexto != nil ? String(cString: estatusTexto!) : ""
                
                let reporte = Reporte(
                    id: id,
                    tipo: tipo,
                    ubicacion: ubicacion,
                    descripcion: descripcion,
                    estatus: estatus
                )
                
                reportes.append(reporte)
            }
            
        } else {
            print("Error al obtener reportes")
        }
        
        sqlite3_finalize(statement)
        return reportes
    }
    
    // MARK: - Actualizar estatus de reporte
    
    func actualizarEstatusReporte(id: Int, nuevoEstatus: String) -> Bool {
        let query = "UPDATE reportes SET estatus = ? WHERE id = ?;"
        var statement: OpaquePointer?
        var actualizado = false
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(statement, 1, (nuevoEstatus as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Estatus actualizado correctamente")
                actualizado = true
            } else {
                print("Error al actualizar estatus")
            }
            
        } else {
            print("Error al preparar actualización de estatus")
        }
        
        sqlite3_finalize(statement)

        if actualizado {
            let contenido = "📋 El estatus de tu reporte ha sido actualizado a: \(nuevoEstatus)."
            insertarMensajeChat(reporteId: id, remitente: "bot", contenido: contenido)
            enviarNotificacion(reporteId: id, nuevoEstatus: nuevoEstatus)
        }

        return actualizado
    }

    // MARK: - Enviar notificación local

    private func enviarNotificacion(reporteId: Int, nuevoEstatus: String) {
        let contenido = UNMutableNotificationContent()
        contenido.title = "REPORTEC – Actualización de reporte"
        contenido.body = "Tu reporte #\(reporteId) cambió su estatus a: \(nuevoEstatus)."
        contenido.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "reporte_\(reporteId)_\(Int(Date().timeIntervalSince1970))",
            content: contenido,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Eliminar reporte
    
    func eliminarReporte(id: Int) -> Bool {
        eliminarMensajesDeReporte(reporteId: id)
        let query = "DELETE FROM reportes WHERE id = ?;"
        var statement: OpaquePointer?
        var eliminado = false
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(statement, 1, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Reporte eliminado correctamente")
                eliminado = true
            } else {
                print("Error al eliminar reporte")
            }
            
        } else {
            print("Error al preparar eliminación de reporte")
        }
        
        sqlite3_finalize(statement)
        return eliminado
    }

    // MARK: - Obtener un reporte por ID

    func obtenerReporte(id: Int) -> Reporte? {
        let query = "SELECT id, tipo, ubicacion, descripcion, estatus FROM reportes WHERE id = ?;"
        var statement: OpaquePointer?
        var reporte: Reporte? = nil

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            if sqlite3_step(statement) == SQLITE_ROW {
                let rid = Int(sqlite3_column_int(statement, 0))
                let tipo = sqlite3_column_text(statement, 1).map { String(cString: $0) } ?? ""
                let ubicacion = sqlite3_column_text(statement, 2).map { String(cString: $0) } ?? ""
                let descripcion = sqlite3_column_text(statement, 3).map { String(cString: $0) } ?? ""
                let estatus = sqlite3_column_text(statement, 4).map { String(cString: $0) } ?? ""
                reporte = Reporte(id: rid, tipo: tipo, ubicacion: ubicacion, descripcion: descripcion, estatus: estatus)
            }
        }
        sqlite3_finalize(statement)
        return reporte
    }

    // MARK: - Insertar mensaje de chat

    @discardableResult
    func insertarMensajeChat(reporteId: Int, remitente: String, contenido: String) -> Int? {
        let query = "INSERT INTO mensajes_chat (reporte_id, remitente, contenido, fecha, leido) VALUES (?, ?, ?, ?, ?);"
        var statement: OpaquePointer?
        var nuevoId: Int? = nil
        let fecha = ISO8601DateFormatter().string(from: Date())
        let leido: Int32 = remitente == "usuario" ? 1 : 0

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(reporteId))
            sqlite3_bind_text(statement, 2, (remitente as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (contenido as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (fecha as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 5, leido)
            if sqlite3_step(statement) == SQLITE_DONE {
                nuevoId = Int(sqlite3_last_insert_rowid(db))
            }
        }
        sqlite3_finalize(statement)
        return nuevoId
    }

    // MARK: - Obtener mensajes de chat de un reporte

    func obtenerMensajesChat(reporteId: Int) -> [MensajeChat] {
        let query = "SELECT id, reporte_id, remitente, contenido, fecha, leido FROM mensajes_chat WHERE reporte_id = ? ORDER BY id ASC;"
        var statement: OpaquePointer?
        var mensajes: [MensajeChat] = []

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(reporteId))
            while sqlite3_step(statement) == SQLITE_ROW {
                let mid = Int(sqlite3_column_int(statement, 0))
                let rid = Int(sqlite3_column_int(statement, 1))
                let remitente = sqlite3_column_text(statement, 2).map { String(cString: $0) } ?? ""
                let contenido = sqlite3_column_text(statement, 3).map { String(cString: $0) } ?? ""
                let fecha = sqlite3_column_text(statement, 4).map { String(cString: $0) } ?? ""
                let leido = sqlite3_column_int(statement, 5) == 1
                mensajes.append(MensajeChat(id: mid, reporteId: rid, remitente: remitente, contenido: contenido, fecha: fecha, leido: leido))
            }
        }
        sqlite3_finalize(statement)
        return mensajes
    }

    // MARK: - Contar mensajes no leídos (bot) de un reporte

    func contarMensajesNoLeidos(reporteId: Int) -> Int {
        let query = "SELECT COUNT(*) FROM mensajes_chat WHERE reporte_id = ? AND leido = 0;"
        var statement: OpaquePointer?
        var count = 0

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(reporteId))
            if sqlite3_step(statement) == SQLITE_ROW {
                count = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        return count
    }

    // MARK: - Marcar mensajes de un reporte como leídos

    func marcarMensajesLeidos(reporteId: Int) {
        let query = "UPDATE mensajes_chat SET leido = 1 WHERE reporte_id = ?;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(reporteId))
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    // MARK: - Eliminar mensajes de chat de un reporte

    func eliminarMensajesDeReporte(reporteId: Int) {
        let query = "DELETE FROM mensajes_chat WHERE reporte_id = ?;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(reporteId))
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }
}
