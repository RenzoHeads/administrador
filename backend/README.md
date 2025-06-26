## Instrucciones:

1. Instalar Ruby

https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.2.4-1/rubyinstaller-devkit-3.2.4-1-x64.exe

2.  Instalar bundler

        gem install bundler

3.  Instalar dependencias

        bundler install

4.  Ejecutar la aplicación

        ruby main.rb

## Instrucciones para macOS

1.  Instalar gestor de versiones de Ruby y 'keg-only' de PostgreSQL

        brew install rbenv libpq
        rbenv init
        source ~/.zshrc
        rbenv install 3.2.8

2.  Instalar bundler

        gem install bundler

3.  Configurar bundler (Usar version de ruby especifica, instalar dependencias en carpeta local y usar pg_config de libpq)

        rbenv local 3.2.8
        bundle config set --local path 'vendor/bundle'
        bundle config build.pg --with-pg-config="$(brew --prefix)/opt/libpq/bin/pg_config"

4.  Instalar dependencias

        bundle install

5.  Ejecutar la aplicación

        bundle exec ruby main.rb
