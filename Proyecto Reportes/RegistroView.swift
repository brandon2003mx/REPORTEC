import SwiftUI

struct RegistroView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var numeroControl = ""
    @State private var correo = ""
    @State private var contrasena = ""
    @State private var confirmarContrasena = ""
    
    @State private var mostrarAlerta = false
    @State private var mensajeAlerta = ""
    @State private var registroExitoso = false
    
    var body: some View {
        ZStack {
            Color(red: 0.10, green: 0.08, blue: 0.85)
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
                .padding(.bottom, 35)
                
                VStack(spacing: 25) {
                    
                    Image("conejo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 200)
                        .padding(.top, 30)
                    
                    VStack(spacing: 8) {
                        Text("Registro")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(red: 0.10, green: 0.25, blue: 0.30))
                        
                        Text("Ingresa tus datos para continuar")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 18) {
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("#Número de control")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.10, green: 0.25, blue: 0.30))
                            
                            TextField("Ej. 22345678", text: $numeroControl)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(18)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Correo electrónico")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.10, green: 0.25, blue: 0.30))
                            
                            TextField("Ej. alumno@tecnm.mx", text: $correo)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding()
                                .background(Color.white)
                                .cornerRadius(18)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contraseña")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.10, green: 0.25, blue: 0.30))
                            
                            SecureField("Ingresa tu contraseña", text: $contrasena)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(18)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirmar contraseña")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.10, green: 0.25, blue: 0.30))
                            
                            SecureField("Confirma tu contraseña", text: $confirmarContrasena)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(18)
                        }
                    }
                    .padding(.horizontal, 25)
                    
                    Button {
                        registrar()
                    } label: {
                        Text("Registrarme")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.12, green: 0.05, blue: 0.85))
                            .cornerRadius(22)
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.86, green: 0.90, blue: 0.93))
                .clipShape(RoundedRectangle(cornerRadius: 45, style: .continuous))
                .padding(.horizontal, 8)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Aviso", isPresented: $mostrarAlerta) {
            Button("OK", role: .cancel) {
                if registroExitoso {
                    dismiss()
                }
            }
        } message: {
            Text(mensajeAlerta)
        }
    }
    
    func registrar() {
        let numeroControlLimpio = numeroControl.trimmingCharacters(in: .whitespacesAndNewlines)
        let correoLimpio = correo.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !numeroControlLimpio.isEmpty, !correoLimpio.isEmpty, !contrasena.isEmpty, !confirmarContrasena.isEmpty else {
            mensajeAlerta = "Por favor llena todos los campos."
            mostrarAlerta = true
            return
        }
        
        guard ValidadorCorreo.esValido(correoLimpio) else {
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
