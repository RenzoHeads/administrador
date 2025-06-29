-- ===================================================
-- CONSULTAS SQL PARA ENDPOINTS DE RECORDATORIOS
-- ===================================================

-- 1. CREAR RECORDATORIO
-- POST-- 15. ACTIVAR RECORDATORIOS DE TAREAS DE PRIORIDAD ALTA PARA UN USUARIO
-- PUT /recordatorios/activar-prioridad-alta/:usuario_id
-- SEQUEL: DB[:recordatorios].where(tarea_id: DB[:tareas].where(usuario_id: usuario_id).where(prioridad_id: 3).select(:id)).update(activado: true)

UPDATE recordatorios 
SET activado = TRUE 
WHERE tarea_id IN (
    SELECT id 
    FROM tareas 
    WHERE usuario_id = $1 
    AND prioridad_id = 3  -- Solo tareas con prioridad ID = 3
);os/crear

INSERT INTO recordatorios (tarea_id, fecha_hora, token_fcm, mensaje, activado) 
VALUES ($1, $2, $3, $4, $5) 
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
    mensaje = $4,
    activado = $5
WHERE id = $6 
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

-- ===================================================
-- NUEVOS ENDPOINTS PARA ACTIVAR/DESACTIVAR RECORDATORIOS
-- ===================================================

-- 13. DESACTIVAR TODOS LOS RECORDATORIOS DE UN USUARIO
-- PUT /recordatorios/desactivar-usuario/:usuario_id
-- SEQUEL: DB[:recordatorios].where(tarea_id: DB[:tareas].where(usuario_id: usuario_id).select(:id)).update(activado: false)

UPDATE recordatorios 
SET activado = FALSE 
WHERE tarea_id IN (
    SELECT id FROM tareas WHERE usuario_id = $1
);

-- ===================================================

-- 14. ACTIVAR TODOS LOS RECORDATORIOS DE UN USUARIO
-- PUT /recordatorios/activar-usuario/:usuario_id
-- SEQUEL: DB[:recordatorios].where(tarea_id: DB[:tareas].where(usuario_id: usuario_id).select(:id)).update(activado: true)

UPDATE recordatorios 
SET activado = TRUE 
WHERE tarea_id IN (
    SELECT id FROM tareas WHERE usuario_id = $1
);

-- ===================================================

-- 15. ACTIVAR RECORDATORIOS DE TAREAS DE PRIORIDAD ALTA PARA UN USUARIO
-- PUT /recordatorios/activar-prioridad-alta/:usuario_id
-- SEQUEL: DB[:recordatorios].where(tarea_id: DB[:tareas].join(:prioridades, id: :prioridad_id).where(usuario_id: usuario_id).where(Sequel[:prioridades][:nivel] >= 3).select(Sequel[:tareas][:id])).update(activado: true)

UPDATE recordatorios 
SET activado = TRUE 
WHERE tarea_id IN (
    SELECT t.id 
    FROM tareas t 
    JOIN prioridades p ON t.prioridad_id = p.id 
    WHERE t.usuario_id = $1 
    AND p.nivel >= 3  -- Asumiendo que nivel 3+ es prioridad alta
);

-- ===================================================

-- 16. OBTENER ESTADO DE RECORDATORIOS DE UN USUARIO
-- GET /recordatorios/estado-usuario/:usuario_id
-- SEQUEL: DB[:recordatorios].join(:tareas, id: :tarea_id).where(Sequel[:tareas][:usuario_id] => usuario_id).group(:activado).select(:activado, Sequel.lit('COUNT(*)').as(:cantidad))

SELECT 
    activado, 
    COUNT(*) as cantidad 
FROM recordatorios r 
JOIN tareas t ON r.tarea_id = t.id 
WHERE t.usuario_id = $1 
GROUP BY activado;

-- ===================================================

-- 17. OBTENER RECORDATORIOS ACTIVOS PARA EL SCHEDULER
-- (Consulta actualizada para el scheduler)

SELECT r.*, t.titulo as tarea_titulo, t.usuario_id
FROM recordatorios r
JOIN tareas t ON r.tarea_id = t.id
WHERE DATE_TRUNC('minute', r.fecha_hora) = $1
AND r.enviado = FALSE
AND r.activado = TRUE  -- Solo recordatorios activados
ORDER BY r.fecha_hora ASC;
