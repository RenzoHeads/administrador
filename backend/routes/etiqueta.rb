require 'json'
require 'securerandom'

post '/etiquetas/crear' do
    data = JSON.parse(request.body.read)
    etiqueta = Etiqueta.new(
      nombre: data['nombre'],
      color: data['color']
    )
    etiqueta.save
    [200, etiqueta.to_json]
  end
  

# Actualizar etiqueta
put '/etiquetas/actualizar/:id' do
    data = JSON.parse(request.body.read)
    etiqueta = Etiqueta.first(id: params[:id])
    if etiqueta
      etiqueta.update(
        nombre: data['nombre'],
        color: data['color']
      )
      [200, etiqueta.to_json]
    else
      [404, 'Etiqueta no encontrada']
    end
  end

# Eliminar etiqueta
delete '/etiquetas/eliminar/:id' do
        etiqueta = Etiqueta.first(id: params[:id])
        if etiqueta
          etiqueta.destroy
          [200, 'Etiqueta eliminada']
        else
          [404, 'Etiqueta no encontrada']
        end
      end
  
  ##Verificar si una etiqueta existe por nombre y retornar id
  get '/etiquetas/obtener/:nombre' do
    etiqueta = Etiqueta.first(nombre: params[:nombre])
    if etiqueta
      [200, etiqueta.to_json]
    else
      [404, 'Etiqueta no encontrada']
    end
  end

  ##Obtener etiqueta por id
  get '/etiquetas/:id' do
    etiqueta = Etiqueta.first(id: params[:id])
    if etiqueta
      [200, etiqueta.to_json]
    else
      [404, 'Etiqueta no encontrada']
    end
  end
  

  
  ##Obtener etiquetas completas de una tarea
  get '/tareas/:tarea_id/etiquetas' do
    tareaetiquetas = TareaEtiqueta.where(tarea_id: params[:tarea_id]).all
    if tareaetiquetas.empty?
      [404, 'Sin etiquetas']
    else
      etiquetas = tareaetiquetas.map { |te| Etiqueta.first(id: te.etiqueta_id) }.compact
      [200, etiquetas.to_json]
    end
  end

  ##Obtener etiquetas completas de todas las tareas de un usuario
  get '/usuarios/:usuario_id/etiquetas' do
    tareaetiquetas = TareaEtiqueta.where(usuario_id: params[:usuario_id]).all
    if tareaetiquetas.empty?
      [404, 'Sin etiquetas']
    else
      etiquetas = tareaetiquetas.map { |te| Etiqueta.first(id: te.etiqueta_id) }.compact
      [200, etiquetas.to_json]
    end
  end
  