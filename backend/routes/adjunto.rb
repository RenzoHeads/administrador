require 'json'
require 'securerandom'
require_relative '../models/blob'

# === CONTROLADORES PARA ADJUNTOS ===

# Subir adjunto para una tarea
post '/adjuntos/subir' do
    begin
      # Validar parámetros
      unless params[:tarea_id] && params[:file]
        return [400, { error: 'Se requiere tarea_id y un archivo' }.to_json]
      end
      
      # Procesar el archivo subido
      upload_result = process_file_upload(params)
      
      if upload_result[:success]
        # Determinar el tipo de archivo
        file_type = determine_file_type(upload_result[:filename])
        
        # Subir al blob de Azure
        blob_result = AzureBlobService.upload_file(
          upload_result[:temp_path],
          upload_result[:filename],
          upload_result[:content_type],
          'adjuntos',
          params[:tarea_id]
        )
        
        # Limpiar el archivo temporal
        File.delete(upload_result[:temp_path]) if File.exist?(upload_result[:temp_path])
        
        if blob_result[:success]
          # Guardar en la base de datos
          adjunto = Adjunto.new(
            tarea_id: params[:tarea_id],
            nombre: upload_result[:filename],
            ruta: blob_result[:path],
            tipo: file_type
          )
          
          adjunto.save
          
          # Devolver respuesta exitosa
          content_type :json
          status 200
          return {
            message: 'Adjunto subido correctamente',
            adjunto: {
              id: adjunto.id,
              nombre: adjunto.nombre,
              ruta: adjunto.ruta,
              tipo: adjunto.tipo,
              url: blob_result[:url]
            }
          }.to_json
        else
          status 500
          return { error: "Error al subir archivo a Azure: #{blob_result[:error]}" }.to_json
        end
      else
        status 400
        return { error: upload_result[:error] }.to_json
      end
    rescue => e
      puts "Error al subir adjunto: #{e.message}"
      puts e.backtrace.join("\n")
      status 500
      return { error: 'Error interno al procesar la solicitud' }.to_json
    end
  end
  
  # Crear adjunto (con ruta existente)
  post '/adjuntos/crear' do
    begin
      data = JSON.parse(request.body.read)
      
      # Validar datos mínimos
      unless data['tarea_id'] && data['nombre'] && data['ruta'] && data['tipo']
        return [400, { error: 'Faltan datos requeridos' }.to_json]
      end
      
      adjunto = Adjunto.new(
        tarea_id: data['tarea_id'],
        nombre: data['nombre'],
        ruta: data['ruta'],
        tipo: data['tipo'] # Debe ser un valor del enum: 'IMAGEN', 'DOCUMENTO', etc.
      )
      
      adjunto.save
      
      content_type :json
      status 200
      return { 
        message: 'Adjunto creado correctamente',
        adjunto: adjunto 
      }.to_json
    rescue => e
      puts "Error al crear adjunto: #{e.message}"
      status 500
      return { error: 'Error al crear adjunto' }.to_json
    end
  end
  
  # Obtener adjuntos por tarea
  get '/adjuntos/tarea/:tarea_id' do
    begin
      adjuntos = Adjunto.where(tarea_id: params[:tarea_id]).all
      
      # Si se solicitan URLs con SAS
      if params[:incluir_urls] == 'true'
        adjuntos_con_urls = adjuntos.map do |adjunto|
          sas_result = AzureBlobService.generate_sas_url(adjunto.ruta)
          adjunto_data = adjunto.to_hash
          adjunto_data[:url] = sas_result[:success] ? sas_result[:sas_url] : nil
          adjunto_data
        end
        
        content_type :json
        adjuntos.empty? ? [404, { error: 'No hay adjuntos' }.to_json] : [200, adjuntos_con_urls.to_json]
      else
        content_type :json
        adjuntos.empty? ? [404, { error: 'No hay adjuntos' }.to_json] : [200, adjuntos.to_json]
      end
    rescue => e
      puts "Error al obtener adjuntos: #{e.message}"
      status 500
      return { error: 'Error al obtener adjuntos' }.to_json
    end
  end
  
  # Eliminar adjunto
  delete '/adjuntos/eliminar/:id' do
    begin
      adjunto = Adjunto.first(id: params[:id])
      
      if adjunto
        # Eliminar del blob de Azure
        delete_result = AzureBlobService.delete_file(adjunto.ruta)
        
        # Eliminar de la base de datos incluso si falla en Azure
        # (podría ser que ya no exista en Azure)
        adjunto.destroy
        
        if delete_result[:success]
          status 200
          return { message: 'Adjunto eliminado correctamente' }.to_json
        else
          # El registro se eliminó de la BD pero hubo un problema con Azure
          status 207 # Multi-Status
          return { 
            message: 'Adjunto eliminado de la base de datos pero pudo haber un problema al eliminarlo de Azure',
            azure_error: delete_result[:error]
          }.to_json
        end
      else
        status 404
        return { error: 'Adjunto no encontrado' }.to_json
      end
    rescue => e
      puts "Error al eliminar adjunto: #{e.message}"
      status 500
      return { error: 'Error al eliminar adjunto' }.to_json
    end
  end
  
  # Actualizar adjunto
  put '/adjuntos/actualizar/:id' do
    begin
      data = JSON.parse(request.body.read)
      adjunto = Adjunto.first(id: params[:id])
      
      if adjunto
        # Solo permitir actualizar ciertos campos
        campos_actualizables = {}
        campos_actualizables[:nombre] = data['nombre'] if data['nombre']
        campos_actualizables[:tipo] = data['tipo'] if data['tipo']
        
        adjunto.update(campos_actualizables)
        
        status 200
        return { 
          message: 'Adjunto actualizado correctamente',
          adjunto: adjunto 
        }.to_json
      else
        status 404
        return { error: 'Adjunto no encontrado' }.to_json
      end
    rescue => e
      puts "Error al actualizar adjunto: #{e.message}"
      status 500
      return { error: 'Error al actualizar adjunto' }.to_json
    end
  end
  
  # Obtener URL con SAS para un adjunto específico
  get '/adjuntos/:id/url' do
    begin
      adjunto = Adjunto.first(id: params[:id])
      
      if adjunto
        # Generar URL con SAS para acceso temporal
        expira_en = params[:expira_en]&.to_i || 60 # Minutos
        sas_result = AzureBlobService.generate_sas_url(adjunto.ruta, expira_en)
        
        if sas_result[:success]
          status 200
          return {
            nombre: adjunto.nombre,
            tipo: adjunto.tipo,
            url: sas_result[:sas_url],
            expira_en: sas_result[:expiry_time]
          }.to_json
        else
          status 500
          return { error: "Error al generar URL: #{sas_result[:error]}" }.to_json
        end
      else
        status 404
        return { error: 'Adjunto no encontrado' }.to_json
      end
    rescue => e
      puts "Error al obtener URL de adjunto: #{e.message}"
      status 500
      return { error: 'Error al generar URL de acceso' }.to_json
    end
  end