require 'json'
require 'securerandom'

# Crear tarea con etiquetas - PROTEGIDO
post '/tareas/crear_con_etiquetas' do
  authenticate_jwt!
  content_type :json
  
  data = JSON.parse(request.body.read, symbolize_names: true)

  DB.transaction do
    nueva_tarea = DB[:tareas].insert(
      usuario_id: data[:usuario_id],
      lista_id: data[:lista_id],
      titulo: data[:titulo],
      descripcion: data[:descripcion],
      fecha_creacion: data[:fecha_creacion],
      fecha_vencimiento: data[:fecha_vencimiento],
      categoria_id: data[:categoria_id],
      estado_id: data[:estado_id],
      prioridad_id: data[:prioridad_id]
    )

    # Asociar etiquetas
    if data[:etiquetas].is_a?(Array)
      data[:etiquetas].each do |etiqueta_id|
        DB[:tarea_etiquetas].insert(
          tarea_id: nueva_tarea,
          etiqueta_id: etiqueta_id
        )
      end
    end

    tarea = DB[:tareas][id: nueva_tarea]
    [200, tarea.to_json]
  end
rescue => e
  status 500
  { error: e.message }.to_json
end

# Actualizar tarea con etiquetas - PROTEGIDO
put '/tareas/:id/actualizar_con_etiquetas' do
  authenticate_jwt!
  content_type :json
  
  tarea_id = params[:id].to_i
  data = JSON.parse(request.body.read, symbolize_names: true)

  DB.transaction do
    # Verificar que exista
    tarea = DB[:tareas][id: tarea_id]
    halt 404, { error: 'Tarea no encontrada' }.to_json unless tarea

    # Actualizar tarea
    DB[:tareas].where(id: tarea_id).update(
      usuario_id: data[:usuario_id],
      lista_id: data[:lista_id],
      titulo: data[:titulo],
      descripcion: data[:descripcion],
      fecha_creacion: data[:fecha_creacion],
      fecha_vencimiento: data[:fecha_vencimiento],
      categoria_id: data[:categoria_id],
      estado_id: data[:estado_id],
      prioridad_id: data[:prioridad_id]
    )

    # Eliminar etiquetas actuales
    DB[:tarea_etiquetas].where(tarea_id: tarea_id).delete

    # Insertar nuevas etiquetas
    if data[:etiquetas].is_a?(Array)
      data[:etiquetas].each do |etiqueta_id|
        DB[:tarea_etiquetas].insert(
          tarea_id: tarea_id,
          etiqueta_id: etiqueta_id
        )
      end
    end

    tarea_actualizada = DB[:tareas][id: tarea_id]
    [200, tarea_actualizada.to_json]
  end
rescue => e
  status 500
  { error: e.message }.to_json
end


# Eliminar tarea - PROTEGIDO
delete '/tareas/eliminar/:id' do
  authenticate_jwt!
  content_type :json
  
  tarea = Tarea.first(id: params[:id])
  if tarea
    tarea.destroy
    { status: 200, mensaje: 'Tarea eliminada' }.to_json
  else
    { status: 404, mensaje: 'Tarea no encontrada' }.to_json
  end
end

# Mostrar tarea por id - PROTEGIDO
get '/tareas/obtener/:id' do
  authenticate_jwt!
  content_type :json
  
  tarea = Tarea.first(id: params[:id])
  if tarea
    [200, tarea.to_json]
  else
    [404, 'Tarea no encontrada']
  end
end

# Obtener todas las tareas de un usuario - PROTEGIDO
get '/tareas/:usuario_id' do
  authenticate_jwt!
  content_type :json
  
  tareas = Tarea.where(usuario_id: params[:usuario_id]).all
  tareas.empty? ? [404, 'Sin tareas'] : [200, tareas.to_json]
end

# Mostrar estado de una tarea - PROTEGIDO
get '/tareas/estado/:id' do
  authenticate_jwt!
  content_type :json
  
  tarea = Tarea.first(id: params[:id])
  if tarea
    estado = Estado.first(id: tarea.estado)
    if estado
      [200, estado.to_json]
    else
      [404, 'Estado no encontrado']
    end
  else
    [404, 'Tarea no encontrada']
  end
end

# Actualizar estado de una tarea por estadoid - PROTEGIDO
put '/tareas/estado/:id' do
  authenticate_jwt!
  content_type :json
  
  data = JSON.parse(request.body.read)
  tarea = Tarea.first(id: params[:id].to_i)

  if tarea
    estado_id = data['estado_id'].to_i
    estado = Estado.first(id: estado_id)
    
    if estado
      tarea.update(estado_id: estado.id)
      [200, tarea.to_json]
    else
      [404, { error: 'Estado no encontrado' }.to_json]
    end
  else
    [404, { error: 'Tarea no encontrada' }.to_json]
  end
end
 




