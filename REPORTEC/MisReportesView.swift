import SwiftUI

struct MisReportesView: View {

    @Environment(\.dismiss) var dismiss
    @State private var reportes: [Reporte] = []
    @State private var unreadCounts: [Int: Int] = [:]
    @State private var reporteSeleccionado: Reporte? = nil
    @State private var reporteAEliminar: Reporte? = nil
    @State private var mostrarAlertaEliminar = false

    var body: some View {
        ZStack {
            Color(red: 0.10, green: 0.40, blue: 0.85)
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
                            Text("Mis Reportes")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.black.opacity(0.75))
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
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No tienes reportes aún")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.gray)
                            Text("Cuando crees un reporte aparecerá aquí.")
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
                                    ReporteCardView(
                                        reporte: reporte,
                                        mensajesNoLeidos: unreadCounts[reporte.id] ?? 0,
                                        onTap: { reporteSeleccionado = reporte },
                                        onEliminar: {
                                            reporteAEliminar = reporte
                                            mostrarAlertaEliminar = true
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
        .navigationDestination(item: $reporteSeleccionado) { reporte in
            ReporteChatView(reporte: reporte)
        }
        .alert("Eliminar reporte", isPresented: $mostrarAlertaEliminar, presenting: reporteAEliminar) { reporte in
            Button("Eliminar", role: .destructive) {
                eliminarReporte(reporte: reporte)
            }
            Button("Cancelar", role: .cancel) {
                reporteAEliminar = nil
            }
        } message: { reporte in
            Text("¿Deseas eliminar el Reporte #\(reporte.id)? Esta acción no se puede deshacer.")
        }
    }

    func cargarReportes() {
        guard let numeroControl = SessionManager.shared.numeroControlActual else {
            reportes = []
            unreadCounts = [:]
            return
        }

        reportes = DatabaseManager.shared.obtenerReportesDelUsuario(numeroControl)
        var counts: [Int: Int] = [:]
        for reporte in reportes {
            let n = DatabaseManager.shared.contarMensajesNoLeidos(reporteId: reporte.id)
            if n > 0 { counts[reporte.id] = n }
        }
        unreadCounts = counts
    }

    func eliminarReporte(reporte: Reporte) {
        _ = DatabaseManager.shared.eliminarReporte(id: reporte.id)
        reporteAEliminar = nil
        cargarReportes()
    }
}

// MARK: - Tarjeta de reporte

struct ReporteCardView: View {

    let reporte: Reporte
    let mensajesNoLeidos: Int
    let onTap: () -> Void
    let onEliminar: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {

                // Fila superior: folio + badge de estatus + eliminar
                HStack {
                    Text("Folio #\(reporte.id)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.10, green: 0.08, blue: 0.85))
                    Spacer()
                    EstatusBadge(estatus: reporte.estatus)
                    Button(action: onEliminar) {
                        Image(systemName: "trash")
                            .font(.system(size: 15))
                            .foregroundColor(.red.opacity(0.75))
                            .padding(8)
                            .background(Color.red.opacity(0.08))
                            .clipShape(Circle())
                    }
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

                // Badge de mensajes no leídos
                if mensajesNoLeidos > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                        Text("\(mensajesNoLeidos) mensaje\(mensajesNoLeidos == 1 ? "" : "s") nuevo\(mensajesNoLeidos == 1 ? "" : "s")")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red)
                    .clipShape(Capsule())
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Badge de estatus

struct EstatusBadge: View {

    let estatus: String

    var badgeColor: Color {
        switch estatus.uppercased() {
        case "NUEVO":      return Color(red: 0.10, green: 0.08, blue: 0.85)
        case "EN PROCESO": return Color.orange
        case "RESUELTO":   return Color(red: 0.15, green: 0.60, blue: 0.35)
        case "CERRADO":    return Color.gray
        default:           return Color.secondary
        }
    }

    var body: some View {
        Text(estatus)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(badgeColor)
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        MisReportesView()
    }
}
