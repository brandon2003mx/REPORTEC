import SwiftUI

struct ReporteChatView: View {

    @Environment(\.dismiss) var dismiss
    let reporteInicial: Reporte

    @State private var reporte: Reporte
    @State private var mensajes: [MensajeChat] = []

    init(reporte: Reporte) {
        self.reporteInicial = reporte
        _reporte = State(initialValue: reporte)
    }

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
                        Button(action: { cargarDatos() }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white)
                                .font(.title3)
                                .padding(10)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 30)
                .padding(.bottom, 25)

                // Área de chat
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 18) {

                            // Info del reporte
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Folio #\(reporte.id)")
                                        .font(.system(size: 26, weight: .bold))
                                        .foregroundColor(.black.opacity(0.75))
                                    EstatusBadge(estatus: reporte.estatus)
                                }
                                Spacer()
                            }
                            .padding(.top, 25)
                            .padding(.horizontal, 20)

                            if mensajes.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "bubble.left.and.bubble.right")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray.opacity(0.45))
                                    Text("No hay mensajes en este chat.")
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                }
                                .padding(.top, 40)
                            } else {
                                ForEach(mensajes) { mensaje in
                                    if mensaje.remitente == "usuario" {
                                        HStack {
                                            Spacer()
                                            Text(mensaje.contenido)
                                                .foregroundColor(.white)
                                                .font(.system(size: 15))
                                                .padding()
                                                .frame(maxWidth: 260, alignment: .leading)
                                                .background(Color(red: 0.12, green: 0.05, blue: 0.85))
                                                .cornerRadius(25)
                                        }
                                        .padding(.horizontal, 20)
                                    } else {
                                        HStack {
                                            Text(mensaje.contenido)
                                                .foregroundColor(.white)
                                                .font(.system(size: 15))
                                                .padding()
                                                .frame(maxWidth: 320, alignment: .leading)
                                                .background(Color(red: 0.00, green: 0.3, blue: 0.95))
                                                .cornerRadius(25)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }

                            Color.clear
                                .frame(height: 1)
                                .id("bottom")
                        }
                        .padding(.bottom, 20)
                    }
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .onChange(of: mensajes.count) {
                        withAnimation {
                            proxy.scrollTo("bottom", anchor: .bottom)
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
        .onAppear { cargarDatos() }
    }

    func cargarDatos() {
        if let fresco = DatabaseManager.shared.obtenerReporte(id: reporteInicial.id) {
            reporte = fresco
        }
        mensajes = DatabaseManager.shared.obtenerMensajesChat(reporteId: reporte.id)
        DatabaseManager.shared.marcarMensajesLeidos(reporteId: reporte.id)
    }
}

#Preview {
    NavigationStack {
        ReporteChatView(reporte: Reporte(id: 1, tipo: "Hay una fuga en el baño", ubicacion: "Edificio A", descripcion: "Fuga en el lavabo", estatus: "EN PROCESO"))
    }
}
