# Usa una imagen base oficial de Ruby 3.3
FROM ruby:3.3

# Instala dependencias necesarias para SQLite y otras gemas
RUN apt-get update -qq && apt-get install -y build-essential libsqlite3-dev

# Crea un directorio de trabajo
WORKDIR /app

# Copia el contenido del proyecto al contenedor
COPY . .




# Instala las gemas
RUN gem install bundler && bundle install
# Expone el puerto típico de Sinatra
EXPOSE 4567

# Comando para iniciar la app
CMD ["ruby", "main.rb"]
