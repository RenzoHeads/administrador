require 'json'
require 'securerandom'

# Crear etiqueta - PROTEGIDO
post '/etiquetas/crear' do
  authenticate_jwt!
  content_type :json
  
  data = JSON.parse(request.body.read)
  etiqueta = Etiqueta.new(
    nombre: data['nombre'],
    color: data['color']
  )
  etiqueta.save
  [200, etiqueta.to_json]
end

# Actualizar etiqueta - PROTEGIDO
put '/etiquetas/actualizar/:id' do
  authenticate_jwt!
  content_type :json
  
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

# Eliminar etiqueta - PROTEGIDO
delete '/etiquetas/eliminar/:id' do
  authenticate_jwt!
  content_type :json
  
  etiqueta = Etiqueta.first(id: params[:id])
  if etiqueta
    etiqueta.destroy
    [200, 'Etiqueta eliminada']
  else
    [404, 'Etiqueta no encontrada']
  end
end

# Verificar si una etiqueta existe por nombre y retornar id - PROTEGIDO
get '/etiquetas/obtener/:nombre' do
  authenticate_jwt!
  content_type :json
  
  etiqueta = Etiqueta.first(nombre: params[:nombre])
  if etiqueta
    [200, etiqueta.to_json]
  else
    [404, 'Etiqueta no encontrada']
  end
end

# Obtener etiqueta por id - PROTEGIDO
get '/etiquetas/:id' do
  authenticate_jwt!
  content_type :json
  
  etiqueta = Etiqueta.first(id: params[:id])
  if etiqueta
    [200, etiqueta.to_json]
  else
    [404, 'Etiqueta no encontrada']
  end
end
  

  
  