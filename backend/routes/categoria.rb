require 'json'
require 'securerandom'

# Crear categoría (requiere autenticación)
post '/categorias/crear' do
  authenticate_jwt!
  content_type :json
  
  begin
    data = JSON.parse(request.body.read)
    categoria = Categoria.new(
      nombre: data['nombre'],
      color: data['color']
    )
    categoria.save
    
    puts "✅ Categoría creada: #{categoria.nombre} por usuario ID: #{current_user_id}"
    
    [200, {
      success: true,
      message: 'Categoría creada exitosamente',
      categoria: categoria.values
    }.to_json]
  rescue => e
    puts "❌ Error creando categoría: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al crear categoría'
    }.to_json]
  end
end

# Obtener todas las categorías (requiere autenticación)
get '/categorias' do
  authenticate_jwt!
  content_type :json
  
  begin
    categorias = Categoria.all
    if categorias.empty?
      [404, {
        success: false,
        message: 'Sin categorías'
      }.to_json]
    else
      [200, {
        success: true,
        categorias: categorias.map(&:values)
      }.to_json]
    end
  rescue => e
    puts "❌ Error obteniendo categorías: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al obtener categorías'
    }.to_json]
  end
end

# Actualizar categoría (requiere autenticación)
put '/categorias/actualizar/:id' do
  authenticate_jwt!
  content_type :json
  
  begin
    data = JSON.parse(request.body.read)
    categoria = Categoria.first(id: params[:id])
    
    if categoria
      categoria.update(
        nombre: data['nombre'],
        color: data['color']
      )
      
      puts "✅ Categoría actualizada: #{categoria.nombre} por usuario ID: #{current_user_id}"
      
      [200, {
        success: true,
        message: 'Categoría actualizada exitosamente',
        categoria: categoria.values
      }.to_json]
    else
      [404, {
        success: false,
        error: 'Categoría no encontrada',
        message: 'La categoría especificada no existe'
      }.to_json]
    end
  rescue => e
    puts "❌ Error actualizando categoría: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al actualizar categoría'
    }.to_json]
  end
end

# Eliminar categoría (requiere autenticación)
delete '/categorias/eliminar/:id' do
  authenticate_jwt!
  content_type :json
  
  begin
    categoria = Categoria.first(id: params[:id])
    
    if categoria
      categoria.destroy
      puts "✅ Categoría eliminada: #{categoria.nombre} por usuario ID: #{current_user_id}"
      
      [200, {
        success: true,
        message: 'Categoría eliminada exitosamente'
      }.to_json]
    else
      [404, {
        success: false,
        error: 'Categoría no encontrada',
        message: 'La categoría especificada no existe'
      }.to_json]
    end
  rescue => e
    puts "❌ Error eliminando categoría: #{e.message}"
    [500, {
      success: false,
      error: 'Error interno del servidor',
      message: 'Error al eliminar categoría'
    }.to_json]
  end
end

