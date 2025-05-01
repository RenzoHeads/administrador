require 'json'
require 'securerandom'

#mostrar todas las prioridades
get '/prioridades' do
    prioridades = Prioridad.all
    prioridades.empty? ? [404, 'Sin prioridades'] : [200, prioridades.to_json]
end

#mostrar prioridad por id
get '/prioridades/:id' do
    prioridad = Prioridad.first(id: params[:id])
    if prioridad
      [200, prioridad.to_json]
    else
      [404, 'Prioridad no encontrada']
    end
end