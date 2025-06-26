require 'json'
require 'securerandom'
require_relative '../models/blob' # Asegúrate de tener la clase AzureBlobService definida
require 'concurrent'

# === CONTROLADORES PARA USUARIOS ===

require 'json'
require 'securerandom'
require_relative '../models/blob' # Asegúrate de tener la clase AzureBlobService definida
require_relative '../services/jwt_service'
require 'concurrent'

# === CONTROLADORES PARA USUARIOS ===

# Validar usuario (Login con JWT)
post '/usuario/validar' do
  content_type :json
  
  begin
    # Parsear el cuerpo de la petición
    body = request.body.read
    data = JSON.parse(body)
    
    nombre = data['nombre']
    password = data['contrasena'] || data['password']
    
    # Validar que se proporcionen nombre y contraseña
    unless nombre && password
      return [400, {
        success: false,
        error: 'nombre y contraseña son requeridos',
        message: 'Por favor proporciona nombre y contraseña'
      }.to_json]
    end

    # Buscar usuario por nombre
    usuario = Usuario.where(nombre: nombre).first
    
    unless usuario
      puts "🔒 Intento de login fallido: nombre no encontrado - #{nombre}"
      return [401, {
        success: false,
        error: 'Credenciales inválidas',
        message: 'nombre o contraseña incorrectos'
      }.to_json]
    end

    # Verificar contraseña (sin hash)
    unless usuario.contrasena == password
      puts "🔒 Intento de login fallido: contraseña incorrecta - #{nombre}"
      return [401, {
        success: false,
        error: 'Credenciales inválidas',
        message: 'nombre o contraseña incorrectos'
      }.to_json]
    end

    # Generar JWT token
    payload = {
      user_id: usuario.id,
      email: usuario.email,
      nombre: usuario.nombre
    }
    
    token = JWTService.encode_token(payload)
    
    unless token
      puts "❌ Error generando token JWT para usuario: #{nombre}"
      return [500, {
        success: false,
        error: 'Error interno del servidor',
        message: 'No se pudo generar el token de acceso'
      }.to_json]
    end

    puts "✅ Login exitoso para usuario: #{nombre} (ID: #{usuario.id})"
    
    # Respuesta exitosa
    [200, {
      success: true,
      message: 'Login exitoso',
      user: {
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email
      },
      token: token
    }.to_json]

  rescue JSON::ParserError
    [400, {
      success: false,
      error: 'JSON inválido',
      message: 'El formato de los datos enviados es incorrecto'
    }.to_json]
  rescue => e
    puts "❌ Error en login: #{e.message}"
    puts e.backtrace.join("\n")
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Ocurrió un error procesando tu solicitud'
    }.to_json]
  end
end

# Crear usuario (sin hash de contraseña)
post '/usuario/crear-usuario' do
  content_type :json
  
  begin
    nombre = params[:nombre]
    contrasena = params[:contrasena]
    email = params[:email]

    # Validar que se proporcionen todos los datos requeridos
    unless nombre && contrasena && email
      return [400, {
        success: false,
        error: 'Datos incompletos',
        message: 'Nombre, contraseña y email son requeridos'
      }.to_json]
    end

    # Validar longitud mínima de contraseña
    if contrasena.length < 6
      return [400, {
        success: false,
        error: 'Contraseña muy corta',
        message: 'La contraseña debe tener al menos 6 caracteres'
      }.to_json]
    end

    # Verificar si el nombre de usuario ya existe
    if Usuario.where(nombre: nombre).count > 0
      return [409, {
        success: false,
        error: 'Usuario ya existe',
        message: 'El nombre de usuario ya está en uso'
      }.to_json]
    end

    # Verificar si el email ya existe
    if Usuario.where(email: email).count > 0
      return [409, {
        success: false,
        error: 'Email ya existe',
        message: 'El email ya está registrado'
      }.to_json]
    end

    # Crear el usuario (sin hashear contraseña)
    usuario = Usuario.new(
      nombre: nombre, 
      contrasena: contrasena, 
      email: email
    )
    usuario.save

    puts "✅ Usuario creado exitosamente: #{email} (ID: #{usuario.id})"
    
    [200, {
      success: true,
      message: 'Usuario creado exitosamente',
      user: {
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email
      }
    }.to_json]

  rescue => e
    puts "❌ Error creando usuario: #{e.message}"
    puts e.backtrace.join("\n")
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'No se pudo crear el usuario'
    }.to_json]
  end
