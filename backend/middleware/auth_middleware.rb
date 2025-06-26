require_relative '../services/jwt_service'

# Middleware para validar JWT en rutas protegidas
def authenticate_jwt!
  # Obtener el header Authorization
  auth_header = request.env['HTTP_AUTHORIZATION']
  
  unless auth_header
    puts "🔒 Intento de acceso sin token a #{request.path}"
    halt 401, { 
      success: false, 
      error: 'Token de acceso requerido',
      message: 'Debes iniciar sesión para acceder a este recurso'
    }.to_json
  end

  # Extraer el token (formato: "Bearer <token>")
  token = extract_token_from_header(auth_header)
  
  unless token
    puts "🔒 Formato de token inválido en #{request.path}"
    halt 401, { 
      success: false, 
      error: 'Formato de token inválido',
      message: 'El token debe tener el formato: Bearer <token>'
    }.to_json
  end

  # Validar el token
  decoded_token = JWTService.validate_token(token)
  
  unless decoded_token
    puts "🔒 Token JWT inválido o expirado en #{request.path}"
    halt 401, { 
      success: false, 
      error: 'Token inválido o expirado',
      message: 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.'
    }.to_json
  end

  # Verificar que el usuario existe en la BD
  user_id = decoded_token['user_id'] || decoded_token[:user_id]
  current_user = Usuario.first(id: user_id)
  
  unless current_user
    puts "🔒 Usuario no encontrado para token en #{request.path} (ID: #{user_id})"
    halt 401, { 
      success: false, 
      error: 'Usuario no encontrado',
      message: 'El usuario asociado al token no existe'
    }.to_json
  end

  # Establecer el usuario actual para usar en las rutas
  @current_user = current_user
  @current_user_id = user_id

  puts "✅ Usuario autenticado: #{current_user.email} (ID: #{user_id}) accediendo a #{request.path}"
end

# Helper para extraer el token del header Authorization
def extract_token_from_header(auth_header)
  if auth_header&.start_with?('Bearer ')
    auth_header.split(' ').last
  else
    nil
  end
end

# Helper para obtener el usuario actual (disponible después de authenticate_jwt!)
def current_user
  @current_user
end

# Helper para obtener el ID del usuario actual
def current_user_id
  @current_user_id
end

# Middleware más permisivo para rutas que pueden funcionar con o sin autenticación
def optional_authenticate_jwt!
  auth_header = request.env['HTTP_AUTHORIZATION']
  return unless auth_header

  token = extract_token_from_header(auth_header)
  return unless token

  decoded_token = JWTService.validate_token(token)
  return unless decoded_token

  user_id = decoded_token['user_id'] || decoded_token[:user_id]
  current_user = Usuario.first(id: user_id)
  return unless current_user

  @current_user = current_user
  @current_user_id = user_id
end
