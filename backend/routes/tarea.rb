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
      prioridad: data['prioridad'],
      estado: data['estado'],
      categoria_id: data['categoria_id']
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
        prioridad: data['prioridad'],
        estado: data['estado'],
        categoria_id: data['categoria_id']
      )
      [200, tarea.to_json]
    else
      [404, 'Tarea no encontrada']
    end
end

# Eliminar tarea (Se debe usar DELETE)
delete '/tareas/eliminar/:id' do
    tarea = Tarea.first(id: params[:id])
    if tarea
      tarea.destroy
      [200, 'Tarea eliminada']
    else
      [404, 'Tarea no encontrada']
    end
end

#Mostrar todos los estadsos de las tareas
get '/tareas/emociones' do
  content_type :json
  estados = DB.fetch("SELECT unnest(enum_range(NULL::estado_enum)) AS estado").map { |row| row[:estado] }
  estados.to_json
end

#Mostrar todas las prioridades de las tareas
get '/tareas/prioridades' do
  content_type :json
  prioridades = DB.fetch("SELECT unnest(enum_range(NULL::prioridad_enum)) AS prioridad").map { |row| row[:prioridad] }
  prioridades.to_json
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

#mostrar tareas de inician hoy de un usuario
get '/tareas/hoy/:usuario_id' do
  fecha = Date.today
  inicio_dia = Time.new(fecha.year, fecha.month, fecha.day, 0, 0, 0)
  fin_dia = Time.new(fecha.year, fecha.month, fecha.day, 23, 59, 59)

  tareas = Tarea.where(
    usuario_id: params[:usuario_id],
    fecha_vencimiento: inicio_dia..fin_dia
  ).all

  tareas.empty? ? [404, 'Sin tareas'] : [200, tareas.to_json]
end





