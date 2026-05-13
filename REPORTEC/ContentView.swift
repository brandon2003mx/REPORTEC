import SwiftUI

struct ContentView: View {

    @State private var numeroControl: String = ""
    @State private var contrasena: String = ""

    @State private var irAlChat = false
    @State private var mostrarAlerta = false
    @State private var mensajeAlerta = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.10, green: 0.40, blue: 0.85)
                    .ignoresSafeArea()

                GeometryReader { _ in
                    VStack(spacing: 12) {
                        Spacer(minLength: 12)

                        Text("REPORTEC")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.white)

                        Image("conejo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 140)

                        Text("Bienvenido")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)

                        Text("Por favor ingresa tus datos")
                            .foregroundColor(.white.opacity(0.9))
                            .font(.system(size: 15, weight: .medium))

                        VStack(spacing: 12) {
                            TextField("#Número de Control", text: $numeroControl)
                                .keyboardType(.numberPad)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .background(Color(.systemGray5))
                                .cornerRadius(14)

                            SecureField("Contraseña", text: $contrasena)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .background(Color(.systemGray5))
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 30)

                        Button {
                            iniciarSesion()
                        } label: {
                            Text("Iniciar Sesión")
                                .font(.system(size: 19, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(red: 0.65, green: 0.85, blue: 0.75))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 30)

                        NavigationLink(destination: RegistroView()) {
                            Text("Registrarse")
                                .foregroundColor(.white)
                                .font(.system(size: 15, weight: .semibold))
                        }

                        NavigationLink(destination: RecuperarContrasenaView()) {
                            Text("¿Olvidaste tu contraseña?")
                                .foregroundColor(.white)
                                .font(.system(size: 15, weight: .semibold))
                        }

                        Divider()
                            .background(Color.white.opacity(0.4))
                            .padding(.horizontal, 50)

                        NavigationLink(destination: ResponsableLoginView()) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.badge.key.fill")
                                Text("Acceso Responsable")
                                    .bold()
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 24)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(16)
                        }

                        Spacer(minLength: 12)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationDestination(isPresented: $irAlChat) {
                ChatView()
            }
            .alert("Aviso", isPresented: $mostrarAlerta) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(mensajeAlerta)
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                if numeroControl.isEmpty {
                    numeroControl = UserDefaults.standard.string(forKey: "ultimoNumeroControlRegistrado") ?? ""
                }
            }
        }
    }

    func iniciarSesion() {
        if numeroControl.isEmpty || contrasena.isEmpty {
            mensajeAlerta = "Por favor llena todos los campos."
            mostrarAlerta = true
            return
        }

        let loginCorrecto = DatabaseManager.shared.iniciarSesion(
            numeroControl: numeroControl,
            contrasena: contrasena
        )

        if loginCorrecto {
            SessionManager.shared.iniciarSesion(numeroControl: numeroControl)
            irAlChat = true
        } else {
            SessionManager.shared.cerrarSesion()
            mensajeAlerta = "Número de control o contraseña incorrectos."
            mostrarAlerta = true
        }
    }
}

#Preview {
    ContentView()
}
