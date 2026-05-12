import SwiftUI

struct GestionReportesView: View {

    @Environment(\.dismiss) var dismiss
    @State private var reportes: [Reporte] = []
    @State private var mostrarAlerta = false
    @State private var mensajeAlerta = ""

    let areaUsuario: String
    let estatusOpciones = ["NUEVO", "EN PROCESO", "RESUELTO", "CERRADO"]

    var nombreArea: String {
        areaUsuario == "recursosmat" ? "Recursos Materiales" : "Mantenimiento"
    }

    var body: some View {
        ZStack {
            Color(red: 0.10, green: 0.08, blue: 0.85)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // Encabezado
                ZStack {
                    Text("REPORTEC")
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundColor(.white)

                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.title2)
                                .padding(10)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 30)
                .padding(.bottom, 25)

                // Contenido principal
                VStack(spacing: 0) {

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Gestión de Reportes")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black.opacity(0.75))
                            Text(nombreArea)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.10, green: 0.08, blue: 0.85))
                            Text("\(reportes.count) reporte\(reportes.count == 1 ? "" : "s") registrado\(reportes.count == 1 ? "" : "s")")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: { cargarReportes() }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 0.10, green: 0.08, blue: 0.85))
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 25)
                    .padding(.bottom, 15)

                    if reportes.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "tray.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No hay reportes aún")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.gray)
                            Text("Los reportes enviados por los alumnos aparecerán aquí.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                ForEach(reportes) { reporte in
                                    GestionReporteCardView(
                                        reporte: reporte,
                                        estatusOpciones: estatusOpciones,
                                        onCambiarEstatus: { nuevoEstatus in
                                            cambiarEstatus(reporte: reporte, nuevoEstatus: nuevoEstatus)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.86, green: 0.90, blue: 0.93))
                .clipShape(RoundedRectangle(cornerRadius: 45, style: .continuous))
                .padding(.horizontal, 8)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { cargarReportes() }
        .alert("Aviso", isPresented: $mostrarAlerta) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(mensajeAlerta)
        }
    }

    func cargarReportes() {
        reportes = DatabaseManager.shared.obtenerReportesDeArea(areaUsuario)
    }

    func cambiarEstatus(reporte: Reporte, nuevoEstatus: String) {
        guard reporte.estatus != nuevoEstatus else { return }

        let actualizado = DatabaseManager.shared.actualizarEstatusReporte(id: reporte.id, nuevoEstatus: nuevoEstatus)
        if actualizado {
            cargarReportes()
            sendStatusChangeEmail(reporte: reporte, nuevoEstatus: nuevoEstatus)
        } else {
            mensajeAlerta = "No se pudo actualizar el estatus."
            mostrarAlerta = true
        }
    }

    func sendStatusChangeEmail(reporte: Reporte, nuevoEstatus: String) {
        guard let correoDestino = DatabaseManager.shared.obtenerCorreoDeReporte(id: reporte.id),
              !correoDestino.isEmpty else {
            mensajeAlerta = "El estatus se actualizó, pero el reporte no tiene un correo asociado."
            mostrarAlerta = true
            return
        }

        guard EmailValidator.esValido(correoDestino) else {
            mensajeAlerta = "El estatus se actualizó, pero el correo del estudiante no es válido."
            mostrarAlerta = true
            return
        }

        let asunto = "Actualización de reporte #\(reporte.id)"
        let cuerpo = """
        Hola,

        El estatus de tu reporte #\(reporte.id) cambió a: \(nuevoEstatus).

        Tipo: \(reporte.tipo)
        Ubicación: \(reporte.ubicacion)

        Equipo REPORTEC
        """

        EmailService.enviarCorreo(destinatario: correoDestino, asunto: asunto, cuerpo: cuerpo) { resultado in
            switch resultado {
            case .success:
                mensajeAlerta = "Estatus actualizado. Correo enviado a \(correoDestino)."
                mostrarAlerta = true
            case .failure(let error):
                mensajeAlerta = "El estatus se actualizó, pero no se pudo enviar el correo: \(error.localizedDescription)"
                mostrarAlerta = true
            }
        }
    }
}

// MARK: - Tarjeta de gestión de reporte

struct GestionReporteCardView: View {

    let reporte: Reporte
    let estatusOpciones: [String]
    let onCambiarEstatus: (String) -> Void

    @State private var estatusSeleccionado: String

    init(reporte: Reporte, estatusOpciones: [String], onCambiarEstatus: @escaping (String) -> Void) {
        self.reporte = reporte
        self.estatusOpciones = estatusOpciones
        self.onCambiarEstatus = onCambiarEstatus
        _estatusSeleccionado = State(initialValue: reporte.estatus)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Folio + badge
            HStack {
                Text("Folio #\(reporte.id)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(red: 0.10, green: 0.08, blue: 0.85))
                Spacer()
                EstatusBadge(estatus: estatusSeleccionado)
            }

            Divider()

            // Tipo
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 14))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tipo de incidencia")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)
                    Text(reporte.tipo)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.8))
                }
            }

            // Ubicación
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(Color(red: 0.10, green: 0.08, blue: 0.85))
                    .font(.system(size: 14))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ubicación")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)
                    Text(reporte.ubicacion)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.8))
                }
            }

            // Descripción
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "text.alignleft")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Descripción")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)
                    Text(reporte.descripcion)
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.75))
                        .lineLimit(3)
                }
            }

            Divider()

            // Selector de estatus
            VStack(alignment: .leading, spacing: 6) {
                Text("Actualizar estatus")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)

                HStack(spacing: 8) {
                    ForEach(estatusOpciones, id: \.self) { opcion in
                        Button(action: {
                            estatusSeleccionado = opcion
                            onCambiarEstatus(opcion)
                        }) {
                            Text(opcion)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(estatusSeleccionado == opcion ? .white : Color(red: 0.10, green: 0.08, blue: 0.85))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    estatusSeleccionado == opcion
                                        ? EstatusBadge(estatus: opcion).badgeColor
                                        : Color(red: 0.10, green: 0.08, blue: 0.85).opacity(0.08)
                                )
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    NavigationStack {
        GestionReportesView(areaUsuario: "mantenimiento")
    }
}
