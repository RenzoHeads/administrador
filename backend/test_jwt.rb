#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'

puts "🧪 Probando implementación JWT..."
puts "=" * 50

BASE_URL = 'http://localhost:4567'

# Helper para hacer requests HTTP
def make_request(method, path, data = nil, headers = {})
  uri = URI("#{BASE_URL}#{path}")
  
  case method
  when :post
    request = Net::HTTP::Post.new(uri)
  when :get
    request = Net::HTTP::Get.new(uri)
  when :put
    request = Net::HTTP::Put.new(uri)
  else
    raise "Método no soportado: #{method}"
  end
  
  # Agregar headers
  headers.each { |k, v| request[k] = v }
  
  # Agregar datos si es POST/PUT
  if data
    if data.is_a?(Hash)
      request.body = data.to_json
      request['Content-Type'] = 'application/json'
    else
      request.body = data
    end
  end
  
  begin
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(request)
    {
      status: response.code.to_i,
      body: response.body,
      headers: response.to_hash
    }
  rescue => e
    { error: e.message }
  end
end

# Test 1: Crear usuario
puts "1️⃣  Creando usuario de prueba..."
response = make_request(
  :post, 
  '/usuario/crear-usuario', 
  'nombre=TestJWT&contrasena=password123&email=testjwt@email.com',
  { 'Content-Type' => 'application/x-www-form-urlencoded' }
)

if response[:status] == 200 || response[:status] == 409
  puts "✅ Usuario creado o ya existe"
else
  puts "❌ Error creando usuario: #{response[:body]}"
end

# Test 2: Login y obtener token
puts "\n2️⃣  Haciendo login para obtener JWT..."
login_data = {
  email: 'testjwt@email.com',
  contrasena: 'password123'
}

response = make_request(:post, '/usuario/validar', login_data)

if response[:status] == 200
  begin
    login_response = JSON.parse(response[:body])
    if login_response['success'] && login_response['token']
      token = login_response['token']
      puts "✅ Login exitoso!"
      puts "🔑 Token obtenido: #{token[0..50]}..."
      
      # Test 3: Acceder a ruta protegida CON token
      puts "\n3️⃣  Accediendo a ruta protegida CON token..."
      response = make_request(
        :get, 
        '/usuario/1', 
        nil, 
        { 'Authorization' => "Bearer #{token}" }
      )
      
      if response[:status] == 200
        puts "✅ Acceso autorizado con JWT"
      else
        puts "❌ Error con token válido: #{response[:body]}"
      end
      
      # Test 4: Acceder a ruta protegida SIN token
      puts "\n4️⃣  Accediendo a ruta protegida SIN token..."
      response = make_request(:get, '/usuario/1')
      
      if response[:status] == 401
        puts "✅ Acceso denegado correctamente (401)"
      else
        puts "❌ Debería dar 401 pero dio: #{response[:status]}"
      end
      
      # Test 5: Acceder con token inválido
      puts "\n5️⃣  Accediendo con token inválido..."
      response = make_request(
        :get, 
        '/usuario/1', 
        nil, 
        { 'Authorization' => 'Bearer token_invalido_123' }
      )
      
      if response[:status] == 401
        puts "✅ Token inválido rechazado correctamente (401)"
      else
        puts "❌ Debería rechazar token inválido"
      end
      
    else
      puts "❌ Login falló: #{login_response['message']}"
    end
  rescue JSON::ParserError
    puts "❌ Respuesta de login no es JSON válido"
  end
else
  puts "❌ Error en login: #{response[:body]}"
end

puts "\n" + "=" * 50
puts "🎉 Pruebas JWT completadas!"
puts "📝 Revisa jwt_test.rest para más pruebas detalladas"
puts "🔧 Configura JWT_SECRET en .env para producción"
