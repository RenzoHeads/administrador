-- ===================================================
-- CONSULTAS SQL PARA ENDPOINTS DE LISTAS
-- ===================================================

-- 1. CREAR LISTA
-- POST /listas/crear

INSERT INTO listas (usuario_id, nombre, descripcion, color) 
VALUES ($1, $2, $3, $4) 
RETURNING *;

-- ===================================================

-- 2. OBTENER LISTAS POR USUARIO
-- GET /listas/:usuario_id

SELECT * FROM listas 
WHERE usuario_id = $1
ORDER BY nombre ASC;

-- ===================================================

-- 3. ACTUALIZAR LISTA
-- PUT /listas/actualizar/:id

-- Verificar que la lista existe
SELECT * FROM listas 
WHERE id = $1;

-- Actualizar lista
UPDATE listas SET 
    usuario_id = $1,
    nombre = $2,
    descripcion = $3,
    color = $4
WHERE id = $5 
RETURNING *;

-- ===================================================

-- 4. ELIMINAR LISTA Y SUS TAREAS RELACIONADAS
-- DELETE /listas/eliminar/:id

-- Obtener lista para verificar existencia
SELECT * FROM listas 
WHERE id = $1;

-- Obtener IDs de tareas que serán eliminadas
SELECT id FROM tareas 
WHERE lista_id = $1;

-- Eliminar tareas de la lista
DELETE FROM tareas 
WHERE lista_id = $1;

-- Eliminar la lista
DELETE FROM listas 
WHERE id = $1;

-- ===================================================

-- 5. OBTENER CANTIDAD DE TAREAS POR LISTA
-- GET /listas/cantidad_tareas/:id

-- Verificar que la lista existe
SELECT * FROM listas 
WHERE id = $1;

-- Contar tareas de la lista
SELECT COUNT(*) as cantidad_tareas 
FROM tareas 
WHERE lista_id = $1;

-- ===================================================

-- 6. OBTENER CANTIDAD DE TAREAS PENDIENTES POR LISTA
-- GET /listas/cantidad_tareas_pendientes/:id

-- Verificar que la lista existe
SELECT * FROM listas 
WHERE id = $1;

-- Contar tareas pendientes (estado_id = 1)
SELECT COUNT(*) as cantidad_tareas_pendientes 
FROM tareas 
WHERE lista_id = $1 
AND estado_id = 1;

-- ===================================================

-- 7. OBTENER CANTIDAD DE TAREAS COMPLETADAS POR LISTA
-- GET /listas/cantidad_tareas_completadas/:id

-- Verificar que la lista existe
SELECT * FROM listas 
WHERE id = $1;

-- Contar tareas completadas (estado_id = 2)
SELECT COUNT(*) as cantidad_tareas_completadas 
FROM tareas 
WHERE lista_id = $1 
AND estado_id = 2;

-- ===================================================

-- 8. GENERAR LISTA CON TAREAS USANDO IA
-- POST /listas/generar_ia

-- Crear lista generada por IA
INSERT INTO listas (usuario_id, nombre, descripcion, color) 
VALUES ($1, $2, $3, $4) 
RETURNING *;

-- Crear tareas generadas por IA (se ejecuta múltiples veces)
INSERT INTO tareas (
    lista_id, 
    usuario_id, 
    titulo, 
    descripcion, 
    fecha_creacion, 
    fecha_vencimiento, 
    estado_id, 
    prioridad_id, 
    categoria_id
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) 
RETURNING *;

-- ===================================================

-- 9. OBTENER LISTAS CON ESTADÍSTICAS COMPLETAS
-- Consulta avanzada para obtener listas con contadores de tareas

SELECT 
    l.id,
    l.nombre,
    l.descripcion,
    l.color,
    l.usuario_id,
    COUNT(t.id) as total_tareas,
    COUNT(CASE WHEN t.estado_id = 1 THEN 1 END) as tareas_pendientes,
    COUNT(CASE WHEN t.estado_id = 2 THEN 1 END) as tareas_completadas,
    COUNT(CASE WHEN t.estado_id = 3 THEN 1 END) as tareas_en_progreso
FROM listas l
LEFT JOIN tareas t ON l.id = t.lista_id
WHERE l.usuario_id = $1
GROUP BY l.id, l.nombre, l.descripcion, l.color, l.usuario_id
ORDER BY l.nombre ASC;

-- ===================================================

-- 10. OBTENER LISTA CON SUS TAREAS
-- Consulta para obtener una lista específica con todas sus tareas

SELECT 
    l.id as lista_id,
    l.nombre as lista_nombre,
    l.descripcion as lista_descripcion,
    l.color as lista_color,
    t.id as tarea_id,
    t.titulo as tarea_titulo,
    t.descripcion as tarea_descripcion,
    t.fecha_creacion,
    t.fecha_vencimiento,
    e.nombre as estado,
    p.nombre as prioridad,
    c.nombre as categoria
FROM listas l
LEFT JOIN tareas t ON l.id = t.lista_id
LEFT JOIN estados e ON t.estado_id = e.id
LEFT JOIN prioridades p ON t.prioridad_id = p.id
LEFT JOIN categorias c ON t.categoria_id = c.id
WHERE l.id = $1
ORDER BY t.fecha_vencimiento ASC;

-- ===================================================

-- 11. BUSCAR LISTAS POR NOMBRE
-- Consulta para buscar listas que contengan un texto específico

SELECT * FROM listas 
WHERE usuario_id = $1 
AND LOWER(nombre) LIKE LOWER('%' || $2 || '%')
ORDER BY nombre ASC;
