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

    private let fondoAzulPlano = Color(red: 0.0, green: 0.3, blue: 0.95)
    private let userBubbleStart = Color(red: 0.12, green: 0.18, blue: 0.88)
    private let userBubbleEnd = Color(red: 0.06, green: 0.11, blue: 0.66)
    private let botBubbleColor = Color(red: 0.90, green: 0.95, blue: 1.00)
    private let chatSurface = Color(red: 0.84, green: 0.90, blue: 0.97)

    var areaAsignada: String {
        let lower = tipoIncidencia.lowercased()
        if lower.contains("sillas") || lower.contains("mesas") || lower.contains("agua")
            || lower.contains("fuga") || lower.contains("baño") {
            return "Recursos Materiales"
        }
        return "Mantenimiento"
    }

    var body: some View {
        ZStack {
            fondoAzulPlano
                .ignoresSafeArea()

            VStack(spacing: 0) {

                ZStack {
                    VStack(spacing: 2) {
                        Text("REPORTEC")
                            .font(.system(size: 34, weight: .heavy))
                            .foregroundColor(.white)
                        Text("Asistente de Reportes")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                    }

                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.title3.weight(.bold))
                                .frame(width: 38, height: 38)
                                .background(Color.white.opacity(0.16))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 30)
                .padding(.bottom, 22)

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 14) {
                            HStack(spacing: 10) {
                                Image(systemName: "sparkles.bubble")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(red: 0.07, green: 0.33, blue: 0.82))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Bienvenido")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.black.opacity(0.74))
                                    Text("Vamos a registrar tu reporte paso a paso")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black.opacity(0.55))
                                }
                                Spacer()
                            }
                            .padding(.top, 22)
                            .padding(.horizontal, 20)

                            ChatBubbleUsuario(texto: tipoIncidencia, start: userBubbleStart, end: userBubbleEnd)
                                .padding(.horizontal, 20)

                            ChatBubbleBot(
                                texto: "Entendido. Vas a reportar:\n\"\(tipoIncidencia)\".\n\nPrimero dime la ubicación exacta (edificio / salón o área).",
                                color: botBubbleColor
                            )
                            .padding(.horizontal, 20)

                            if !ubicacionEnviada.isEmpty {
                                ChatBubbleUsuario(texto: ubicacionEnviada, start: userBubbleStart, end: userBubbleEnd)
                                    .padding(.horizontal, 20)

                                ChatBubbleBot(
                                    texto: "Gracias. Ahora dime, ¿qué notas? (descripción del problema)",
                                    color: botBubbleColor
                                )
                                .padding(.horizontal, 20)
                            }

                            if !descripcionEnviada.isEmpty {
                                ChatBubbleUsuario(texto: descripcionEnviada, start: userBubbleStart, end: userBubbleEnd)
                                    .padding(.horizontal, 20)

                                if case .reporteCreado(let folio) = estadoChat {
                                    ChatBubbleBot(
                                        texto: "✅ Reporte creado con folio #\(folio).\n\n• Tipo: \(tipoIncidencia)\n• Ubicación: \(ubicacionEnviada)\n• Descripción: \(descripcionEnviada)\n• Área asignada: \(areaAsignada)\n• Prioridad: Media\n\nEstatus actual: NUEVO (recibido)\nTe avisaremos por este chat cuando haya cambios.",
                                        color: botBubbleColor
                                    )
                                    .padding(.horizontal, 20)
                                    .id("confirmacion")
                                }
                            }

                            Color.clear
                                .frame(height: 1)
                                .id("bottom")
                        }
                        .padding(.bottom, 14)
                    }
                    .onChange(of: estadoChat) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(chatSurface)
                .clipShape(RoundedRectangle(cornerRadius: 42, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 42, style: .continuous)
                        .stroke(Color.white.opacity(0.32), lineWidth: 1)
                )
                .padding(.horizontal, 8)

                if estadoChat == .esperandoUbicacion || estadoChat == .esperandoDescripcion {
                    HStack(spacing: 10) {
                        TextField(
                            estadoChat == .esperandoUbicacion
                                ? "Escribe la ubicación (edificio / salón o área)..."
                                : "Escribe la descripción del problema...",
                            text: $mensaje
                        )
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        Button(action: { enviarMensaje() }) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 48, height: 48)
                                .background(Color.black)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.22), radius: 6, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
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
            guard let numeroControl = SessionManager.shared.numeroControlActual else { return }
            if let folio = DatabaseManager.shared.insertarReporte(
                tipo: tipoIncidencia,
                ubicacion: ubicacionEnviada,
                descripcion: trimmed,
                numeroControl: numeroControl
            ) {
                let db = DatabaseManager.shared
                db.insertarMensajeChat(reporteId: folio, remitente: "usuario", contenido: tipoIncidencia)
                db.insertarMensajeChat(reporteId: folio, remitente: "bot",
                    contenido: "Entendido. Vas a reportar:\n\"\(tipoIncidencia)\".\n\nPrimero dime la ubicación exacta (edificio / salón o área).")
                db.insertarMensajeChat(reporteId: folio, remitente: "usuario", contenido: ubicacionEnviada)
                db.insertarMensajeChat(reporteId: folio, remitente: "bot",
                    contenido: "Gracias. Ahora dime, ¿qué notas? (descripción del problema)")
                db.insertarMensajeChat(reporteId: folio, remitente: "usuario", contenido: trimmed)
                db.insertarMensajeChat(reporteId: folio, remitente: "bot",
                    contenido: "✅ Reporte creado con folio #\(folio).\n\n• Tipo: \(tipoIncidencia)\n• Ubicación: \(ubicacionEnviada)\n• Descripción: \(trimmed)\n• Área asignada: \(areaAsignada)\n• Prioridad: Media\n\nEstatus actual: NUEVO (recibido)\nTe avisaremos por este chat cuando haya cambios.")

                estadoChat = .reporteCreado(folio: folio)
            }
        }
    }
}

private struct ChatBubbleUsuario: View {
    let texto: String
    let start: Color
    let end: Color

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 5) {
                Text("Tú")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.black.opacity(0.45))
                Text(texto)
                    .foregroundColor(.white)
                    .font(.system(size: 15, weight: .medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .frame(maxWidth: 265, alignment: .leading)
                    .background(
                        LinearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }
}

private struct ChatBubbleBot: View {
    let texto: String
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Asistente")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.black.opacity(0.45))
                Text(texto)
                    .foregroundColor(.black.opacity(0.78))
                    .font(.system(size: 15))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .frame(maxWidth: 320, alignment: .leading)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.8), lineWidth: 1)
                    )
            }
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        ChatView2(tipoIncidencia: "El clima no funciona (no está encendido)")
    }
}
