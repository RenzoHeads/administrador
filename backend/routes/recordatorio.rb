require 'json'
require 'securerandom'


post '/recordatorios/crear' do
    data = JSON.parse(request.body.read)
    recordatorio = Recordatorio.new(
      tarea_id: data['tarea_id'],
      fecha_hora: data['fecha_hora'],
      token_fcm: data['token_fcm'],
      mensaje: data['mensaje']
      
    )
    recordatorio.save
    [200, recordatorio.to_json]
  end

put '/recordatorios/actualizar' do
    data = JSON.parse(request.body.read)
    recordatorio = Recordatorio.first(id: data['id'])
    if recordatorio
      recordatorio.update(
        tarea_id: data['tarea_id'],
        fecha_hora: data['fecha_hora'],
        token_fcm: data['token_fcm'],
        mensaje: data['mensaje'],
        
      )
      [200, recordatorio.to_json]
    else
      [404, 'Recordatorio no encontrado']
    end
  end

delete '/recordatorios/eliminar/:id' do
    recordatorio = Recordatorio.first(id: params[:id])
    if recordatorio
      recordatorio.destroy
      [200, 'Recordatorio eliminado']
    else
      [404, 'Recordatorio no encontrado']
    end
  end

get '/recordatorios/:tarea_id' do
    recordatorios = Recordatorio.where(tarea_id: params[:tarea_id]).all
    recordatorios.empty? ? [404, 'Sin recordatorios'] : [200, recordatorios.to_json]
  end

