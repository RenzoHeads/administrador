require 'sequel'

# Datos de conexión a la base de datos PostgreSQL en Azure
username = 'postgres'
password = 'grupoPrograWeb2'
database = 'aulas'
host = 'prograweb-202402-1507-db.postgres.database.azure.com' # Reemplaza con tu host de Azure
port = 5432

# Conexión a la base de datos PostgreSQL en Azure
DB = Sequel.connect(
  adapter: 'postgres',
  user: username,
  password: password,
  host: host,
  database: database,
  port: port
)

Sequel::Model.plugin :json_serializer
