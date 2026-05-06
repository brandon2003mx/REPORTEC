import SwiftUI

struct MisReportesView: View {

    @Environment(\.dismiss) var dismiss
    @State private var reportes: [Reporte] = []

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
                                    ReporteCardView(reporte: reporte)
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
    }

    func cargarReportes() {
        reportes = DatabaseManager.shared.obtenerReportes()
    }
}

// MARK: - Tarjeta de reporte

struct ReporteCardView: View {

    let reporte: Reporte

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Fila superior: folio + badge de estatus
            HStack {
                Text("Folio #\(reporte.id)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(red: 0.10, green: 0.08, blue: 0.85))
                Spacer()
                EstatusBadge(estatus: reporte.estatus)
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
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 3)
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
