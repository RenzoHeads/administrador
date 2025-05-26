require 'dotenv'
Dotenv.load
require 'sinatra'
require 'sequel'

# configs
set :public_folder, File.dirname(__FILE__) + '/public'
set :views, File.dirname(__FILE__) + '/views'
set :protection, except: :frame_options
set :bind, '0.0.0.0'
set :port, ENV['PORT'] || 3000

# db
require_relative 'configs/database'
require_relative 'configs/models'

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

