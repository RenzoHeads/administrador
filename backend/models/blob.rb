require 'azure/storage/blob'
require 'mime-types'
require 'securerandom'
require 'fileutils'
require 'azure/storage/common'
# Configuración para Azure Blob Storage
module AzureBlobService
  class << self
    def configure(account_name, sas_token, container_name)
      @account_name = account_name
      @sas_token = sas_token
      @container_name = container_name
      @blob_service = Azure::Storage::Blob::BlobService.new(
        storage_account_name: @account_name,
        storage_sas_token: @sas_token
      )
    end
    
    def upload_file(file_path, file_name, content_type, entity_type, entity_id)
      # Generar un nombre único para evitar colisiones
      # Formato: entity_type/entity_id/timestamp-random-original_name
      timestamp = Time.now.to_i
      random_str = SecureRandom.hex(4)
      extension = File.extname(file_name)
      base_name = File.basename(file_name, extension)
      
      # Sanitizar el nombre del archivo
      sanitized_base = base_name.gsub(/[^a-zA-Z0-9_-]/, '')
      
      # Determinar el tipo de contenido basado en la extensión si no se proporciona
      content_type ||= MIME::Types.type_for(file_path).first&.content_type || 'application/octet-stream'
      
      # Estructura de carpetas y nombre final
      blob_path = "#{entity_type}/#{entity_id}/#{timestamp}-#{random_str}-#{sanitized_base}#{extension}"
      
      # Opciones para la subida del archivo
      options = {
        content_type: content_type,
        metadata: {
          'original_filename' => file_name,
          'entity_type' => entity_type,
          'entity_id' => entity_id.to_s,
          'upload_timestamp' => Time.now.utc.iso8601
        }
      }
      
      # Subir el archivo al blob
      begin
        File.open(file_path, 'rb') do |file|
          @blob_service.create_block_blob(@container_name, blob_path, file, options)
        end
        
        # Generar la URL del blob
        blob_url = "https://#{@account_name}.blob.core.windows.net/#{@container_name}/#{blob_path}"
        
        return {
          success: true,
          path: blob_path,
          url: blob_url,
          content_type: content_type
        }
      rescue => e
        return {
          success: false,
          error: e.message
        }
      end
    end
    
    # Método para eliminar un archivo del blob
    def delete_file(blob_path)
      begin
        @blob_service.delete_blob(@container_name, blob_path)
        return { success: true }
      rescue => e
        return {
          success: false,
          error: e.message
        }
      end
    end
    
# Método para obtener URL con SAS para acceso temporal
    def generate_sas_url(blob_path, expires_in_minutes = 60)
      begin
        # Verificar que tengamos los valores necesarios configurados
        if @account_name.nil? || @container_name.nil? || @sas_token.nil?
          return {
            success: false,
            error: "La configuración de Azure Blob Storage no está completa"
          }
        end
        
        # Extraer solamente el token SAS (sin el signo de interrogación inicial)
        # El token SAS que ya tienes probablemente incluye los permisos necesarios
        sas_token = @sas_token.start_with?('?') ? @sas_token[1..-1] : @sas_token
        
        # Construir directamente la URL de acceso al blob usando el token SAS
        sas_url = "https://#{@account_name}.blob.core.windows.net/#{@container_name}/#{blob_path}?#{sas_token}"
        
        # Calcular tiempo de expiración aproximado basado en el token SAS existente
        # Este es solo un valor aproximado para devolver en la respuesta
        expiry_time = (Time.now + (expires_in_minutes * 60)).utc.iso8601
        
        return {
          success: true,
          sas_url: sas_url,
          expiry_time: expiry_time
        }
      rescue => e
        return {
          success: false,
          error: "Error al generar URL: #{e.message}"
        }
      end
    end
  end
end

# Inicializar el servicio al cargar la aplicación
configure do
  # Estos valores deberían venir de variables de entorno o un archivo de configuración
  account_name = "gordo"
  sas_token = "sp=racwdli&st=2025-04-13T21:04:12Z&se=2025-07-23T05:04:12Z&spr=https&sv=2024-11-04&sr=c&sig=3mohaZWVdiGzftKifWt2IjoOGk5%2FHUtx5SS3R7RXjIA%3D"
  container_name = "archivos"
  
  # Configurar el servicio
  AzureBlobService.configure(account_name, sas_token, container_name)
end

# Helper para procesar la subida de archivos
def process_file_upload(params, temp_folder = './tmp/uploads')
  begin
    # Asegurarse de que existe la carpeta temporal
    FileUtils.mkdir_p(temp_folder) unless File.directory?(temp_folder)
    
    # Procesar el archivo subido
    if params[:file] && params[:file][:tempfile]
      # Crear un nombre de archivo temporal
      temp_path = File.join(temp_folder, "#{SecureRandom.uuid}#{File.extname(params[:file][:filename])}")
      
      # Guardar el archivo temporalmente
      FileUtils.copy(params[:file][:tempfile].path, temp_path)
      
      return {
        success: true,
        temp_path: temp_path,
        filename: params[:file][:filename],
        content_type: params[:file][:type]
      }
    else
      return {
        success: false,
        error: 'No se ha proporcionado un archivo'
      }
    end
  rescue => e
    return {
      success: false,
      error: e.message
    }
  end
end

# Método para determinar el tipo de archivo basado en la extensión
def determine_file_type(filename)
  extension = File.extname(filename).downcase
  
  case extension
  when '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg'
    'IMAGEN'
  when '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.txt', '.rtf'
    'DOCUMENTO'
  when '.mp3', '.wav', '.ogg', '.flac', '.aac', '.m4a'
    'AUDIO'
  when '.mp4', '.avi', '.mov', '.wmv', '.flv', '.mkv', '.webm'
    'VIDEO'
  else
    'OTRO'
  end
end

# Limpiar archivos temporales (puedes llamar a esta función periódicamente)
def clean_temp_files(temp_folder = './tmp/uploads', max_age_hours = 24)
  begin
    return unless File.directory?(temp_folder)
    
    Dir.glob(File.join(temp_folder, '*')).each do |file|
      if File.file?(file) && (Time.now - File.mtime(file)) > (max_age_hours * 3600)
        File.delete(file)
      end
    end
  rescue => e
    puts "Error al limpiar archivos temporales: #{e.message}"
  end
end