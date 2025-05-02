require 'json'
require 'securerandom'
require_relative '../models/blob' # Asegúrate de tener la clase AzureBlobService definida

# === CONTROLADORES PARA USUARIOS ===

# Validar usuario
post '/usuario/validar' do
  status = 500
  resp = ''
  body = request.body.read
  data = JSON.parse(body)
  usuario = data['nombre']
  contrasena = data['contrasena']

  begin
    record = Usuario.where(nombre: usuario, contrasena: contrasena).select(:id).first
    if record
      resp = { id: record.id }.to_json
      status = 200
    else
      status = 404
      resp = 'Usuario y/o contraseña no válidos'
    end
  rescue => e
    status = 500
    resp = 'Error al validar usuario'
    puts e.message
  end
  status status
  resp
end

# Crear usuario
post '/usuario/crear-usuario' do
  status = 500
  resp = ''
  nombre = params[:nombre]
  contrasena = params[:contrasena]
  email = params[:email]

  begin
    if Usuario.where(nombre: nombre).count == 0
      usuario = Usuario.new(nombre: nombre, contrasena: contrasena, email: email)
      usuario.save
      resp = 'Usuario creado exitosamente'
      status = 200
    else
      status = 409
      resp = 'Usuario ya en uso'
    end
  rescue => e
    resp = 'Error al crear usuario'
    puts e.message
  end
  status status
  resp
end

# Obtener todos los usuarios
get '/usuarios' do
  status = 500
  resp = ''
  begin
    usuarios = Usuario.all
    if usuarios.any?
      status = 200
      resp = usuarios.to_json
    else
      status = 404
      resp = 'No hay usuarios registrados'
    end
  rescue => e
    resp = 'Error al obtener usuarios'
    puts e.message
  end
  status status
  resp
end

# Actualizar usuario
put '/usuario/actualizar/:id' do
  status = 500
  resp = ''
  begin
    data = JSON.parse(request.body.read)
    usuario = Usuario.first(id: params[:id])
    if usuario
      usuario.update(
        nombre: data['nombre'],
        contrasena: data['contrasena'],
        email: data['email'],
        imagen: data['imagen_perfil'] # si has añadido imagen de perfil
      )
      resp = usuario.to_json
      status = 200
    else
      status = 404
      resp = 'Usuario no encontrado'
    end
  rescue => e
    resp = 'Error al actualizar usuario'
    puts e.message
  end
  status status
  resp
end

# Eliminar usuario
delete '/usuario/eliminar/:id' do
  status = 500
  resp = ''
  begin
    usuario = Usuario.first(id: params[:id])
    if usuario
      usuario.destroy
      resp = 'Usuario eliminado'
      status = 200
    else
      status = 404
      resp = 'Usuario no encontrado'
    end
  rescue => e
    resp = 'Error al eliminar usuario'
    puts e.message
  end
  status status
  resp
end


# Verificar si correo existe
get '/usuario/verificar-correo/:email' do
  status = 500
  resp = ''
  begin
    usuario = Usuario.where(email: params[:email]).first
    if usuario
      resp = 'Correo existe'
      status = 200
    else
      status = 404
      resp = 'Correo no existe'
    end
  rescue => e
    resp = 'Error al verificar correo'
    puts e.message
  end
  status status
  resp
end

# Obtener usuario por ID
get '/usuario/:id' do
  status = 500
  resp = ''
  begin
    usuario = Usuario.first(id: params[:id])
    if usuario
      resp = usuario.to_json
      status = 200
    else
      status = 404
      resp = 'Usuario no encontrado'
    end
  rescue => e
    resp = 'Error al obtener usuario'
    puts e.message
  end
  status status
  resp
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
  status = 500
  resp = ''
  begin
    data = JSON.parse(request.body.read)
    token = data['reset_token']
    nueva_contrasena = data['contrasena']

    usuario = Usuario.where(reset_token: token).first

    if usuario && usuario.reset_token_expira_en > Time.now
      
      
      usuario.update(
        contrasena: nueva_contrasena,
        reset_token: nil,
        reset_token_expira_en: nil
      )
      status = 200
      resp = 'Contraseña actualizada correctamente'
    else
      status = 400
      resp = 'Token inválido o expirado'
    end
  rescue => e
    resp = 'Error al restablecer contraseña'
    puts e.message
  end
  status status
  resp
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

