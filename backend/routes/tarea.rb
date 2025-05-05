require 'json'
require 'securerandom'

# Crear tarea (POST está bien aquí)
post '/tareas/crear' do
    data = JSON.parse(request.body.read)
    tarea = Tarea.new(
      usuario_id: data['usuario_id'],
      lista_id: data['lista_id'],
      titulo: data['titulo'],
      descripcion: data['descripcion'],
      fecha_creacion: data['fecha_creacion'],
      fecha_vencimiento: data['fecha_vencimiento'],
      categoria_id: data['categoria_id'],
      estado_id: data['estado_id'],
      prioridad_id: data['prioridad_id']
    )
    tarea.save
    [200, tarea.to_json]
end

# Actualizar tarea (Se debe usar PUT)
put '/tareas/actualizar/:id' do
    data = JSON.parse(request.body.read)
    tarea = Tarea.first(id: params[:id])
    if tarea
      tarea.update(
          usuario_id: data['usuario_id'],
          lista_id: data['lista_id'],
          titulo: data['titulo'],
          descripcion: data['descripcion'],
          fecha_creacion: data['fecha_creacion'],
          fecha_vencimiento: data['fecha_vencimiento'], 
          categoria_id: data['categoria_id'],
          estado_id: data['estado_id'],
          prioridad_id: data['prioridad_id']
        )
      [200, tarea.to_json]
    else
      [404, 'Tarea no encontrada']
    end
end

delete '/tareas/eliminar/:id' do
  content_type :json  # Establecer el tipo de contenido como JSON
  tarea = Tarea.first(id: params[:id])
  if tarea
    tarea.destroy
    { status: 200, mensaje: 'Tarea eliminada' }.to_json  # Devolver un objeto JSON
  else
    { status: 404, mensaje: 'Tarea no encontrada' }.to_json  # Devolver un objeto JSON
  end
end

# Obtener tareas por usuario (GET está bien)
get '/tareas/:usuario_id' do
    tareas = Tarea.where(usuario_id: params[:usuario_id]).all
    tareas.empty? ? [404, 'Sin tareas'] : [200, tareas.to_json]
end

# Obtener tareas por lista (GET está bien)
get '/tareas/lista/:lista_id' do
    tareas = Tarea.where(lista_id: params[:lista_id]).all
    tareas.empty? ? [404, 'Sin tareas'] : [200, tareas.to_json]
end

#Obtener tareas por etiqueta (GET está bien)
get '/tareas/etiqueta/:etiqueta_id' do
    tareas = TareaEtiqueta.where(etiqueta_id: params[:etiqueta_id]).all
    tareas.empty? ? [404, 'Sin tareas'] : [200, tareas.to_json]
end

#Mostrar tarea por id
get '/tareas/obtener/:id' do
    tarea = Tarea.first(id: params[:id])
    if tarea
      [200, tarea.to_json]
    else
      [404, 'Tarea no encontrada']
    end
end

get '/tareas/hoy/:usuario_id' do
  fecha = Date.today
  inicio_dia = Time.new(fecha.year, fecha.month, fecha.day, 0, 0, 0)
  fin_dia = Time.new(fecha.year, fecha.month, fecha.day, 23, 59, 59)

  tareas = Tarea.where(
    usuario_id: params[:usuario_id],
    fecha_creacion: inicio_dia..fin_dia
  )

  tareas.empty? ? [404, 'Sin tareas'] : [200, tareas.to_json]
end



#mostrar estado de una tarea
get '/tareas/estado/:id' do
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

#actualizar estado de una tarea por estadoid
put '/tareas/estado/:id' do
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






