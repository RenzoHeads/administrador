require 'dotenv'
Dotenv.load

puts "🔧 Configuración Firebase Admin SDK"
puts "=" * 50

# Verificar variables requeridas
required_vars = {
  'FIREBASE_PROJECT_ID' => ENV['FIREBASE_PROJECT_ID'],
  'FIREBASE_PRIVATE_KEY' => ENV['FIREBASE_PRIVATE_KEY'],
  'FIREBASE_CLIENT_EMAIL' => ENV['FIREBASE_CLIENT_EMAIL']
}

puts "\n📋 Verificando variables de entorno:"
all_configured = true

required_vars.each do |var_name, value|
  if value && !value.empty? && value != "tu-proyecto-firebase-id"
    puts "✅ #{var_name}: Configurado"
    if var_name == 'FIREBASE_PRIVATE_KEY'
      puts "   📄 Longitud: #{value.length} caracteres"
      puts "   🔐 Formato: #{value.include?('-----BEGIN') ? 'PEM completo' : 'Solo clave'}"
    elsif var_name == 'FIREBASE_CLIENT_EMAIL'
      puts "   📧 Email: #{value[0..30]}..."
    elsif var_name == 'FIREBASE_PROJECT_ID'
      puts "   🆔 Project ID: #{value}"
    end
  else
    puts "❌ #{var_name}: NO configurado"
    all_configured = false
  end
end

puts "\n" + "=" * 50

if all_configured
  puts "✅ Todas las variables están configuradas"
  puts "\n🧪 Probando inicialización del servicio..."
  
  begin
    require_relative 'services/fcm_admin_service'
    fcm_service = FCMAdminService.new
    puts "✅ Firebase Admin SDK inicializado correctamente"
  rescue => e
    puts "❌ Error inicializando Firebase Admin SDK:"
    puts "   #{e.message}"
  end
else
  puts "❌ Faltan variables por configurar"
  puts "\n📚 Para obtener las credenciales correctas:"
  puts "1. Ve a Firebase Console: https://console.firebase.google.com/"
  puts "2. Selecciona tu proyecto"
  puts "3. Configuración del proyecto (⚙️) > Cuentas de servicio"
  puts "4. Clica en 'Generar nueva clave privada'"
  puts "5. Descarga el archivo JSON"
  puts "6. Extrae los valores y agrégalos al archivo .env:"
  puts ""
  puts "   FIREBASE_PROJECT_ID=valor_de_project_id"
  puts "   FIREBASE_PRIVATE_KEY=valor_de_private_key"
  puts "   FIREBASE_CLIENT_EMAIL=valor_de_client_email"
end

puts "\n🔄 Una vez configurado, reinstala las gemas:"
puts "bundle install"
puts ""
puts "🚀 Y luego ejecuta el servidor:"
puts "ruby main.rb"
