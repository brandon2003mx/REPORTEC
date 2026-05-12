import Foundation

/// Envía correos automáticamente usando la API de Brevo (ex Sendinblue).
///
/// ## Configuración (una sola vez)
/// 1. Crea una cuenta gratuita en https://app.brevo.com (300 correos/día gratis)
/// 2. Ve a "SMTP & API" → "API Keys" y genera una clave.
/// 3. Verifica el correo que usarás como remitente en Brevo → "Senders & IP".
/// 4. Reemplaza los valores de `apiKey` y `correoRemitente` a continuación.
class CorreoManager {

    static let shared = CorreoManager()

    // MARK: - Configuración ← edita estos dos valores

    /// Clave de API obtenida desde app.brevo.com → SMTP & API → API Keys
    private let apiKey = "TU_API_KEY_AQUI"

    /// Correo verificado en Brevo que aparecerá como remitente
    private let correoRemitente = "reportec@tudominio.com"

    private let nombreRemitente = "REPORTEC"

    private init() {}

    // MARK: - Envío de correo

    /// Envía un correo de notificación al estudiante cuando cambia el estatus de su reporte.
    func enviarNotificacionEstatus(
        destinatario: String,
        reporteId: Int,
        nuevoEstatus: String,
        tipo: String,
        ubicacion: String,
        completion: @escaping (Bool, String?) -> Void
    ) {
        let asunto = "Actualización de tu reporte #\(reporteId) – REPORTEC"
        let cuerpo = """
        Hola,

        El estatus de tu reporte ha sido actualizado.

        Folio:      #\(reporteId)
        Tipo:       \(tipo)
        Ubicación:  \(ubicacion)
        Nuevo estatus: \(nuevoEstatus)

        Puedes revisar los detalles en la aplicación REPORTEC.

        — Equipo REPORTEC
        """

        enviarCorreo(destinatario: destinatario, asunto: asunto, cuerpo: cuerpo, completion: completion)
    }

    // MARK: - Llamada a la API

    private func enviarCorreo(
        destinatario: String,
        asunto: String,
        cuerpo: String,
        completion: @escaping (Bool, String?) -> Void
    ) {
        guard let url = URL(string: "https://api.brevo.com/v3/smtp/email") else {
            completion(false, "URL de API inválida.")
            return
        }

        let payload: [String: Any] = [
            "sender": [
                "name": nombreRemitente,
                "email": correoRemitente
            ],
            "to": [
                ["email": destinatario]
            ],
            "subject": asunto,
            "textContent": cuerpo
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(false, "Error al preparar el correo.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, "Error de red: \(error.localizedDescription)")
                    return
                }
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                if (200...299).contains(statusCode) {
                    completion(true, nil)
                } else {
                    completion(false, "Error al enviar el correo (código \(statusCode)).")
                }
            }
        }.resume()
    }
}