end




# Eliminar usuario (requiere autenticación)
delete '/usuario/eliminar/:id' do
  authenticate_jwt!
  content_type :json
  
  begin
    user_id = params[:id].to_i
    
    # Solo permitir que el usuario elimine su propia cuenta
    unless current_user_id == user_id
      return [403, {
        success: false,
        error: 'Acceso denegado',
        message: 'Solo puedes eliminar tu propia cuenta'
      }.to_json]
    end

    usuario = Usuario.first(id: user_id)
    unless usuario
      return [404, {
        success: false,
        error: 'Usuario no encontrado',
        message: 'El usuario especificado no existe'
      }.to_json]
    end

    usuario.destroy
    puts "✅ Usuario eliminado: #{usuario.email} (ID: #{usuario.id})"
    
    [200, {
      success: true,
      message: 'Usuario eliminado correctamente'
    }.to_json]

  rescue => e
    puts "❌ Error eliminando usuario: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al eliminar usuario'
    }.to_json]
  end
end


# Verificar si correo existe (público)
get '/usuario/verificar-correo/:email' do
  content_type :json
  
  begin
    email = params[:email]
    usuario = Usuario.where(email: email).first
    
    if usuario
      [200, {
        success: true,
        exists: true,
        message: 'Correo existe'
      }.to_json]
    else
      [404, {
        success: false,
        exists: false,
        message: 'Correo no existe'
      }.to_json]
    end
  rescue => e
    puts "❌ Error verificando correo: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al verificar correo'
    }.to_json]
  end
end

# Obtener usuario por ID (requiere autenticación)
get '/usuario/:id' do
  authenticate_jwt!
  content_type :json
  
  begin
    user_id = params[:id].to_i
    
    # Solo permitir que el usuario acceda a su propia información
    # o implementar verificación de roles si es necesario
    unless current_user_id == user_id
      return [403, {
        success: false,
        error: 'Acceso denegado',
        message: 'Solo puedes acceder a tu propia información'
      }.to_json]
    end

    usuario = Usuario.first(id: user_id)
    
    unless usuario
      return [404, {
        success: false,
        error: 'Usuario no encontrado',
        message: 'El usuario solicitado no existe'
      }.to_json]
    end

    [200, {
      success: true,
      user: {
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email
        # No incluir la contraseña por seguridad
      }
    }.to_json]

  rescue => e
    puts "❌ Error obteniendo usuario: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'No se pudo obtener la información del usuario'
    }.to_json]
  end
end

# ================================
# ✅ RECUPERAR CONTRASEÑA CON TOKEN
# ================================

# Solicitar recuperación de contraseña
post '/usuario/solicitar-recuperacion' do
  status = 500
  resp = ''
  begin
    data = JSON.parse(request.body.read)
    email = data['email']
    usuario = Usuario.where(email: email).first

    if usuario
      token = SecureRandom.hex(16)
      usuario.update(
        reset_token: token,
        reset_token_expira_en: Time.now + 3600 # 1 hora desde ahora
      )
      
      # Enviar correo con instrucciones
      enviar_correo_recuperacion(email, token)

      status = 200
      resp = 'Se envió un correo con instrucciones para recuperar la contraseña.'
    else
      status = 404
      resp = 'Correo no registrado'
    end
  rescue => e
    resp = 'Error al generar token'
    puts e.message
  end
  status status
  resp
