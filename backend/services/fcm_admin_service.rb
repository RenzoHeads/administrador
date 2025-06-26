require 'google/apis/fcm_v1'
require 'googleauth'
require 'json'

class FCMAdminService
  def initialize
    @service = Google::Apis::FcmV1::FirebaseCloudMessagingService.new
    
    # Configurar autenticación usando la clave privada desde variable de entorno
    setup_authentication
    
    puts "🔑 Firebase Admin SDK inicializado: #{@credentials ? 'Credenciales configuradas' : 'Sin credenciales'}"
  end

  def send_notification(token, title, body, data = {})
    return { success: false, error: 'Firebase Admin SDK no configurado' } unless @credentials

    begin
      # Asegurar que el token sea un string
      token = token.to_s.strip
      return { success: false, error: 'Token FCM vacío' } if token.empty?

      puts "📱 Enviando FCM Admin SDK a token: #{token[0..20]}..."

      # Construir el mensaje según la API v1 de FCM
      message = Google::Apis::FcmV1::Message.new(
        token: token,
        notification: Google::Apis::FcmV1::Notification.new(
          title: title,
          body: body
        ),
        data: data.transform_values(&:to_s), # Firebase requiere strings
        android: Google::Apis::FcmV1::AndroidConfig.new(
          notification: Google::Apis::FcmV1::AndroidNotification.new(
            sound: 'default'
          )
        ),
        apns: Google::Apis::FcmV1::ApnsConfig.new(
          payload: {
            'aps' => {
              'sound' => 'default'
            }
          }
        )
      )

      # Enviar el mensaje
      project_id = get_project_id_from_credentials
      request = Google::Apis::FcmV1::SendMessageRequest.new(message: message)
      
      response = @service.send_message("projects/#{project_id}", request)
      
      { success: true, response: response.name }
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

  private

  def setup_authentication
    begin
      # Intentar cargar desde archivo JSON primero (más confiable)
      credentials_file = File.join(File.dirname(__FILE__), '..', 'firebase-credentials.json')
      
      if File.exist?(credentials_file)
        puts "🔧 Cargando credenciales desde archivo JSON..."
        @credentials = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: File.open(credentials_file),
          scope: ['https://www.googleapis.com/auth/firebase.messaging']
        )
        @service.authorization = @credentials
        puts "✅ Credenciales cargadas desde archivo JSON exitosamente"
        return
      end

      # Fallback: usar variables de entorno
      puts "🔧 Cargando credenciales desde variables de entorno..."
      private_key_raw = ENV['FIREBASE_PRIVATE_KEY']
      
      unless private_key_raw
        puts "❌ FIREBASE_PRIVATE_KEY no encontrada en variables de entorno"
        return
      end

      # Limpiar y formatear la clave privada correctamente
      private_key = format_private_key(private_key_raw)

      # Crear las credenciales
      credentials_hash = {
        "type" => "service_account",
        "project_id" => ENV['FIREBASE_PROJECT_ID'],
        "private_key_id" => ENV['FIREBASE_PRIVATE_KEY_ID'] || "dummy",
        "private_key" => private_key,
        "client_email" => ENV['FIREBASE_CLIENT_EMAIL'],
        "client_id" => ENV['FIREBASE_CLIENT_ID'] || "dummy",
        "auth_uri" => "https://accounts.google.com/o/oauth2/auth",
        "token_uri" => "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url" => "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url" => "https://www.googleapis.com/robot/v1/metadata/x509/#{ENV['FIREBASE_CLIENT_EMAIL']}"
      }

      # Crear credenciales desde el hash
      @credentials = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(credentials_hash.to_json),
        scope: ['https://www.googleapis.com/auth/firebase.messaging']
      )

      @service.authorization = @credentials
      
    rescue => e
      puts "❌ Error configurando Firebase Admin SDK: #{e.message}"
      @credentials = nil
    end
  end

  def get_project_id_from_credentials
    ENV['FIREBASE_PROJECT_ID'] || 'tu-proyecto-firebase'
  end

  def format_private_key(raw_key)
    # Remover espacios y caracteres extraños
    cleaned_key = raw_key.strip
    
    # Si ya tiene el formato PEM correcto, solo reemplazar \n literales
    if cleaned_key.include?('-----BEGIN PRIVATE KEY-----')
      # Reemplazar \n literales con saltos de línea reales
      formatted_key = cleaned_key.gsub('\\n', "\n")
      puts "🔧 Clave privada ya en formato PEM, aplicando formato correcto"
      return formatted_key
    end
    
    # Si no tiene headers PEM, agregarlos
    puts "🔧 Agregando headers PEM a la clave privada"
    return "-----BEGIN PRIVATE KEY-----\n#{cleaned_key}\n-----END PRIVATE KEY-----"
  end
end
