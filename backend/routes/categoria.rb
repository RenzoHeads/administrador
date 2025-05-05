require 'json'
require 'securerandom'

post '/categorias/crear' do
    data = JSON.parse(request.body.read)
    categoria = Categoria.new(
      nombre: data['nombre'],
      color: data['color']
    )
    categoria.save
    [200, categoria.to_json]
  end
  
  get '/categorias' do
    categorias = Categoria.all
    categorias.empty? ? [404, 'Sin categorías'] : [200, categorias.to_json]
  end

  put '/categorias/actualizar/:id' do
    data = JSON.parse(request.body.read)
    categoria = Categoria.first(id: params[:id])
    if categoria
      categoria.update(
        nombre: data['nombre'],
        color: data['color']
      )
      [200, categoria.to_json]
    else
      [404, 'Categoría no encontrada']
    end
  end

  delete '/categorias/eliminar/:id' do
    categoria = Categoria.first(id: params[:id])
    if categoria
      categoria.destroy
      [200, 'Categoría eliminada']
    else
      [404, 'Categoría no encontrada']
    end
  end

##Cargar categoria por id de tarea
get '/categorias/tarea/:tarea_id' do
    tarea = Tarea.first(id: params[:tarea_id])
    if tarea && tarea.categoria
      [200, tarea.categoria.to_json]
    else
      [404, 'Categoría no encontrada']
    end
  end