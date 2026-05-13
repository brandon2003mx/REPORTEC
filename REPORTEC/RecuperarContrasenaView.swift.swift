import SwiftUI

struct RecuperarContrasenaView: View {

    @Environment(\.dismiss) var dismiss

    @State private var numeroControl = ""
    @State private var nuevaContrasena = ""
    @State private var confirmarContrasena = ""

    @State private var mostrarAlerta = false
    @State private var mensajeAlerta = ""
    @State private var actualizacionExitosa = false

    var body: some View {
        ZStack {
            Color(red: 0.10, green: 0.40, blue: 0.85)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    Text("REPORTEC")
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundColor(.white)

                    HStack {
                        Button {
                            dismiss()
                        } label: {
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
                .padding(.top, 35)
                .padding(.bottom, 20)

                GeometryReader { _ in
                    VStack(spacing: 12) {
                        Image("conejo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 120)
                            .padding(.top, 10)

                        Text("¿Olvidaste tu contraseña?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(red: 0.10, green: 0.25, blue: 0.30))
                            .multilineTextAlignment(.center)

                        Text("Ingresa tu número de control y crea una nueva contraseña")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            field(title: "#Número de control") {
                                TextField("Ej. 22345678", text: $numeroControl)
                                    .keyboardType(.numberPad)
                            }

                            field(title: "Nueva contraseña") {
                                SecureField("Ingresa tu nueva contraseña", text: $nuevaContrasena)
                            }

                            field(title: "Confirmar nueva contraseña") {
                                SecureField("Confirma tu nueva contraseña", text: $confirmarContrasena)
                            }
                        }
                        .padding(.horizontal, 25)

                        Spacer(minLength: 0)

                        Button {
                            actualizarContrasena()
                        } label: {
                            Text("Actualizar contraseña")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(red: 0.12, green: 0.05, blue: 0.85))
                                .cornerRadius(22)
                        }
                        .padding(.horizontal, 25)
                        .padding(.bottom, 16)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(Color(red: 0.86, green: 0.90, blue: 0.93))
                .clipShape(RoundedRectangle(cornerRadius: 45, style: .continuous))
                .padding(.horizontal, 8)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Aviso", isPresented: $mostrarAlerta) {
            Button("OK", role: .cancel) {
                if actualizacionExitosa {
                    dismiss()
                }
            }
        } message: {
            Text(mensajeAlerta)
        }
    }

    @ViewBuilder
    private func field<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(red: 0.10, green: 0.25, blue: 0.30))
            content()
                .padding(.vertical, 11)
                .padding(.horizontal, 12)
                .background(Color.white)
                .cornerRadius(16)
        }
    }

    func actualizarContrasena() {
        guard !numeroControl.isEmpty, !nuevaContrasena.isEmpty, !confirmarContrasena.isEmpty else {
            mensajeAlerta = "Por favor llena todos los campos."
            mostrarAlerta = true
            return
        }

        guard nuevaContrasena == confirmarContrasena else {
            mensajeAlerta = "Las contraseñas no coinciden."
            mostrarAlerta = true
            return
        }

        let exito = DatabaseManager.shared.actualizarContrasena(
            numeroControl: numeroControl,
            nuevaContrasena: nuevaContrasena
        )

        if exito {
            mensajeAlerta = "Contraseña actualizada correctamente."
            actualizacionExitosa = true
        } else {
            mensajeAlerta = "Número de control no encontrado."
            actualizacionExitosa = false
        }
        mostrarAlerta = true
    }
}

#Preview {
    NavigationStack {
        RecuperarContrasenaView()
    }
}
