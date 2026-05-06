import SwiftUI

enum EstadoChat: Equatable {
    case esperandoUbicacion
    case esperandoDescripcion
    case reporteCreado(folio: Int)
}

struct ChatView2: View {

    @Environment(\.dismiss) var dismiss
    @State private var mensaje = ""
    @State private var ubicacionEnviada = ""
    @State private var descripcionEnviada = ""
    @State private var estadoChat: EstadoChat = .esperandoUbicacion

    let tipoIncidencia: String

    var areaAsignada: String {
        let lower = tipoIncidencia.lowercased()
        if lower.contains("sillas") || lower.contains("mesas") || lower.contains("agua") {
            return "Recursos Materiales"
        }
        return "Mantenimiento"
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
                        Button(action: {
                            dismiss()
                        }) {
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

                // Area de chat con scroll
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 18) {

                            // Saludo
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Bienvenido")
                                        .font(.system(size: 30, weight: .bold))
                                        .foregroundColor(.black.opacity(0.7))

                                    Text("¿Cómo te puedo ayudar?")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.black.opacity(0.7))
                                }
                                Spacer()
                            }
                            .padding(.top, 25)
                            .padding(.horizontal, 20)

                            // Burbuja: tipo de incidencia seleccionado (usuario)
                            HStack {
                                Spacer()
                                Text(tipoIncidencia)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                                    .padding()
                                    .frame(maxWidth: 260, alignment: .leading)
                                    .background(Color(red: 0.12, green: 0.05, blue: 0.85))
                                    .cornerRadius(25)
                            }
                            .padding(.horizontal, 20)

                            // Burbuja: bot pide ubicacion
                            HStack {
                                Text("Entendido. Vas a reportar:\n\"\(tipoIncidencia)\".\n\nPrimero dime la ubicación exacta (edificio / salón o área).")
                                    .foregroundColor(.white)
                                    .font(.system(size: 15))
                                    .padding()
                                    .frame(maxWidth: 320, alignment: .leading)
                                    .background(Color(red: 0.00, green: 0.3, blue: 0.95))
                                    .cornerRadius(25)
                                Spacer()
                            }
                            .padding(.horizontal, 20)

                            // Mostrar ubicacion enviada y pedir descripcion
                            if !ubicacionEnviada.isEmpty {

                                // Burbuja: ubicacion del usuario
                                HStack {
                                    Spacer()
                                    Text(ubicacionEnviada)
                                        .foregroundColor(.white)
                                        .font(.system(size: 16))
                                        .padding()
                                        .frame(maxWidth: 260, alignment: .leading)
                                        .background(Color(red: 0.12, green: 0.05, blue: 0.85))
                                        .cornerRadius(25)
                                }
                                .padding(.horizontal, 20)

                                // Burbuja: bot pide descripcion
                                HStack {
                                    Text("Gracias. Ahora dime, ¿qué notas? (descripción del problema)")
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

                            // Mostrar descripcion del usuario y confirmacion tras enviar
                            if !descripcionEnviada.isEmpty {

                                // Burbuja: descripcion del usuario
                                HStack {
                                    Spacer()
                                    Text(descripcionEnviada)
                                        .foregroundColor(.white)
                                        .font(.system(size: 16))
                                        .padding()
                                        .frame(maxWidth: 260, alignment: .leading)
                                        .background(Color(red: 0.12, green: 0.05, blue: 0.85))
                                        .cornerRadius(25)
                                }
                                .padding(.horizontal, 20)

                                // Burbuja: confirmacion del bot con folio
                                if case .reporteCreado(let folio) = estadoChat {
                                    HStack {
                                        Text("✅ Reporte creado con folio #\(folio).\n\n• Tipo: \(tipoIncidencia)\n• Ubicación: \(ubicacionEnviada)\n• Descripción: \(descripcionEnviada)\n• Área asignada: \(areaAsignada)\n• Prioridad: Media\n\nEstatus actual: NUEVO (recibido)\nTe avisaremos por este chat cuando haya cambios.")
                                            .foregroundColor(.white)
                                            .font(.system(size: 15))
                                            .padding()
                                            .frame(maxWidth: 330, alignment: .leading)
                                            .background(Color(red: 0.00, green: 0.3, blue: 0.95))
                                            .cornerRadius(25)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    .id("confirmacion")
                                }
                            }

                            Color.clear
                                .frame(height: 1)
                                .id("bottom")
                        }
                        .padding(.bottom, 10)
                    }
                    .onChange(of: estadoChat) { _ in
                        withAnimation {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.86, green: 0.90, blue: 0.93))
                .clipShape(RoundedRectangle(cornerRadius: 45, style: .continuous))
                .padding(.horizontal, 8)

                // Campo de texto (visible mientras se espera ubicacion o descripcion)
                if estadoChat == .esperandoUbicacion || estadoChat == .esperandoDescripcion {
                    HStack(spacing: 12) {
                        TextField(
                            estadoChat == .esperandoUbicacion
                                ? "Escribe la ubicación (edificio / salón o área)..."
                                : "Escribe la descripción del problema...",
                            text: $mensaje
                        )
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)

                        Button(action: {
                            enviarMensaje()
                        }) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .frame(width: 58, height: 58)
                                .background(Color.black)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    func enviarMensaje() {
        let trimmed = mensaje.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        mensaje = ""

        if estadoChat == .esperandoUbicacion {
            ubicacionEnviada = trimmed
            estadoChat = .esperandoDescripcion
        } else if estadoChat == .esperandoDescripcion {
            descripcionEnviada = trimmed
            if let folio = DatabaseManager.shared.insertarReporte(
                tipo: tipoIncidencia,
                ubicacion: ubicacionEnviada,
                descripcion: trimmed
            ) {
                estadoChat = .reporteCreado(folio: folio)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView2(tipoIncidencia: "El clima no funciona (no está encendido)")
    }
}
