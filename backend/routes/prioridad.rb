require 'json'
require 'securerandom'

# Obtener todas las prioridades (requiere autenticación)
get '/prioridades' do
  authenticate_jwt!
  content_type :json
  
  begin
    prioridades = Prioridad.all
    if prioridades.empty?
      [404, {
        success: false,
        message: 'Sin prioridades'
      }.to_json]
    else
      [200, {
        success: true,
        prioridades: prioridades.map(&:values)
      }.to_json]
    end
  rescue => e
    puts "❌ Error obteniendo prioridades: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al obtener prioridades'
    }.to_json]
  end
end

# Obtener prioridad por ID (requiere autenticación)
get '/prioridades/:id' do
  authenticate_jwt!
  content_type :json
  
  begin
    prioridad = Prioridad.first(id: params[:id])
    if prioridad
      [200, {
        success: true,
        prioridad: prioridad.values
      }.to_json]
    else
      [404, {
        success: false,
        error: 'Prioridad no encontrada',
        message: 'La prioridad especificada no existe'
      }.to_json]
    end
  rescue => e
    puts "❌ Error obteniendo prioridad: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al obtener prioridad'
    }.to_json]
  end
end