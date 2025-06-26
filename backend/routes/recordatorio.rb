require 'json'

# CRUD Endpoints para Recordatorios (Protegidos con JWT)

# CREATE - Crear recordatorio (requiere autenticación)
post '/recordatorios/crear' do
  authenticate_jwt!
  content_type :json
  
  begin
    data = JSON.parse(request.body.read)
    recordatorio = Recordatorio.new(
      tarea_id: data['tarea_id'],
      fecha_hora: data['fecha_hora'],
      token_fcm: data['token_fcm'],
      mensaje: data['mensaje']
    )
    recordatorio.save
    
    puts "✅ Recordatorio creado: Tarea #{recordatorio.tarea_id} por usuario ID: #{current_user_id}"
    
    [200, {
      success: true,
      message: 'Recordatorio creado exitosamente',
      recordatorio: recordatorio.values
    }.to_json]
  rescue => e
    puts "❌ Error creando recordatorio: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al crear recordatorio'
    }.to_json]
  end
end

# READ - Obtener recordatorios por tarea (requiere autenticación)
get '/recordatorios/:tarea_id' do
  authenticate_jwt!
  content_type :json
  
  begin
    recordatorios = Recordatorio.where(tarea_id: params[:tarea_id]).all
    if recordatorios.empty?
      [404, {
        success: false,
        message: 'Sin recordatorios'
      }.to_json]
    else
      [200, {
        success: true,
        recordatorios: recordatorios.map(&:values)
      }.to_json]
    end
  rescue => e
    puts "❌ Error obteniendo recordatorios: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al obtener recordatorios'
    }.to_json]
  end
end

# UPDATE - Actualizar recordatorio (requiere autenticación)
put '/recordatorios/actualizar' do
  authenticate_jwt!
  content_type :json
  
  begin
    data = JSON.parse(request.body.read)
    recordatorio = Recordatorio.first(id: data['id'])
    
    if recordatorio
      recordatorio.update(
        tarea_id: data['tarea_id'],
        fecha_hora: data['fecha_hora'],
        token_fcm: data['token_fcm'],
        mensaje: data['mensaje']
      )
      
      puts "✅ Recordatorio actualizado: ID #{recordatorio.id} por usuario ID: #{current_user_id}"
      
      [200, {
        success: true,
        message: 'Recordatorio actualizado exitosamente',
        recordatorio: recordatorio.values
      }.to_json]
    else
      [404, {
        success: false,
        error: 'Recordatorio no encontrado',
        message: 'El recordatorio especificado no existe'
      }.to_json]
    end
  rescue => e
    puts "❌ Error actualizando recordatorio: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al actualizar recordatorio'
    }.to_json]
  end
end

# DELETE - Eliminar recordatorio (requiere autenticación)
delete '/recordatorios/eliminar/:id' do
  authenticate_jwt!
  content_type :json
  
  begin
    recordatorio = Recordatorio.first(id: params[:id])
    
    if recordatorio
      recordatorio.destroy
      puts "✅ Recordatorio eliminado: ID #{params[:id]} por usuario ID: #{current_user_id}"
      
      [200, {
        success: true,
        message: 'Recordatorio eliminado exitosamente'
      }.to_json]
    else
      [404, {
        success: false,
        error: 'Recordatorio no encontrado',
        message: 'El recordatorio especificado no existe'
      }.to_json]
    end
  rescue => e
    puts "❌ Error eliminando recordatorio: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al eliminar recordatorio'
    }.to_json]
  end
end

