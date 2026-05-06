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
                Color(red: 0.0, green: 0.3, blue: 0.95)
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    
                    Spacer()
                    
                    Text("REPORTEC")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image("conejo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 200)
                    
                    Text("Bienvenido")
                        .font(.title)
                        .foregroundColor(.white)
                        .bold()
                    
                    Text("Por favor ingresa tus datos")
                        .foregroundColor(.white.opacity(0.9))
                    
                    VStack(spacing: 15) {
                        
                        TextField("#Número de Control", text: $numeroControl)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(15)
                        
                        SecureField("Contraseña", text: $contrasena)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 30)
                    
                    Button {
                        iniciarSesion()
                    } label: {
                        Text("Iniciar Sesión")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.65, green: 0.85, blue: 0.75))
                            .cornerRadius(18)
                    }
                    .padding(.horizontal, 30)
                    
                    NavigationLink(destination: RegistroView()) {
                        Text("Registrarse")
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }
                    
                    NavigationLink(destination: RecuperarContrasenaView()) {
                        Text("¿Olvidaste tu contraseña?")
                            .foregroundColor(.white)
                            .padding(.top, 10)
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
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(18)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
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
            irAlChat = true
        } else {
            mensajeAlerta = "Número de control o contraseña incorrectos."
            mostrarAlerta = true
        }
    }
}

#Preview {
    ContentView()
}
