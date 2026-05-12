import Foundation

// MARK: - Configuración de EmailJS
//
// Para activar el envío automático de correos sigue estos pasos:
//
//  1. Crea una cuenta gratuita en https://www.emailjs.com
//  2. En el panel, crea un "Email Service" conectado a tu cuenta de Gmail / Outlook, etc.
//  3. Crea un "Email Template" con las siguientes variables en el cuerpo:
//        {{to_email}}  – dirección del destinatario
//        {{subject}}   – asunto del mensaje
//        {{message}}   – cuerpo del correo
//  4. Copia los identificadores en las tres constantes de abajo.
//
// Mientras los valores sigan siendo los marcadores de posición ("TU_...") el servicio
// mostrará un aviso de configuración pendiente sin afectar el resto de la app.

enum EmailJSConfig {
    static let serviceID  = "TU_SERVICE_ID"   // Ej: "service_abc123"
    static let templateID = "TU_TEMPLATE_ID"  // Ej: "template_xyz456"
    static let publicKey  = "TU_PUBLIC_KEY"   // Ej: "aBcDeFgHiJkLmNoPqRsT"
}

// MARK: - Servicio de envío de correo

enum EmailService {

    enum EmailError: Error, LocalizedError {
        case configurationMissing
        case invalidURL
        case networkError(Error)
        case serverError(Int)

        var errorDescription: String? {
            switch self {
            case .configurationMissing:
                return "El servicio de correo no está configurado. Revisa EmailJSConfig en EmailService.swift."
            case .invalidURL:
                return "URL del servicio de correo inválida."
            case .networkError(let error):
                return "Error de red: \(error.localizedDescription)"
            case .serverError(let code):
                return "El servidor respondió con código \(code)."
            }
        }
    }

    /// Envía un correo electrónico de forma automática mediante la API de EmailJS.
    /// - Parameters:
    ///   - destinatario: Dirección de correo del receptor.
    ///   - asunto: Asunto del mensaje.
    ///   - cuerpo: Texto del mensaje.
    ///   - completion: Bloque que se ejecuta en el hilo principal con el resultado.
    static func enviarCorreo(
        destinatario: String,
        asunto: String,
        cuerpo: String,
        completion: @escaping (Result<Void, EmailError>) -> Void
    ) {
        guard EmailJSConfig.serviceID  != "TU_SERVICE_ID",
              EmailJSConfig.templateID != "TU_TEMPLATE_ID",
              EmailJSConfig.publicKey  != "TU_PUBLIC_KEY" else {
            DispatchQueue.main.async { completion(.failure(.configurationMissing)) }
            return
        }

        guard let url = URL(string: "https://api.emailjs.com/api/v1.0/email/send") else {
            DispatchQueue.main.async { completion(.failure(.invalidURL)) }
            return
        }

        let payload: [String: Any] = [
            "service_id":  EmailJSConfig.serviceID,
            "template_id": EmailJSConfig.templateID,
            "user_id":     EmailJSConfig.publicKey,
            "template_params": [
                "to_email": destinatario,
                "subject":  asunto,
                "message":  cuerpo
            ]
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: payload) else {
            DispatchQueue.main.async { completion(.failure(.invalidURL)) }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.networkError(error))) }
                return
            }

            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 200 {
                DispatchQueue.main.async { completion(.success(())) }
            } else {
                DispatchQueue.main.async { completion(.failure(.serverError(statusCode))) }
            }
        }.resume()
    }
}
