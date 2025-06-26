require 'dotenv'
Dotenv.load

# Configurar zona horaria para Windows
ENV['TZ'] = ENV['TZ'] || 'America/Lima'

require 'sinatra'
require 'sequel'
require 'rufus-scheduler'

# configs
set :public_folder, File.dirname(__FILE__) + '/public'
set :views, File.dirname(__FILE__) + '/views'
set :protection, except: :frame_options
set :bind, '0.0.0.0'
set :port, ENV['PORT'] || 4567

# db
require_relative 'configs/database'
require_relative 'configs/models'

# Servicios
require_relative 'services/reminder_scheduler'

# Inicializar scheduler de forma global
scheduler = Rufus::Scheduler.new
reminder_scheduler = ReminderScheduler.new

puts "🚀 Scheduler de recordatorios iniciado"

# Calcular tiempo hasta el próximo minuto completo
current_time = Time.now
seconds_until_next_minute = 60 - current_time.sec
puts "⏰ Servidor iniciado en segundo #{current_time.sec} del minuto"
puts "⏰ Primera revisión en #{seconds_until_next_minute} segundos (al completarse el minuto)"

# Programar la primera revisión al completarse el minuto actual
scheduler.in "#{seconds_until_next_minute}s" do
  puts "� #{Time.now} - Primera verificación de recordatorios al completarse el minuto"
  reminder_scheduler.check_and_send_reminders
  
  # Después de la primera revisión, programar las revisiones cada minuto
  scheduler.every '1m' do
    puts "⏰ #{Time.now} - Verificación de recordatorios (cada minuto)"
    reminder_scheduler.check_and_send_reminders
  end
end

# Tick para mostrar que el scheduler está funcionando
scheduler.every '1m' do
  puts "🕐 Tick #{Time.now}"
end

# Manejar cierre limpio solo cuando se termine la aplicación
Signal.trap('INT') do
  puts "\n🛑 Recibida señal de interrupción, cerrando scheduler..."
  scheduler.shutdown(:wait) if scheduler
  exit
end

# Precargar tablas clave para evitar latencia en primera ejecución
# Warm-up explícito de todas las consultas críticas, de forma secuencial


# end points
Dir[File.join(__dir__, 'routes', '*.rb')].each { |file| require_relative file }
# CORS
before do
  headers 'Access-Control-Allow-Origin' => '*', # Permitir acceso desde cualquier origen
          'Access-Control-Allow-Methods' => ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], # Permitir los métodos HTTP especificados
          'Access-Control-Allow-Headers' => 'Content-Type' # Permitir el encabezado Content-Type
end

options '*' do
  response.headers['Allow'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
  200
end

get '/' do
  erb :home
end

