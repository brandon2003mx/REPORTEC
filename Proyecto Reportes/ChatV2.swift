import SwiftUI

struct ChatView2: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var mensaje = ""
    
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
                
                // Tarjeta principal
                VStack(spacing: 18) {
                    
                    HStack(spacing: 16) {
                        Image("robot")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Bienvenido")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.black.opacity(0.7))
                            
                            Text("¿Cómo te puedo ayudar?")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black.opacity(0.7))
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 25)
                    .padding(.horizontal, 20)
                    
                    HStack {
                        Spacer()
                        
                        Text("1")
                            .foregroundColor(.white)
                            .font(.title3.bold())
                            .padding(.vertical, 16)
                            .frame(width: 140)
                            .background(Color(red: 0.12, green: 0.05, blue: 0.85))
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 20)
                    
                    HStack {
                        Spacer()
                        Text("16:46 pm")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                    }
                    
                    HStack {
                        Text("""
Entendido. Vas a reportar: “El clima no funciona (no está encendido)”.
Para generar tu reporte necesito:

1. Ubicación exacta (edificio / salón o área)
2. ¿Qué notas? (no enciende, no enfría, hace ruido, tira agua, etc.)
""")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 320, alignment: .leading)
                        .background(Color(red: 0.12, green: 0.05, blue: 0.85))
                        .cornerRadius(25)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    HStack {
                        Text("16:47 pm")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    Image("mascota")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 130)
                    
                    HStack {
                        Spacer()
                        
                        Text("Edificio C, salón C4, el clima no enciende")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 210, alignment: .leading)
                            .background(Color(red: 0.12, green: 0.05, blue: 0.85))
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 20)
                    
                    HStack {
                        Spacer()
                        Text("16:47 pm")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                    }
                    
                    HStack {
                        Text("""
Listo: Reporte creado con folio #1051.

• Tipo: Clima no funciona
• Ubicación: Edificio A · Salón 204
• Área asignada: Mantenimiento
• Prioridad: Media

Estatus actual: NUEVO (recibido)
Te avisaré por este chat cuando cambie a EN PROCESO o RESUELTO.
""")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 330, alignment: .leading)
                        .background(Color(red: 0.00, green: 0.3, blue: 0.95))
                        .cornerRadius(25)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    HStack {
                        Text("16:47 pm")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        TextField("Mensaje", text: $mensaje)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                        
                        Button(action: {
                            print("Enviar mensaje: \(mensaje)")
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
                    .padding(.bottom, 25)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.86, green: 0.90, blue: 0.93))
                .clipShape(RoundedRectangle(cornerRadius: 45, style: .continuous))
                .padding(.horizontal, 8)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