# Subir foto de perfil
post '/usuario/:id/foto-perfil' do
  begin
    # Verificar que el usuario existe
    usuario = Usuario.first(id: params[:id])
    unless usuario
      status 404
      return { error: 'Usuario no encontrado' }.to_json
    end
    
    # Validar que se ha subido un archivo
    unless params[:file]
      status 400
      return { error: 'Se requiere un archivo de imagen' }.to_json
    end
    
    # Validar tipo de archivo (debe ser imagen)
    file_type = determine_file_type(params[:file][:filename])
    unless file_type == 'IMAGEN'
      status 400
      return { error: 'El archivo debe ser una imagen (JPG, PNG, etc.)' }.to_json
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
        if usuario.imagen_perfil
          # Intentar eliminar la imagen anterior (ignoramos errores)
          AzureBlobService.delete_file(usuario.imagen_perfil) rescue nil
        end
        
        # Actualizar el campo de imagen_perfil con la nueva ruta
        usuario.update(imagen_perfil: blob_result[:path])
        
        # Generar URL con SAS para acceso temporal
        sas_result = AzureBlobService.generate_sas_url(blob_result[:path])
        
        status 200
        return {
          message: 'Foto de perfil actualizada correctamente',
          imagen_perfil: blob_result[:path],
          url: sas_result[:success] ? sas_result[:sas_url] : blob_result[:url]
        }.to_json
      else
        status 500
        return { error: "Error al subir imagen a Azure: #{blob_result[:error]}" }.to_json
      end
    else
      status 400
      return { error: upload_result[:error] }.to_json
    end
  rescue => e
    puts "Error al subir foto de perfil: #{e.message}"
    puts e.backtrace.join("\n")
    status 500
    return { error: 'Error interno al procesar la solicitud' }.to_json
  end
end

# Eliminar foto de perfil
delete '/usuario/:id/foto-perfil' do
  begin
    usuario = Usuario.first(id: params[:id])
    
    unless usuario
      status 404
      return { error: 'Usuario no encontrado' }.to_json
    end
    
    if usuario.imagen_perfil
      # Eliminar del blob de Azure
      delete_result = AzureBlobService.delete_file(usuario.imagen_perfil)
      
      # Actualizar usuario para eliminar la referencia
      usuario.update(imagen_perfil: nil)
      
      status 200
      return { message: 'Foto de perfil eliminada correctamente' }.to_json
    else
      status 400
      return { error: 'El usuario no tiene foto de perfil' }.to_json
    end
  rescue => e
    puts "Error al eliminar foto de perfil: #{e.message}"
    status 500
    return { error: 'Error al eliminar foto de perfil' }.to_json
  end
end

# Obtener URL de la foto de perfil
get '/usuario/:id/foto-perfil' do
  begin
    usuario = Usuario.first(id: params[:id])
    
    unless usuario
      status 404
      return { error: 'Usuario no encontrado' }.to_json
    end
    
    if usuario.imagen_perfil
      # Generar URL con SAS para acceso temporal
      expira_en = params[:expira_en]&.to_i || 60 # Minutos
      sas_result = AzureBlobService.generate_sas_url(usuario.imagen_perfil, expira_en)
      
      if sas_result[:success]
        status 200
        return {
          imagen_perfil: usuario.imagen_perfil,
          url: sas_result[:sas_url],
          expira_en: sas_result[:expiry_time]
        }.to_json
      else
        status 500
        return { error: "Error al generar URL: #{sas_result[:error]}" }.to_json
      end
    else
      status 404
      return { error: 'El usuario no tiene foto de perfil' }.to_json
    end
  rescue => e
    puts "Error al obtener URL de foto de perfil: #{e.message}"
    status 500
    return { error: 'Error al generar URL de acceso' }.to_json
  end
end


#Actualizar nombre de usuario que no exista
put '/usuario/actualizar-nombre/:id' do
  status = 500
  resp = ''
  begin
    data = JSON.parse(request.body.read)
    nuevo_nombre = data['nombre']
    usuario = Usuario.first(id: params[:id])
    if usuario
      if Usuario.where(nombre: nuevo_nombre).count == 0
        usuario.update(
          nombre: nuevo_nombre
        )
        resp = usuario.to_json
        status = 200
      else
        status = 409
        resp = 'Nombre de usuario ya en uso'
      end
    else
      status = 404
      resp = 'Usuario no encontrado'
    end
  rescue => e
    resp = 'Error al actualizar nombre de usuario'
    puts e.message
  end
  status status
  resp
end


#Actualizar correo de usuario que no exista 
put '/usuario/actualizar-correo/:id' do
  status = 500
  resp = ''
  begin
    data = JSON.parse(request.body.read)
    nuevo_correo = data['email']
    usuario = Usuario.first(id: params[:id])
    if usuario
      if Usuario.where(email: nuevo_correo).count == 0
        usuario.update(
          email: nuevo_correo
        )
        resp = usuario.to_json
        status = 200
      else
        status = 409
        resp = 'Correo ya en uso'
      end
    else
      status = 404
      resp = 'Usuario no encontrado'
    end
  rescue => e
    resp = 'Error al actualizar correo de usuario'
    puts e.message
  end
  status status
  resp
end