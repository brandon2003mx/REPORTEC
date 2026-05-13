import SwiftUI

struct ChatView: View {

    @State private var numeroIncidencia = ""
    @State private var navegarAChat2 = false
    @State private var navegarAMisReportes = false
    @State private var tipoSeleccionado = ""
    @State private var mostrarError = false

    private let fondoAzulPlano = Color(red: 0.0, green: 0.3, blue: 0.95)
    private let panelColor = Color(red: 0.84, green: 0.90, blue: 0.97)
    private let cardColor = Color(red: 0.90, green: 0.95, blue: 1.00)
    private let accentBlue = Color(red: 0.12, green: 0.18, blue: 0.88)

    let opciones: [String: String] = [
        "1": "El clima no funciona (no está encendido)",
        "2": "Hace falta sillas",
        "3": "Hay una fuga en el baño",
        "4": "No hay agua en el edificio",
        "5": "No hay electricidad en el edificio"
    ]

    var body: some View {
        ZStack {
            fondoAzulPlano
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 2) {
                    Text("REPORTEC")
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundColor(.white)
                    Text("Asistente de Reportes")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(.top, 30)
                .padding(.bottom, 22)

                GeometryReader { _ in
                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles.bubble")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 0.07, green: 0.33, blue: 0.82))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Bienvenido")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black.opacity(0.74))
                                Text("Selecciona la incidencia para continuar")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.black.opacity(0.55))
                            }

                            Spacer()

                            Button(action: { navegarAMisReportes = true }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "list.bullet.clipboard.fill")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("Mis Reportes")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundColor(accentBlue)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 20)

                        HStack {
                            Text("Selecciona un número de incidencia y se enviará al área encargada.")
                                .font(.system(size: 14))
                                .foregroundColor(.black.opacity(0.78))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                                .background(cardColor)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(Color.white.opacity(0.8), lineWidth: 1)
                                )
                            Spacer()
                        }
                        .padding(.horizontal, 24)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("1. El clima no funciona (No está encendido)")
                            Text("2. Hace falta sillas")
                            Text("3. Hay una fuga en el baño")
                            Text("4. No hay agua en el edificio")
                            Text("5. No hay electricidad en el edificio")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.12, green: 0.18, blue: 0.88), Color(red: 0.06, green: 0.11, blue: 0.66)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.horizontal, 24)

                        Image("mascota")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .opacity(0.3)

                        if mostrarError {
                            Text("Por favor ingresa un número válido del 1 al 5.")
                                .foregroundColor(.red)
                                .font(.system(size: 13, weight: .semibold))
                                .padding(.horizontal, 20)
                        }

                        Spacer(minLength: 0)

                        HStack(spacing: 10) {
                            TextField("Ingresa el número de incidencia...", text: $numeroIncidencia)
                                .keyboardType(.numberPad)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                            Button(action: { enviarNumero() }) {
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
                        .padding(.bottom, 14)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(panelColor)
                    .clipShape(RoundedRectangle(cornerRadius: 42, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 42, style: .continuous)
                            .stroke(Color.white.opacity(0.32), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 8)
            }
        }
        .navigationDestination(isPresented: $navegarAChat2) {
            ChatView2(tipoIncidencia: tipoSeleccionado)
        }
        .navigationDestination(isPresented: $navegarAMisReportes) {
            MisReportesView()
        }
        .navigationBarBackButtonHidden(true)
    }

    func enviarNumero() {
        let trimmed = numeroIncidencia.trimmingCharacters(in: .whitespaces)
        if let tipo = opciones[trimmed] {
            tipoSeleccionado = tipo
            mostrarError = false
            navegarAChat2 = true
        } else {
            mostrarError = true
        }
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
