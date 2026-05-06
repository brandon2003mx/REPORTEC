import Foundation
import SQLite3

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

struct Reporte: Identifiable {
    var id: Int
    var tipo: String
    var ubicacion: String
    var descripcion: String
    var estatus: String
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
        
        execute(query: tablaUsuarios)
        execute(query: tablaReportes)
        execute(query: tablaResponsables)
        insertarResponsableDefecto()
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
    
    // MARK: - Insertar responsable por defecto
    
    func insertarResponsableDefecto() {
        let query = "INSERT OR IGNORE INTO responsables (usuario, contrasena) VALUES (?, ?);"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, ("responsable" as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, ("Admin2024" as NSString).utf8String, -1, nil)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - Iniciar sesión responsable
    
    func iniciarSesionResponsable(usuario: String, contrasena: String) -> Bool {
        let query = "SELECT * FROM responsables WHERE usuario = ? AND contrasena = ?;"
        var statement: OpaquePointer?
        var existe = false
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (usuario as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (contrasena as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                existe = true
            }
        }
        sqlite3_finalize(statement)
        return existe
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
        return actualizado
    }
    
    // MARK: - Eliminar reporte
    
    func eliminarReporte(id: Int) -> Bool {
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
}
