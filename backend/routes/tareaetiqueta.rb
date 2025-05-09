require 'json'
require 'securerandom'

#Asignar etiqueta a una tarea por id de tarea y id de etiqueta
post '/tareaetiqueta/:tarea_id/:etiqueta_id' do
    # Eliminar esta línea si no usas el body
    # data = JSON.parse(request.body.read)
    
    tareaetiqueta = TareaEtiqueta.new(
        tarea_id: params[:tarea_id],
        etiqueta_id: params[:etiqueta_id]
    )
    tareaetiqueta.save
    [200, tareaetiqueta.to_json]
end


### Obtener etiquetas de una tarea
get '/tareaetiqueta/:tarea_id' do
    tareaetiquetas = TareaEtiqueta.where(tarea_id: params[:tarea_id]).all
    tareaetiquetas.empty? ? [404, 'Sin etiquetas'] : [200, tareaetiquetas.to_json]
end

### Actualizar una etiqueta de una tarea
put '/tareaetiqueta/actualizar/:id' do
    data = JSON.parse(request.body.read)
    tareaetiqueta = TareaEtiqueta.first(id: params[:id])
    if tareaetiqueta
        tareaetiqueta.update(
            tarea_id: data['tarea_id'],
            etiqueta_id: data['etiqueta_id']
        )
        [200, tareaetiqueta.to_json]
    else
        [404, 'Etiqueta no encontrada']
    end
end

## Eliminar una etiqueta de una tarea
delete '/tareaetiqueta/:tarea_id/:etiqueta_id' do
    tareaetiqueta = TareaEtiqueta.first(
        tarea_id: params[:tarea_id],
        etiqueta_id: params[:etiqueta_id]
    )
    if tareaetiqueta
        tareaetiqueta.destroy
        [200, 'Etiqueta eliminada de la tarea']
    else
        [404, 'Relación entre tarea y etiqueta no encontrada']
    end
end