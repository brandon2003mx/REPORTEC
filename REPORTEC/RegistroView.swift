import SwiftUI

struct RegistroView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode

    @State private var numeroControl = ""
    @State private var correo = ""
    @State private var contrasena = ""
    @State private var confirmarContrasena = ""

    @State private var mostrarAlerta = false
    @State private var mensajeAlerta = ""
    @State private var registroExitoso = false

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
                            volverAtras()
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
                            .frame(width: 120, height: 120)
                            .padding(.top, 8)

                        Text("Registro")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(Color(red: 0.10, green: 0.25, blue: 0.30))

                        Text("Ingresa tus datos para continuar")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.gray)

                        VStack(spacing: 12) {
                            field(title: "#Número de control") {
                                TextField("Ej. 22345678", text: $numeroControl)
                                    .keyboardType(.numberPad)
                            }

                            field(title: "Correo electrónico") {
                                TextField("Ej. alumno@tuxtla.tecnm.mx", text: $correo)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            }

                            field(title: "Contraseña") {
                                SecureField("Ingresa tu contraseña", text: $contrasena)
                            }

                            field(title: "Confirmar contraseña") {
                                SecureField("Confirma tu contraseña", text: $confirmarContrasena)
                            }
                        }
                        .padding(.horizontal, 25)

                        Spacer(minLength: 0)

                        Button {
                            registrar()
                        } label: {
                            Text("Registrarme")
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
                if registroExitoso {
                    volverAtras()
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

    private func volverAtras() {
        dismiss()
        presentationMode.wrappedValue.dismiss()
    }

    func registrar() {
        let numeroControlLimpio = numeroControl.trimmingCharacters(in: .whitespacesAndNewlines)
        let correoLimpio = correo.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !numeroControlLimpio.isEmpty, !correoLimpio.isEmpty, !contrasena.isEmpty, !confirmarContrasena.isEmpty else {
            mensajeAlerta = "Por favor llena todos los campos."
            mostrarAlerta = true
            return
        }

        guard EmailValidator.esValido(correoLimpio) else {
            mensajeAlerta = "Ingresa un correo electrónico válido."
            mostrarAlerta = true
            return
        }

        guard contrasena == confirmarContrasena else {
            mensajeAlerta = "Las contraseñas no coinciden."
            mostrarAlerta = true
            return
        }

        let exito = DatabaseManager.shared.registrarUsuario(
            numeroControl: numeroControlLimpio,
            correo: correoLimpio,
            contrasena: contrasena
        )

        if exito {
            UserDefaults.standard.set(numeroControlLimpio, forKey: "ultimoNumeroControlRegistrado")
            mensajeAlerta = "Usuario registrado correctamente."
            registroExitoso = true
        } else {
            mensajeAlerta = "El número de control o correo ya está registrado."
            registroExitoso = false
        }
        mostrarAlerta = true
    }
}

#Preview {
    NavigationStack {
        RegistroView()
    }
}
