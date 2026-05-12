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
                .padding(.bottom, 35)
                
                VStack(spacing: 25) {
                    
                    Image("conejo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 200)
                        .padding(.top, 30)
                    
                    VStack(spacing: 8) {
                        Text("¿Olvidaste tu contraseña?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(red: 0.10, green: 0.25, blue: 0.30))
                            .multilineTextAlignment(.center)
                        
                        Text("Ingresa tu número de control y crea una nueva contraseña")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
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
                            Text("Nueva contraseña")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.10, green: 0.25, blue: 0.30))
                            
                            SecureField("Ingresa tu nueva contraseña", text: $nuevaContrasena)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(18)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirmar nueva contraseña")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.10, green: 0.25, blue: 0.30))
                            
                            SecureField("Confirma tu nueva contraseña", text: $confirmarContrasena)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(18)
                        }
                    }
                    .padding(.horizontal, 25)
                    
                    Button {
                        actualizarContrasena()
                    } label: {
                        Text("Actualizar contraseña")
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
                if actualizacionExitosa {
                    dismiss()
                }
            }
        } message: {
            Text(mensajeAlerta)
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