end

# Función para enviar el correo con el enlace de recuperación
def enviar_correo_recuperacion(email, token)
  require 'mail'

  Mail.defaults do
    delivery_method :smtp, {
      address: "smtp.gmail.com",
      port: 587,
      domain: "gmail.com",
      user_name: "meteorocrack978@gmail.com",
      password: "ydwe eihr rxps oeie",
      authentication: :plain,
      enable_starttls_auto: true
    }
  end

  mail = Mail.new do
    from    "Soporte <no-reply@tudominio.com>"
    to      email
    subject "Recuperación de contraseña - TuApp"

    html_part do
      content_type 'text/html; charset=UTF-8'
      body <<-HTML
        <!DOCTYPE html>
        <html>
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <style>
                .code {{
                    font-size: 24px;
                    padding: 15px;
                    background: #f5f5f5;
                    border-radius: 8px;
                    margin: 20px 0;
                    text-align: center;
                    font-family: monospace;
                }}
                .note {{
                    color: #666;
                    margin-top: 20px;
                }}
            </style>
        </head>
        <body>
            <h1>Recuperación de contraseña</h1>
            <p>Usa el siguiente código en la aplicación para restablecer tu contraseña:</p>
            
            <div class="code">#{token}</div>
            
            <p class="note">
                Este código expirará en 1 hora.<br>
                Si no solicitaste este cambio, ignora este mensaje.
            </p>
        </body>
        </html>
      HTML
    end
  end

  mail.deliver!
rescue => e
  puts "Error al enviar correo: #{e.message}"
  raise
end


# Restablecer contraseña con token
put '/usuario/restablecer-contrasena' do
  content_type :json
  
  begin
    data = JSON.parse(request.body.read)
    token = data['reset_token']
    nueva_contrasena = data['contrasena']

    # Validar que se proporcionen todos los datos
    unless token && nueva_contrasena
      return [400, {
        success: false,
        error: 'Datos incompletos',
        message: 'Token y nueva contraseña son requeridos'
      }.to_json]
    end

    # Validar longitud mínima de contraseña  
    if nueva_contrasena.length < 6
      return [400, {
        success: false,
        error: 'Contraseña muy corta',
        message: 'La contraseña debe tener al menos 6 caracteres'
      }.to_json]
    end

    # Buscar usuario por token
    usuario = Usuario.where(reset_token: token).first

    if usuario && usuario.reset_token_expira_en > Time.now
      # Actualizar contraseña sin hashear y limpiar token de recuperación
      usuario.update(
        contrasena: nueva_contrasena,
        reset_token: nil,
        reset_token_expira_en: nil
      )
      
      puts "✅ Contraseña restablecida para usuario: #{usuario.email} (ID: #{usuario.id})"
      
      [200, {
        success: true,
        message: 'Contraseña actualizada correctamente'
      }.to_json]
    else
      [400, {
        success: false,
        error: 'Token inválido o expirado',
        message: 'El token de recuperación no es válido o ha expirado'
      }.to_json]
    end

  rescue JSON::ParserError
    [400, {
      success: false,
      error: 'JSON inválido',
      message: 'El formato de los datos enviados es incorrecto'
    }.to_json]
  rescue => e
    puts "❌ Error al restablecer contraseña: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al restablecer contraseña'
    }.to_json]
  end
end

# ================================Verificar token
get '/usuario/verificar-token/:token' do
  status = 500
  resp = ''
  begin
    token = params[:token]
    usuario = Usuario.where(reset_token: token).first

    if usuario && usuario.reset_token_expira_en > Time.now
      status = 200
      resp = 'Token válido'
    else
      status = 400
      resp = 'Token inválido o expirado'
    end
  rescue => e
    resp = 'Error al verificar token'
    puts e.message
  end
  status status
  resp
end

