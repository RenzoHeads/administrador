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
      mensaje: data['mensaje'],
      activado: data['activado'] || true  # Por defecto activado
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
        mensaje: data['mensaje'],
        activado: data.key?('activado') ? data['activado'] : recordatorio.activado
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

# DESACTIVAR TODOS LOS RECORDATORIOS DE UN USUARIO
put '/recordatorios/desactivar-usuario/:usuario_id' do
  authenticate_jwt!
  content_type :json
  
  begin
    usuario_id = params[:usuario_id].to_i
    
    # Verificar que el usuario autenticado puede realizar esta acción
    unless current_user_id == usuario_id
      return [403, {
        success: false,
        error: 'Acceso denegado',
        message: 'Solo puedes modificar tus propios recordatorios'
      }.to_json]
    end
    
    # Desactivar todos los recordatorios del usuario usando Sequel
    tareas_usuario = DB[:tareas].where(usuario_id: usuario_id).select(:id)
    updated_count = DB[:recordatorios].where(tarea_id: tareas_usuario).update(activado: false)
    
    puts "✅ Recordatorios desactivados para usuario #{usuario_id}: #{updated_count} recordatorios"
    
    [200, {
      success: true,
      message: 'Todos los recordatorios han sido desactivados',
      recordatorios_afectados: updated_count
    }.to_json]
  rescue => e
    puts "❌ Error desactivando recordatorios: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al desactivar recordatorios'
    }.to_json]
  end
end

# ACTIVAR TODOS LOS RECORDATORIOS DE UN USUARIO
put '/recordatorios/activar-usuario/:usuario_id' do
  authenticate_jwt!
  content_type :json
  
  begin
    usuario_id = params[:usuario_id].to_i
    
    # Verificar que el usuario autenticado puede realizar esta acción
    unless current_user_id == usuario_id
      return [403, {
        success: false,
        error: 'Acceso denegado',
        message: 'Solo puedes modificar tus propios recordatorios'
      }.to_json]
    end
    
    # Activar todos los recordatorios del usuario usando Sequel
    tareas_usuario = DB[:tareas].where(usuario_id: usuario_id).select(:id)
    updated_count = DB[:recordatorios].where(tarea_id: tareas_usuario).update(activado: true)
    
    puts "✅ Recordatorios activados para usuario #{usuario_id}: #{updated_count} recordatorios"
    
    [200, {
      success: true,
      message: 'Todos los recordatorios han sido activados',
      recordatorios_afectados: updated_count
    }.to_json]
  rescue => e
    puts "❌ Error activando recordatorios: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al activar recordatorios'
    }.to_json]
  end
end

# ACTIVAR RECORDATORIOS DE TAREAS DE PRIORIDAD ALTA PARA UN USUARIO
put '/recordatorios/activar-prioridad-alta/:usuario_id' do
  authenticate_jwt!
  content_type :json
  
  begin
    usuario_id = params[:usuario_id].to_i
    
    # Verificar que el usuario autenticado puede realizar esta acción
    unless current_user_id == usuario_id
      return [403, {
        success: false,
        error: 'Acceso denegado',
        message: 'Solo puedes modificar tus propios recordatorios'
      }.to_json]
    end
    
    # Activar recordatorios de tareas con prioridad_id = 3 usando Sequel
    tareas_prioridad_alta = DB[:tareas]
      .where(usuario_id: usuario_id)
      .where(prioridad_id: 3)
      .select(:id)
    
    updated_count = DB[:recordatorios].where(tarea_id: tareas_prioridad_alta).update(activado: true)
    
    puts "✅ Recordatorios de prioridad alta (ID=3) activados para usuario #{usuario_id}: #{updated_count} recordatorios"
    
    [200, {
      success: true,
      message: 'Recordatorios de tareas con prioridad alta (ID=3) han sido activados',
      recordatorios_afectados: updated_count
    }.to_json]
  rescue => e
    puts "❌ Error activando recordatorios de prioridad alta: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al activar recordatorios de prioridad alta'
    }.to_json]
  end
end

# OBTENER ESTADO DE RECORDATORIOS DE UN USUARIO (activados/desactivados)
get '/recordatorios/estado-usuario/:usuario_id' do
  authenticate_jwt!
  content_type :json
  
  begin
    usuario_id = params[:usuario_id].to_i
    
    # Verificar que el usuario autenticado puede realizar esta acción
    unless current_user_id == usuario_id
      return [403, {
        success: false,
        error: 'Acceso denegado',
        message: 'Solo puedes ver tus propios recordatorios'
      }.to_json]
    end
    
    # Contar recordatorios activados y desactivados usando Sequel
    stats = DB[:recordatorios]
      .join(:tareas, id: :tarea_id)
      .where(Sequel[:tareas][:usuario_id] => usuario_id)
      .group(:activado)
      .select(:activado, Sequel.lit('COUNT(*)').as(:cantidad))
      .all
    
    activados = stats.find { |s| s[:activado] == true }&.fetch(:cantidad, 0) || 0
    desactivados = stats.find { |s| s[:activado] == false }&.fetch(:cantidad, 0) || 0
    
    [200, {
      success: true,
      recordatorios_activados: activados,
      recordatorios_desactivados: desactivados,
      total_recordatorios: activados + desactivados
    }.to_json]
  rescue => e
    puts "❌ Error obteniendo estado de recordatorios: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al obtener estado de recordatorios'
    }.to_json]
  end
end

#Obtener recordatorios por tarea_id (requiere autenticación)
get '/recordatorios/tarea/:tarea_id' do
  authenticate_jwt!
  content_type :json
  
  begin
    recordatorios = Recordatorio.where(tarea_id: params[:tarea_id]).all
    if recordatorios.empty?
      [404, {
        success: false,
        message: 'Sin recordatorios para esta tarea'
      }.to_json]
    else
      [200, {
        success: true,
        recordatorios: recordatorios.map(&:values)
      }.to_json]
    end
  rescue => e
    puts "❌ Error obteniendo recordatorios por tarea: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al obtener recordatorios por tarea'
    }.to_json]
  end
end

#Borrar recordatorios de lista
delete '/recordatorios/eliminar-lista/:lista_id' do
  authenticate_jwt!
  content_type :json
  
  begin
    lista_id = params[:lista_id].to_i
    
    # Verificar que la lista existe
    lista = Lista.first(id: lista_id)
    unless lista
      return [404, {
        success: false,
        error: 'Lista no encontrada',
        message: 'La lista especificada no existe'
      }.to_json]
    end
    
    # Verificar que el usuario sea propietario de la lista
    unless current_user_id == lista.usuario_id
      return [403, {
        success: false,
        error: 'Acceso denegado',
        message: 'No tienes permisos para acceder a esta lista'
      }.to_json]
    end
    
    # Obtener todas las tareas de la lista
    tareas_ids = DB[:tareas].where(lista_id: lista_id).select(:id)
    
    # Eliminar todos los recordatorios de las tareas de esta lista
    recordatorios_eliminados = DB[:recordatorios].where(tarea_id: tareas_ids).delete
    
    puts "✅ Eliminados #{recordatorios_eliminados} recordatorios de la lista #{lista_id} por usuario ID: #{current_user_id}"
    
    [200, {
      success: true,
      message: 'Recordatorios de la lista eliminados exitosamente',
      recordatorios_eliminados: recordatorios_eliminados,
      lista_id: lista_id
    }.to_json]
    
  rescue => e
    puts "❌ Error eliminando recordatorios de lista: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al eliminar recordatorios de la lista'
    }.to_json]
  end
end
