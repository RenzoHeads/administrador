-- Script para actualizar la tabla recordatorios con los campos necesarios para FCM
-- Ejecutar este script en tu base de datos PostgreSQL

-- Agregar campos para control de envío de notificaciones
ALTER TABLE recordatorios 
ADD COLUMN IF NOT EXISTS enviado BOOLEAN DEFAULT FALSE;

ALTER TABLE recordatorios 
ADD COLUMN IF NOT EXISTS fecha_envio TIMESTAMP;

ALTER TABLE recordatorios 
ADD COLUMN IF NOT EXISTS intentos_envio INTEGER DEFAULT 0;

ALTER TABLE recordatorios 
ADD COLUMN IF NOT EXISTS error_envio TEXT;

-- Crear índice para mejorar performance en las consultas del scheduler
CREATE INDEX IF NOT EXISTS idx_recordatorios_fecha_hora_enviado 
ON recordatorios (fecha_hora, enviado);

-- Crear índice para consultas por fecha truncada al minuto
CREATE INDEX IF NOT EXISTS idx_recordatorios_fecha_hora_minute 
ON recordatorios (date_trunc('minute', fecha_hora));

-- Mostrar estructura actualizada de la tabla
\d recordatorios;
