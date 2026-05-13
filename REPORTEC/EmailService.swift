import Foundation

// MARK: - Configuracion de Resend
//
// Para activar el envio automatico de correos:
// 1) Crea una cuenta en https://resend.com
// 2) Genera un API Key (re_xxx) en Resend
// 3) Verifica un dominio/remitente y usa un correo valido en `fromEmail`
// 4) Reemplaza los valores "TU_..." de abajo

enum ResendConfig {
    static let apiKey = "re_RJgJqbwt_9MUrGR97arjkf623bHGXrpNe"
    static let fromEmail = "Resend <onboarding@resend.dev>"
    static let endpoint = "https://api.resend.com/emails"
}

// MARK: - Servicio de envio de correo

enum EmailService {

    static var estaConfigurado: Bool {
        ResendConfig.apiKey != "TU_RESEND_API_KEY" &&
        ResendConfig.fromEmail != "TU_FROM_EMAIL"
    }

    enum EmailError: Error, LocalizedError {
        case configurationMissing
        case invalidURL
        case invalidRequestBody
        case networkError(Error)
        case serverError(Int, String?)

        var errorDescription: String? {
            switch self {
            case .configurationMissing:
                return "El servicio de correo no esta configurado. Revisa ResendConfig en EmailService.swift."
            case .invalidURL:
                return "URL del servicio de correo invalida."
            case .invalidRequestBody:
                return "No se pudo construir el cuerpo de la solicitud de correo."
            case .networkError(let error):
                return "Error de red: \(error.localizedDescription)"
            case .serverError(let code, let detalle):
                if let detalle, !detalle.isEmpty {
                    return "Resend respondio con codigo \(code): \(detalle)"
                }
                return "Resend respondio con codigo \(code)."
            }
        }
    }

    /// Envia un correo electronico mediante la API de Resend.
    /// - Parameters:
    ///   - destinatario: Direccion de correo del receptor.
    ///   - asunto: Asunto del mensaje.
    ///   - cuerpo: Texto del mensaje en formato plano.
    ///   - completion: Bloque que se ejecuta en el hilo principal con el resultado.
    static func enviarCorreo(
        destinatario: String,
        asunto: String,
        cuerpo: String,
        completion: @escaping (Result<Void, EmailError>) -> Void
    ) {
        guard estaConfigurado else {
            DispatchQueue.main.async { completion(.failure(.configurationMissing)) }
            return
        }

        guard let url = URL(string: ResendConfig.endpoint) else {
            DispatchQueue.main.async { completion(.failure(.invalidURL)) }
            return
        }

        let payload: [String: Any] = [
            "from": ResendConfig.fromEmail,
            "to": [destinatario],
            "subject": asunto,
            "text": cuerpo
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: payload) else {
            DispatchQueue.main.async { completion(.failure(.invalidRequestBody)) }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(ResendConfig.apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                DispatchQueue.main.async { completion(.failure(.networkError(error))) }
                return
            }

            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard (200...299).contains(statusCode) else {
                let detalle = data.flatMap { String(data: $0, encoding: .utf8) }
                DispatchQueue.main.async { completion(.failure(.serverError(statusCode, detalle))) }
                return
            }

            DispatchQueue.main.async { completion(.success(())) }
        }.resume()
    }
}
