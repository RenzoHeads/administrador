require_relative '../services/fcm_admin_service'
require 'tzinfo'

class ReminderScheduler
  def initialize
    @fcm_service = FCMAdminService.new
    
    # Configurar zonas horarias
    @lima_tz = TZInfo::Timezone.get('America/Lima')
    @local_tz = TZInfo::Timezone.get(Time.now.zone) rescue TZInfo::Timezone.get('UTC')
    
    puts "📅 ReminderScheduler iniciado - verificando recordatorios cada minuto"
    puts "🌍 Zona horaria Lima: #{@lima_tz.identifier}"
    puts "🖥️  Zona horaria local: #{@local_tz.identifier}"
  end

  def check_and_send_reminders
    begin
      # Obtener la hora actual de Lima (la BD guarda en hora de Lima)
      lima_time = @lima_tz.now
      lima_current_minute = Time.new(
        lima_time.year,
        lima_time.month,
        lima_time.day,
        lima_time.hour,
        lima_time.min,
        0  # Segundos en 0
      )

      # Obtener también la hora local del sistema para logs
      system_time = Time.now
      system_current_minute = Time.new(
        system_time.year,
        system_time.month,
        system_time.day,
        system_time.hour,
        system_time.min,
        0
      )

      # Buscar recordatorios que coincidan con el minuto actual de Lima y no hayan sido enviados
      recordatorios_pendientes = DB[:recordatorios]
        .where(enviado: false)
        .where(Sequel.function(:date_trunc, 'minute', :fecha_hora) => lima_current_minute)
        .all

      puts "🔍 Verificando recordatorios para Lima: #{lima_current_minute} | Sistema: #{system_current_minute}"
      puts "📋 Encontrados #{recordatorios_pendientes.length} recordatorios pendientes"

      recordatorios_pendientes.each do |recordatorio|
        puts "📤 Enviando recordatorio ID: #{recordatorio[:id]} para tarea: #{recordatorio[:tarea_id]}"
        
        # Enviar notificación FCM
        result = @fcm_service.send_reminder_notification(recordatorio)
        
        if result[:success]
          # Marcar como enviado
          DB[:recordatorios]
            .where(id: recordatorio[:id])
            .update(enviado: true, fecha_envio: Time.now)
          
          puts "✅ Recordatorio #{recordatorio[:id]} enviado exitosamente"
        else
          puts "❌ Error enviando recordatorio #{recordatorio[:id]}: #{result[:error]}"
          
          # Opcional: incrementar contador de intentos fallidos
          intentos_actuales = recordatorio[:intentos_envio] || 0
          if intentos_actuales < 3  # Máximo 3 intentos
            DB[:recordatorios]
              .where(id: recordatorio[:id])
              .update(intentos_envio: intentos_actuales + 1)
          else
            # Después de 3 intentos fallidos, marcar como enviado para evitar loops infinitos
            DB[:recordatorios]
              .where(id: recordatorio[:id])
              .update(enviado: true, fecha_envio: Time.now, error_envio: result[:error])
            puts "⚠️  Recordatorio #{recordatorio[:id]} marcado como enviado después de 3 intentos fallidos"
          end
        end
      end

    rescue => e
      puts "💥 Error en ReminderScheduler: #{e.message}"
      puts e.backtrace
    end
  end
end
