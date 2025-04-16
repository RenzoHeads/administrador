require 'json'
require 'securerandom'

# # === CONTROLADORES PARA listas ===

# # Crear lista
post '/listas/crear' do
    data = JSON.parse(request.body.read)
    lista = Lista.new(
      usuario_id: data['usuario_id'],
      nombre: data['nombre'],
      descripcion: data['descripcion'],
      color: data['color']
    )
    lista.save
    [200, lista.to_json]
  end
  
get '/listas/:usuario_id' do
    listas = Lista.where(usuario_id: params[:usuario_id]).all
    listas.empty? ? [404, 'Sin listas'] : [200, listas.to_json]
  end


    # Actualizar lista
put '/listas/actualizar/:id' do
    data = JSON.parse(request.body.read)
    lista = Lista.first(id: params[:id])
    if lista
      lista.update(
        usuario_id: data['usuario_id'],
        nombre: data['nombre'],
        descripcion: data['descripcion'],
        color: data['color']
      )
      [200, lista.to_json]
    else
      [404, 'Lista no encontrada']
    end
  end

    # Eliminar lista
delete '/listas/eliminar/:id' do
    lista = Lista.first(id: params[:id])
    if lista
      lista.destroy
      [200, 'Lista eliminada']
    else
      [404, 'Lista no encontrada']
    end
  end   

  #Obtener cantidad de tareas por lista
get '/listas/cantidad_tareas/:id' do
  content_type :json
  lista = Lista.first(id: params[:id])
  if lista
    cantidad_tareas = Tarea.where(lista_id: lista.id).count
    { cantidad_tareas: cantidad_tareas }.to_json
  else
    status 404
    { error: 'Lista no encontrada' }.to_json
  end
end