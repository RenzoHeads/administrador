-- ===================================================
-- CONSULTAS SQL PARA ENDPOINTS DE RECORDATORIOS
-- ===================================================

-- 1. CREAR RECORDATORIO
-- POST /recordatorios/crear

INSERT INTO recordatorios (tarea_id, fecha_hora, token_fcm, mensaje) 
VALUES ($1, $2, $3, $4) 
RETURNING *;

-- ===================================================

-- 2. OBTENER RECORDATORIOS POR TAREA
-- GET /recordatorios/:tarea_id

SELECT * FROM recordatorios 
WHERE tarea_id = $1
ORDER BY fecha_hora ASC;

-- ===================================================

-- 3. ACTUALIZAR RECORDATORIO
-- PUT /recordatorios/actualizar

-- Verificar que el recordatorio existe
SELECT * FROM recordatorios 
WHERE id = $1;

-- Actualizar recordatorio
UPDATE recordatorios SET 
    tarea_id = $1,
    fecha_hora = $2,
    token_fcm = $3,
    mensaje = $4
WHERE id = $5 
RETURNING *;

-- ===================================================

-- 4. ELIMINAR RECORDATORIO
-- DELETE /recordatorios/eliminar/:id

-- Verificar que el recordatorio existe
SELECT * FROM recordatorios 
WHERE id = $1;

-- Eliminar recordatorio
DELETE FROM recordatorios 
WHERE id = $1;

-- ===================================================

-- 5. OBTENER RECORDATORIO POR ID
-- GET /recordatorios/detalle/:id

SELECT * FROM recordatorios 
WHERE id = $1;

-- ===================================================

-- 6. OBTENER RECORDATORIOS PENDIENTES PARA ENVIAR
-- Consulta utilizada por el ReminderScheduler

SELECT * FROM recordatorios 
WHERE DATE_TRUNC('minute', fecha_hora) = $1  -- Minuto actual
AND enviado = false
ORDER BY fecha_hora ASC;

-- ===================================================

-- 7. MARCAR RECORDATORIO COMO ENVIADO
-- Consulta para actualizar estado después de envío exitoso

UPDATE recordatorios 
SET enviado = true, 
    fecha_envio = NOW() 
WHERE id = $1;

-- ===================================================

-- 8. OBTENER RECORDATORIOS CON INFORMACIÓN DE TAREA
-- Consulta avanzada para obtener recordatorios con detalles de la tarea

SELECT 
    r.id as recordatorio_id,
    r.fecha_hora,
    r.mensaje,
    r.enviado,
    r.fecha_envio,
    t.id as tarea_id,
    t.titulo as tarea_titulo,
    t.descripcion as tarea_descripcion,
    u.nombre as usuario,
    l.nombre as lista
FROM recordatorios r
JOIN tareas t ON r.tarea_id = t.id
JOIN usuarios u ON t.usuario_id = u.id
JOIN listas l ON t.lista_id = l.id
WHERE r.tarea_id = $1
ORDER BY r.fecha_hora ASC;

-- ===================================================

-- 9. OBTENER RECORDATORIOS DE UN USUARIO
-- Consulta para obtener todos los recordatorios de un usuario

SELECT 
    r.*,
    t.titulo as tarea_titulo,
    l.nombre as lista_nombre
FROM recordatorios r
JOIN tareas t ON r.tarea_id = t.id
JOIN listas l ON t.lista_id = l.id
WHERE t.usuario_id = $1
ORDER BY r.fecha_hora ASC;

-- ===================================================

-- 10. OBTENER RECORDATORIOS PRÓXIMOS (PRÓXIMAS 24 HORAS)
-- Consulta para obtener recordatorios que ocurrirán en las próximas 24 horas

SELECT 
    r.*,
    t.titulo as tarea_titulo,
    t.descripcion as tarea_descripcion,
    u.nombre as usuario
FROM recordatorios r
JOIN tareas t ON r.tarea_id = t.id
JOIN usuarios u ON t.usuario_id = u.id
WHERE r.fecha_hora BETWEEN NOW() AND (NOW() + INTERVAL '24 hours')
AND r.enviado = false
ORDER BY r.fecha_hora ASC;

-- ===================================================

-- 11. OBTENER RECORDATORIOS VENCIDOS (NO ENVIADOS)
-- Consulta para obtener recordatorios que deberían haberse enviado pero no se enviaron

SELECT 
    r.*,
    t.titulo as tarea_titulo,
    u.nombre as usuario
FROM recordatorios r
JOIN tareas t ON r.tarea_id = t.id
JOIN usuarios u ON t.usuario_id = u.id
WHERE r.fecha_hora < NOW()
AND r.enviado = false
ORDER BY r.fecha_hora ASC;

-- ===================================================

-- 12. ESTADÍSTICAS DE RECORDATORIOS
-- Consulta para obtener estadísticas de recordatorios por usuario

SELECT 
    u.id as usuario_id,
    u.nombre as usuario,
    COUNT(r.id) as total_recordatorios,
    COUNT(CASE WHEN r.enviado = true THEN 1 END) as recordatorios_enviados,
    COUNT(CASE WHEN r.enviado = false AND r.fecha_hora < NOW() THEN 1 END) as recordatorios_perdidos,
    COUNT(CASE WHEN r.enviado = false AND r.fecha_hora > NOW() THEN 1 END) as recordatorios_pendientes
FROM usuarios u
LEFT JOIN tareas t ON u.id = t.usuario_id
LEFT JOIN recordatorios r ON t.id = r.tarea_id
WHERE u.id = $1
GROUP BY u.id, u.nombre;
