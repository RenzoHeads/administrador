require 'fcm'
require 'json'

class FCMService
  def initialize
    # La clave del servidor FCM debe estar en una variable de entorno
    @server_key = ENV['FCM_SERVER_KEY']
    @fcm = FCM.new(@server_key) if @server_key
    puts "🔑 FCM inicializado: #{@server_key ? 'Clave configurada' : 'Sin clave'}"
  end

  def send_notification(token, title, body, data = {})
    return { success: false, error: 'FCM no configurado' } unless @fcm

    begin
      # Asegurar que el token sea un string
      token = token.to_s.strip
      return { success: false, error: 'Token FCM vacío' } if token.empty?

      puts "📱 Enviando FCM a token: #{token[0..20]}..."

      options = {
        notification: {
          title: title,
          body: body,
          sound: 'default'
        },
        data: data
      }

      # El FCM gem espera un array de tokens
      response = @fcm.send([token], options)
      
      if response[:status_code] == 200
        { success: true, response: response }
      else
        { success: false, error: "Error FCM: #{response[:body]}" }
      end
    rescue => e
      { success: false, error: "Error enviando notificación: #{e.message}" }
    end
  end

  def send_reminder_notification(recordatorio)
    title = "Recordatorio de Tarea"
    body = recordatorio[:mensaje] || "Tienes una tarea pendiente"
    
    data = {
      tarea_id: recordatorio[:tarea_id].to_s,
      recordatorio_id: recordatorio[:id].to_s,
      type: 'reminder'
    }

    send_notification(recordatorio[:token_fcm], title, body, data)
  end
end
