import SwiftUI

struct ResponsableLoginView: View {

    @Environment(\.dismiss) var dismiss

    @State private var usuario: String = ""
    @State private var contrasena: String = ""
    @State private var irAGestion = false
    @State private var usuarioLogueado = ""
    @State private var mostrarAlerta = false
    @State private var mensajeAlerta = ""

    var body: some View {
        NavigationStack {
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
                    .padding(.top, 35)
                    .padding(.bottom, 35)

                    // Contenido
                    VStack(spacing: 25) {

                        VStack(spacing: 8) {
                            Image(systemName: "person.badge.key.fill")
                                .font(.system(size: 55))
                                .foregroundColor(Color(red: 0.10, green: 0.08, blue: 0.85))
                                .padding(.top, 30)

                            Text("Acceso Responsable")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(Color(red: 0.10, green: 0.25, blue: 0.30))

                            Text("Ingresa tus credenciales")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)
                        }

                        VStack(spacing: 18) {

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Usuario")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(red: 0.10, green: 0.25, blue: 0.30))

                                TextField("Nombre de usuario", text: $usuario)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(18)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Contraseña")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(red: 0.10, green: 0.25, blue: 0.30))

                                SecureField("Contraseña", text: $contrasena)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(18)
                            }
                        }
                        .padding(.horizontal, 25)

                        Button {
                            iniciarSesion()
                        } label: {
                            Text("Iniciar Sesión")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 0.10, green: 0.40, blue: 0.85))
                                .cornerRadius(22)
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 5)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.86, green: 0.90, blue: 0.93))
                    .clipShape(RoundedRectangle(cornerRadius: 45, style: .continuous))
                    .padding(.horizontal, 8)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $irAGestion) {
                GestionReportesView(areaUsuario: usuarioLogueado)
            }
            .alert("Aviso", isPresented: $mostrarAlerta) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(mensajeAlerta)
            }
        }
    }

    func iniciarSesion() {
        guard !usuario.isEmpty, !contrasena.isEmpty else {
            mensajeAlerta = "Por favor llena todos los campos."
            mostrarAlerta = true
            return
        }

        if let logueado = DatabaseManager.shared.iniciarSesionResponsable(usuario: usuario, contrasena: contrasena) {
            usuarioLogueado = logueado
            irAGestion = true
        } else {
            mensajeAlerta = "Usuario o contraseña incorrectos."
            mostrarAlerta = true
        }
    }
}

#Preview {
    NavigationStack {
        ResponsableLoginView()
    }
}
