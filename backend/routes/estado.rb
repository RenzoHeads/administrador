require 'json'
require 'securerandom'

#mostrar todos los estados
get '/estados' do
    estados = Estado.all
    estados.empty? ? [404, 'Sin estados'] : [200, estados.to_json]
end

#mostrar estado por id
get '/estados/:id' do
    estado = Estado.first(id: params[:id])
    if estado
      [200, estado.to_json]
    else
      [404, 'Estado no encontrado']
    end
end