# Subir foto de perfil (requiere autenticación)
post '/usuario/:id/foto-perfil' do
  authenticate_jwt!
  content_type :json
  
  begin
    user_id = params[:id].to_i
    
    # Solo permitir que el usuario suba su propia foto
    unless current_user_id == user_id
      return [403, {
        success: false,
        error: 'Acceso denegado',
        message: 'Solo puedes actualizar tu propia foto de perfil'
      }.to_json]
    end

    # Verificar que el usuario existe
    usuario = Usuario.first(id: user_id)
    unless usuario
      return [404, {
        success: false,
        error: 'Usuario no encontrado',
        message: 'El usuario especificado no existe'
      }.to_json]
    end

    # Validar que se ha subido un archivo
    unless params[:file]
      return [400, {
        success: false,
        error: 'Archivo requerido',
        message: 'Se requiere un archivo de imagen'
      }.to_json]
    end

    # Validar tipo de archivo (debe ser imagen)
    file_type = determine_file_type(params[:file][:filename])
    unless file_type == 'IMAGEN'
      return [400, {
        success: false,
        error: 'Tipo de archivo inválido',
        message: 'El archivo debe ser una imagen (JPG, PNG, etc.)'
      }.to_json]
    end

    # Procesar el archivo subido
    upload_result = process_file_upload(params)

    if upload_result[:success]
      # Subir al blob de Azure
      blob_result = AzureBlobService.upload_file(
        upload_result[:temp_path],
        upload_result[:filename],
        upload_result[:content_type],
        'perfil',
        usuario.id
      )
      
      # Limpiar el archivo temporal
      File.delete(upload_result[:temp_path]) if File.exist?(upload_result[:temp_path])
      
      if blob_result[:success]
        # Si el usuario ya tenía una foto, eliminarla del blob
        if usuario.imagen_perfil && usuario.imagen_perfil.start_with?('http')
          # Extraer la ruta del blob de la URL anterior (si es posible)
          begin
            uri = URI.parse(usuario.imagen_perfil)
            old_path = uri.path.sub(/^\//, '')
            # Intentar eliminar la imagen anterior (ignoramos errores)
            AzureBlobService.delete_file(old_path) rescue nil
          rescue
            # Si hay error al parsear la URL, continuamos sin eliminar
          end
        end
        
        # Generar URL con SAS para acceso permanente (duración larga)
        # Por ejemplo, una duración de 10 años (valor en minutos)
        duracion_larga = 60 * 24 * 365 * 10 # 10 años en minutos
        sas_result = AzureBlobService.generate_sas_url(blob_result[:path], duracion_larga)
        
        if sas_result[:success]
          # Guardar la URL completa en la base de datos
          usuario.update(imagen_perfil: sas_result[:sas_url])
          
          puts "✅ Foto de perfil actualizada para usuario: #{usuario.email} (ID: #{usuario.id})"
          
          [200, {
            success: true,
            message: 'Foto de perfil actualizada correctamente',
            imagen_perfil: sas_result[:sas_url]
          }.to_json]
        else
          [500, {
            success: false,
            error: 'Error generando URL',
            message: "Error al generar URL de acceso: #{sas_result[:error]}"
          }.to_json]
        end
      else
        [500, {
          success: false,
          error: 'Error subiendo archivo',
          message: "Error al subir imagen a Azure: #{blob_result[:error]}"
        }.to_json]
      end
    else
      [400, {
        success: false,
        error: 'Error procesando archivo',
        message: upload_result[:error]
      }.to_json]
    end
  rescue => e
    puts "❌ Error al subir foto de perfil: #{e.message}"
    puts e.backtrace.join("\n")
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error interno al procesar la solicitud'
    }.to_json]
  end
end

