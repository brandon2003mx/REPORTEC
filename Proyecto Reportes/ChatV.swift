import SwiftUI

struct ChatView: View {
    
    @State private var numeroIncidencia = ""
    
    var body: some View {
        ZStack {
            Color(red: 0.0, green: 0.3, blue: 0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
               
                Text("REPORTEC")
                    .font(.system(size: 34, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.top, 30)
                    .padding(.bottom, 25)
                
          
                VStack(spacing: 20) {
                    
                    
                    HStack(alignment: .center, spacing: 16) {
            
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Bienvenido")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.black.opacity(0.75))
                            
                            Text("¿Cómo te puedo ayudar?")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black.opacity(0.75))
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 25)
                    .padding(.horizontal, 20)
                    
                
                    HStack {
                        Text("•  Selecciona un número\ndependiendo la\nincidencia que detectas\ny se enviará al área\nencargada")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 290, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color(red: 0.0, green: 0.3, blue: 0.95))
                            )
                        
                        Spacer()
                        
                        Text("16:46 pm")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                    .padding(.horizontal, 20)
                    
                    
                    Image("mascota")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 220)
                        .opacity(0.4)
                    
                    // Segundo globo con opciones
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("1. El clima no funciona (No\n   está encendido)")
                            Text("2. Hace falta sillas")
                            Text("3. Hay una fuga en el baño")
                            Text("4. No hay agua en el edificio")
                            Text("5. No hay electricidad en el\n   edificio")
                        }
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 310, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(red: 0.0, green: 0.3, blue: 0.95))
                        )
                        
                        Spacer()
                        
                        Text("16:47 pm")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Caja de mensaje inferior
                    HStack(spacing: 12) {
                        TextField("Ingresa el número relacionado con la incidencia.....", text: $numeroIncidencia)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                        
                        Button(action: {
                            print("Número enviado: \(numeroIncidencia)")
                        }) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .frame(width: 55, height: 55)
                                .background(Color.black)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 25)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.90, green: 0.90, blue: 0.95))
                .clipShape(
                    RoundedRectangle(cornerRadius: 45, style: .continuous)
                )
                .padding(.horizontal, 8)
            }
        }
    }
}

#Preview {
    ChatView()
}
