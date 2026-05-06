import SwiftUI

enum EstadoChat: Equatable {
    case esperandoDescripcion
    case reporteCreado(folio: Int)
}

struct ChatView2: View {

    @Environment(\.dismiss) var dismiss
    @State private var mensaje = ""
    @State private var descripcionEnviada = ""
    @State private var estadoChat: EstadoChat = .esperandoDescripcion

    let tipoIncidencia: String

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

                                    Text("\u{00BF}Como te puedo ayudar?")
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

                            // Burbuja: bot pide detalles
                            HStack {
                                Text("Entendido. Vas a reportar:\n\"\(tipoIncidencia)\".\n\nPara generar tu reporte necesito:\n1. Ubicacion exacta (edificio / salon o area)\n2. \u{00BF}Que notas? (descripcion del problema)")
                                    .foregroundColor(.white)
                                    .font(.system(size: 15))
                                    .padding()
                                    .frame(maxWidth: 320, alignment: .leading)
                                    .background(Color(red: 0.00, green: 0.3, blue: 0.95))
                                    .cornerRadius(25)
                                Spacer()
                            }
                            .padding(.horizontal, 20)

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
                                        Text("\u{2705} Reporte creado con folio #\(folio).\n\n\u{2022} Tipo: \(tipoIncidencia)\n\u{2022} Descripcion: \(descripcionEnviada)\n\u{2022} Area asignada: Mantenimiento\n\u{2022} Prioridad: Media\n\nEstatus actual: NUEVO (recibido)\nTe avisaremos por este chat cuando haya cambios.")
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

                // Campo de texto (visible solo mientras se espera descripcion)
                if case .esperandoDescripcion = estadoChat {
                    HStack(spacing: 12) {
                        TextField("Escribe la ubicacion y descripcion del problema...", text: $mensaje)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)

                        Button(action: {
                            enviarDescripcion()
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

    func enviarDescripcion() {
        let trimmed = mensaje.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        descripcionEnviada = trimmed
        mensaje = ""

        if let folio = DatabaseManager.shared.insertarReporte(
            tipo: tipoIncidencia,
            ubicacion: trimmed,
            descripcion: trimmed
        ) {
            estadoChat = .reporteCreado(folio: folio)
        }
    }
}

#Preview {
    NavigationStack {
        ChatView2(tipoIncidencia: "El clima no funciona (no esta encendido)")
    }
}