# Obtener URL de la foto de perfil (requiere autenticación)
get '/usuario/:id/foto-perfil' do
  authenticate_jwt!
  content_type :json
  
  begin
    user_id = params[:id].to_i
    
    # Solo permitir que el usuario acceda a su propia foto (o podríamos permitir acceso público)
    unless current_user_id == user_id
      return [403, {
        success: false,
        error: 'Acceso denegado',
        message: 'Solo puedes ver tu propia foto de perfil'
      }.to_json]
    end

    usuario = Usuario.first(id: user_id)

    unless usuario
      return [404, {
        success: false,
        error: 'Usuario no encontrado',
        message: 'El usuario especificado no existe'
      }.to_json]
    end

    if usuario.imagen_perfil && !usuario.imagen_perfil.empty?
      [200, {
        success: true,
        imagen_perfil: usuario.imagen_perfil
      }.to_json]
    else
      [404, {
        success: false,
        error: 'Sin foto de perfil',
        message: 'El usuario no tiene foto de perfil'
      }.to_json]
    end
  rescue => e
    puts "❌ Error al obtener URL de foto de perfil: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al obtener URL de la foto de perfil'
    }.to_json]
  end
end

# Eliminar foto de perfil (requiere autenticación)
delete '/usuario/:id/foto-perfil' do
  authenticate_jwt!
  content_type :json
  
  begin
    user_id = params[:id].to_i
    
    # Solo permitir que el usuario elimine su propia foto
    unless current_user_id == user_id
      return [403, {
        success: false,
        error: 'Acceso denegado',
        message: 'Solo puedes eliminar tu propia foto de perfil'
      }.to_json]
    end

    usuario = Usuario.first(id: user_id)
    
    unless usuario
      return [404, {
        success: false,
        error: 'Usuario no encontrado',
        message: 'El usuario especificado no existe'
      }.to_json]
    end
    
    if usuario.imagen_perfil
      # Eliminar del blob de Azure
      delete_result = AzureBlobService.delete_file(usuario.imagen_perfil)
      
      # Actualizar usuario para eliminar la referencia
      usuario.update(imagen_perfil: nil)
      
      puts "✅ Foto de perfil eliminada para usuario: #{usuario.email} (ID: #{usuario.id})"
      
      [200, {
        success: true,
        message: 'Foto de perfil eliminada correctamente'
      }.to_json]
    else
      [400, {
        success: false,
        error: 'Sin foto de perfil',
        message: 'El usuario no tiene foto de perfil'
      }.to_json]
    end
  rescue => e
    puts "❌ Error al eliminar foto de perfil: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al eliminar foto de perfil'
    }.to_json]
  end
end


# Actualizar nombre de usuario (requiere autenticación)
put '/usuario/actualizar-nombre/:id' do
  authenticate_jwt!
  content_type :json
  
  begin
    user_id = params[:id].to_i
    
    # Solo permitir que el usuario actualice su propio nombre
    unless current_user_id == user_id
      return [403, {
        success: false,
        error: 'Acceso denegado',
        message: 'Solo puedes actualizar tu propio nombre'
      }.to_json]
    end

    data = JSON.parse(request.body.read)
    nuevo_nombre = data['nombre']
    
    # Validar que se proporcione el nuevo nombre
    unless nuevo_nombre && !nuevo_nombre.strip.empty?
      return [400, {
        success: false,
        error: 'Nombre requerido',
        message: 'Debes proporcionar un nombre válido'
      }.to_json]
    end

    nuevo_nombre = nuevo_nombre.strip

    usuario = Usuario.first(id: user_id)
    unless usuario
      return [404, {
        success: false,
        error: 'Usuario no encontrado',
        message: 'El usuario especificado no existe'
      }.to_json]
    end

    # Verificar que el nombre no esté en uso por otro usuario
    if Usuario.where(nombre: nuevo_nombre).exclude(id: user_id).count > 0
      return [409, {
        success: false,
        error: 'Nombre en uso',
        message: 'El nombre de usuario ya está en uso'
      }.to_json]
    end

    # Actualizar el nombre
    usuario.update(nombre: nuevo_nombre)
    
    puts "✅ Nombre actualizado para usuario: #{usuario.email} (ID: #{usuario.id}) - Nuevo nombre: #{nuevo_nombre}"
    
    [200, {
      success: true,
      message: 'Nombre actualizado correctamente',
      user: {
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email
      }
    }.to_json]

  rescue JSON::ParserError
    [400, {
      success: false,
      error: 'JSON inválido',
      message: 'El formato de los datos enviados es incorrecto'
    }.to_json]
  rescue => e
    puts "❌ Error al actualizar nombre de usuario: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al actualizar nombre de usuario'
    }.to_json]
  end
