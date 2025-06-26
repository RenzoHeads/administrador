require 'jwt'

class JWTService
  # Obtener el secreto desde variables de entorno
  SECRET = ENV['JWT_SECRET'] || 'default_secret_cambiar_en_produccion'
  EXPIRATION = (ENV['JWT_EXPIRATION'] || 604800).to_i # 24 horas por defecto
  ALGORITHM = 'HS256'

  class << self
    # Generar token JWT
    def encode_token(payload)
      # Agregar tiempo de expiración al payload
      payload[:exp] = Time.now.to_i + EXPIRATION
      payload[:iat] = Time.now.to_i # issued at
      
      JWT.encode(payload, SECRET, ALGORITHM)
    rescue => e
      puts "❌ Error generando JWT: #{e.message}"
      nil
    end

    # Decodificar y validar token JWT
    def decode_token(token)
      return nil if token.nil? || token.empty?
      
      decoded = JWT.decode(token, SECRET, true, { algorithm: ALGORITHM })
      decoded.first # Retorna el payload
    rescue JWT::ExpiredSignature
      puts "⏰ Token JWT expirado"
      { error: 'Token expirado' }
    rescue JWT::InvalidSignature
      puts "🔐 Firma JWT inválida"
      { error: 'Token inválido' }
    rescue JWT::DecodeError => e
      puts "💥 Error decodificando JWT: #{e.message}"
      { error: 'Token malformado' }
    rescue => e
      puts "❌ Error inesperado con JWT: #{e.message}"
      { error: 'Error procesando token' }
    end

    # Validar token y retornar información del usuario
    def validate_token(token)
      decoded = decode_token(token)
      return nil if decoded.nil? || decoded.is_a?(Hash) && decoded[:error]
      
      # Verificar que el token contenga user_id
      return nil unless decoded['user_id'] || decoded[:user_id]
      
      decoded
    end

    # Extraer user_id del token
    def get_user_id_from_token(token)
      decoded = validate_token(token)
      return nil unless decoded
      
      decoded['user_id'] || decoded[:user_id]
    end

    # Verificar si un token está próximo a expirar (dentro de 1 hora)
    def token_expiring_soon?(token)
      decoded = decode_token(token)
      return true if decoded.nil? || decoded.is_a?(Hash) && decoded[:error]
      
      exp_time = decoded['exp'] || decoded[:exp]
      return true unless exp_time
      
      # Si expira en menos de 1 hora
      Time.now.to_i > (exp_time - 3600)
    end
  end
end
