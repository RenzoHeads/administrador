require 'dotenv'
Dotenv.load

puts "🔍 Verificando configuración FCM..."
puts ""

# Verificar variable de entorno
fcm_key = ENV['FCM_SERVER_KEY']

if fcm_key
  puts "✅ Variable FCM_SERVER_KEY encontrada"
  puts "📝 Tipo de clave detectado:"
  
  if fcm_key.start_with?('AAAA')
    puts "   🟢 Server Key (Legacy) - ¡CORRECTO para el gem fcm!"
    puts "   📏 Longitud: #{fcm_key.length} caracteres"
  elsif fcm_key.start_with?('-----BEGIN')
    puts "   🟡 Private Key (Admin SDK) - INCORRECTO para el gem fcm"
    puts "   📋 Necesitas la Server Key desde Firebase Console"
  elsif fcm_key.start_with?('MII')
    puts "   🟡 Private Key (Admin SDK) - INCORRECTO para el gem fcm"
    puts "   📋 Necesitas la Server Key desde Firebase Console"
  else
    puts "   🔴 Tipo de clave desconocido"
  end
  
  puts ""
  puts "🔧 Primeros caracteres: #{fcm_key[0..20]}..."
else
  puts "❌ Variable FCM_SERVER_KEY NO encontrada"
  puts "📋 Agregar FCM_SERVER_KEY=tu_clave en .env"
end

puts ""
puts "📚 Para obtener la Server Key correcta:"
puts "1. Ve a Firebase Console: https://console.firebase.google.com/"
puts "2. Selecciona tu proyecto"
puts "3. Configuración del proyecto (⚙️) > Cloud Messaging"
puts "4. Busca 'Clave del servidor' (Server Key)"
puts "5. Copia la clave que empieza con 'AAAA'"
puts ""
puts "⚠️  NOTA: Google está deprecando las Server Keys."
puts "   Para producción, considera migrar a Firebase Admin SDK."