end

# Actualizar correo de usuario (requiere autenticación)
put '/usuario/actualizar-correo/:id' do
  authenticate_jwt!
  content_type :json
  
  begin
    user_id = params[:id].to_i
    
    # Solo permitir que el usuario actualice su propio correo
    unless current_user_id == user_id
      return [403, {
        success: false,
        error: 'Acceso denegado',
        message: 'Solo puedes actualizar tu propio correo'
      }.to_json]
    end

    data = JSON.parse(request.body.read)
    nuevo_correo = data['email']
    
    # Validar que se proporcione el nuevo email
    unless nuevo_correo && !nuevo_correo.strip.empty?
      return [400, {
        success: false,
        error: 'Email requerido',
        message: 'Debes proporcionar un email válido'
      }.to_json]
    end

    nuevo_correo = nuevo_correo.strip.downcase

    # Validar formato de email básico
    unless nuevo_correo.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
      return [400, {
        success: false,
        error: 'Email inválido',
        message: 'El formato del email no es válido'
      }.to_json]
    end

    usuario = Usuario.first(id: user_id)
    unless usuario
      return [404, {
        success: false,
        error: 'Usuario no encontrado',
        message: 'El usuario especificado no existe'
      }.to_json]
    end

    # Verificar que el email no esté en uso por otro usuario
    if Usuario.where(email: nuevo_correo).exclude(id: user_id).count > 0
      return [409, {
        success: false,
        error: 'Email en uso',
        message: 'El email ya está registrado por otro usuario'
      }.to_json]
    end

    # Actualizar el email
    usuario.update(email: nuevo_correo)
    
    puts "✅ Email actualizado para usuario: ID #{usuario.id} - Nuevo email: #{nuevo_correo}"
    
    [200, {
      success: true,
      message: 'Email actualizado correctamente',
      user: {
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email
      }
    }.to_json]

  rescue JSON::ParserError
    [400, {
      success: false,
      error: 'JSON inválido',
      message: 'El formato de los datos enviados es incorrecto'
    }.to_json]
  rescue => e
    puts "❌ Error al actualizar correo de usuario: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al actualizar correo de usuario'
    }.to_json]
  end
end



# Asignar un token FCM a un usuario (requiere autenticación)
post '/usuario/:id/token-fcm' do
  authenticate_jwt!
  content_type :json
  
  begin
    user_id = params[:id].to_i
    
    # Solo permitir que el usuario actualice su propio token FCM
    unless current_user_id == user_id
      return [403, {
        success: false,
        error: 'Acceso denegado',
        message: 'Solo puedes actualizar tu propio token FCM'
      }.to_json]
    end

    # Obtener el usuario por ID
    usuario = Usuario.first(id: user_id)
    unless usuario
      return [404, {
        success: false,
        error: 'Usuario no encontrado',
        message: 'El usuario especificado no existe'
      }.to_json]
    end

    # Obtener el token FCM del cuerpo de la solicitud
    request_data = JSON.parse(request.body.read) rescue {}
    token_fcm = request_data['token_fcm'] || params[:token_fcm]
    
    unless token_fcm && !token_fcm.strip.empty?
      return [400, {
        success: false,
        error: 'Token FCM requerido',
        message: 'Debes proporcionar un token FCM válido'
      }.to_json]
    end

    # Actualizar el token FCM del usuario
    if usuario.respond_to?(:update)
      usuario.update(token_fcm: token_fcm.strip)
    else
      usuario.token_fcm = token_fcm.strip
      usuario.save
    end

    puts "✅ Token FCM actualizado para usuario: #{usuario.email} (ID: #{usuario.id})"

    [200, {
      success: true,
      message: 'Token FCM actualizado correctamente'
    }.to_json]

  rescue JSON::ParserError
    [400, {
      success: false,
      error: 'JSON inválido',
      message: 'El formato de los datos enviados es incorrecto'
    }.to_json]
  rescue => e
    puts "❌ Error al asignar token FCM: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error interno al procesar la solicitud'
    }.to_json]
  end
