require 'json'
require 'securerandom'

post '/comentarios/crear' do
    data = JSON.parse(request.body.read)
    comentario = Comentario.new(
      tarea_id: data['tarea_id'],
      texto: data['texto']
    )
    comentario.save
    [200, comentario.to_json]
  end

get '/comentarios/:tarea_id' do
    comentarios = Comentario.where(tarea_id: params[:tarea_id]).all
    comentarios.empty? ? [404, 'Sin comentarios'] : [200, comentarios.to_json]
  end

put '/comentarios/actualizar/:id' do
        data = JSON.parse(request.body.read)
        comentario = Comentario.first(id: params[:id])
        if comentario
          comentario.update(
            tarea_id: data['tarea_id'],
            texto: data['texto']
          )
          [200, comentario.to_json]
        else
          [404, 'Comentario no encontrado']
        end
      end
    

delete '/comentarios/eliminar/:id' do
            comentario = Comentario.first(id: params[:id])
            if comentario
              comentario.destroy
              [200, 'Comentario eliminado']
            else
              [404, 'Comentario no encontrado']
            end
          end