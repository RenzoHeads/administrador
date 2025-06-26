require 'json'
require 'securerandom'

# Obtener todos los estados (requiere autenticación)
get '/estados' do
  authenticate_jwt!
  content_type :json
  
  begin
    estados = Estado.all
    if estados.empty?
      [404, {
        success: false,
        message: 'Sin estados'
      }.to_json]
    else
      [200, {
        success: true,
        estados: estados.map(&:values)
      }.to_json]
    end
  rescue => e
    puts "❌ Error obteniendo estados: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al obtener estados'
    }.to_json]
  end
end

# Obtener estado por ID (requiere autenticación)
get '/estados/:id' do
  authenticate_jwt!
  content_type :json
  
  begin
    estado = Estado.first(id: params[:id])
    if estado
      [200, {
        success: true,
        estado: estado.values
      }.to_json]
    else
      [404, {
        success: false,
        error: 'Estado no encontrado',
        message: 'El estado especificado no existe'
      }.to_json]
    end
  rescue => e
    puts "❌ Error obteniendo estado: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al obtener estado'
    }.to_json]
  end
end