end


# Precalentamiento del pool de conexiones globales al inicio de la aplicación
DB.fetch("SELECT 1").all  # Precalienta el pool de conexiones cuando inicia la app

# Pre-carga de clases de objetos comunes
DB[:tareas].first  # Force load of Sequel dataset and row classes
DB[:listas].first
DB[:etiquetas].first
DB[:tarea_etiquetas].first

# Cache de datos de referencia (que no cambian frecuentemente)
DATOS_REFERENCIA_CACHE = {
  prioridades: DB[:prioridades].all,
  estados: DB[:estados].all,
  categorias: DB[:categorias].all
}

get '/usuarios/:usuario_id/datos_completos' do
  authenticate_jwt!
  usuario_id = params[:usuario_id]

  pool = Concurrent::FixedThreadPool.new(3)
  resultados = Concurrent::Hash.new

  resultados[:datos_referencia] = DATOS_REFERENCIA_CACHE

  pool.post do
    resultados[:tareas] = DB[:tareas].where(usuario_id: usuario_id).select_all.all
  end

  pool.post do
    resultados[:listas] = DB[:listas].where(usuario_id: usuario_id).all
  end

  pool.post do
    resultados[:etiquetas] = DB[:tarea_etiquetas]
      .join(:etiquetas, id: :etiqueta_id)
      .join(:tareas, Sequel[:tareas][:id] => Sequel[:tarea_etiquetas][:tarea_id])
      .where(Sequel[:tareas][:usuario_id] => usuario_id)
      .select(
        Sequel[:tarea_etiquetas][:tarea_id],
        Sequel[:etiquetas][:id].as(:etiqueta_id),
        Sequel[:etiquetas][:nombre],
        Sequel[:etiquetas][:color]
      ).all
  end

  pool.shutdown
  pool.wait_for_termination # Espera a que todas las tareas terminen
  
  # Organizamos la respuesta
  datos = {
    tareas: resultados[:tareas] || [],
    listas: resultados[:listas] || [],
    etiquetas_por_tarea: [],
    datos_referencia: resultados[:datos_referencia]
  }
  
  # Procesamos las etiquetas por tarea
  etiquetas_por_tarea = {}
  
  if resultados[:etiquetas]
    resultados[:etiquetas].each do |etiqueta|
      tarea_id = etiqueta[:tarea_id]
      etiquetas_por_tarea[tarea_id] ||= []
      
      etiquetas_por_tarea[tarea_id] << {
        id: etiqueta[:etiqueta_id],
        nombre: etiqueta[:nombre],
        color: etiqueta[:color]
      }
    end
  end
  
  # Convertimos a formato de array como esperado
  etiquetas_por_tarea.each do |tarea_id, etiquetas|
    datos[:etiquetas_por_tarea] << {
      tarea_id: tarea_id,
      etiquetas: etiquetas
    }
  end
  

  # Añadir caché con un TTL corto para reducir carga
  cache_control :public, max_age: 60  # 1 minuto de caché
  
  # Usamos oj para serialización más rápida
  json_response = defined?(Oj) ? Oj.dump(datos, mode: :compat) : datos.to_json
  
  [200, json_response]
end


