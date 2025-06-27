-- ===================================================
-- CONSULTAS SQL PARA ENDPOINTS DE TAREAS
-- ===================================================

-- 1. CREAR TAREA CON ETIQUETAS
-- POST /tareas/crear_con_etiquetas

-- Insertar nueva tarea
INSERT INTO tareas (
    usuario_id, 
    lista_id, 
    titulo, 
    descripcion, 
    fecha_creacion, 
    fecha_vencimiento, 
    categoria_id, 
    estado_id, 
    prioridad_id
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) 
RETURNING *;

-- Insertar relaciones con etiquetas (se ejecuta múltiples veces)
INSERT INTO tarea_etiquetas (tarea_id, etiqueta_id) 
VALUES ($1, $2);

-- Obtener tarea creada con sus datos
SELECT * FROM tareas 
WHERE id = $1;

-- ===================================================

-- 2. ACTUALIZAR TAREA CON ETIQUETAS
-- PUT /tareas/:id/actualizar_con_etiquetas

-- Verificar que la tarea existe
SELECT * FROM tareas 
WHERE id = $1;

-- Actualizar datos de la tarea
UPDATE tareas SET 
    usuario_id = $1,
    lista_id = $2,
    titulo = $3,
    descripcion = $4,
    fecha_creacion = $5,
    fecha_vencimiento = $6,
    categoria_id = $7,
    estado_id = $8,
    prioridad_id = $9
WHERE id = $10;

-- Eliminar etiquetas actuales
DELETE FROM tarea_etiquetas 
WHERE tarea_id = $1;

-- Insertar nuevas etiquetas (se ejecuta múltiples veces)
INSERT INTO tarea_etiquetas (tarea_id, etiqueta_id) 
VALUES ($1, $2);

-- Obtener tarea actualizada
SELECT * FROM tareas 
WHERE id = $1;

-- ===================================================

-- 3. ELIMINAR TAREA
-- DELETE /tareas/eliminar/:id

-- Obtener tarea para verificar existencia
SELECT * FROM tareas 
WHERE id = $1;

-- Eliminar tarea (las relaciones se eliminan por CASCADE)
DELETE FROM tareas 
WHERE id = $1;

-- ===================================================

-- 4. OBTENER TAREA POR ID
-- GET /tareas/obtener/:id

SELECT * FROM tareas 
WHERE id = $1;

-- ===================================================

-- 5. OBTENER TODAS LAS TAREAS DE UN USUARIO
-- GET /tareas/:usuario_id

SELECT * FROM tareas 
WHERE usuario_id = $1;

-- ===================================================

-- 6. OBTENER ESTADO DE UNA TAREA
-- GET /tareas/estado/:id

-- Obtener tarea
SELECT * FROM tareas 
WHERE id = $1;

-- Obtener estado de la tarea
SELECT * FROM estados 
WHERE id = $1;  -- estado_id de la tarea

-- ===================================================

-- 7. ACTUALIZAR ESTADO DE UNA TAREA
-- PUT /tareas/estado/:id

-- Obtener tarea
SELECT * FROM tareas 
WHERE id = $1;

-- Verificar que el estado existe
SELECT * FROM estados 
WHERE id = $1;  -- nuevo estado_id

-- Actualizar estado de la tarea
UPDATE tareas 
SET estado_id = $1 
WHERE id = $2 
RETURNING *;

-- ===================================================

-- 8. OBTENER TAREAS CON DETALLES COMPLETOS (consulta avanzada)
-- Esta consulta podría usarse para obtener tareas con toda su información relacionada

SELECT 
    t.id as tarea_id,
    t.titulo,
    t.descripcion,
    t.fecha_creacion,
    t.fecha_vencimiento,
    u.nombre as usuario,
    l.nombre as lista,
    c.nombre as categoria,
    c.color as categoria_color,
    e.nombre as estado,
    p.nombre as prioridad,
    et.nombre as etiqueta,
    et.color as etiqueta_color
FROM tareas t
LEFT JOIN usuarios u ON t.usuario_id = u.id
LEFT JOIN listas l ON t.lista_id = l.id
LEFT JOIN categorias c ON t.categoria_id = c.id
LEFT JOIN estados e ON t.estado_id = e.id
LEFT JOIN prioridades p ON t.prioridad_id = p.id
LEFT JOIN tarea_etiquetas te ON t.id = te.tarea_id
LEFT JOIN etiquetas et ON te.etiqueta_id = et.id
WHERE t.usuario_id = $1
ORDER BY t.fecha_vencimiento ASC;

-- ===================================================

-- 9. OBTENER TAREAS POR ESTADO
-- Consulta útil para filtrar tareas por estado

SELECT * FROM tareas 
WHERE usuario_id = $1 
AND estado_id = $2
ORDER BY fecha_vencimiento ASC;

-- ===================================================

-- 10. OBTENER TAREAS POR LISTA
-- Consulta para obtener todas las tareas de una lista específica

SELECT * FROM tareas 
WHERE lista_id = $1
ORDER BY fecha_creacion DESC;

-- ===================================================

-- 11. OBTENER TAREAS VENCIDAS
-- Consulta para obtener tareas que han pasado su fecha de vencimiento

SELECT * FROM tareas 
WHERE usuario_id = $1 
AND fecha_vencimiento < NOW() 
AND estado_id != 2  -- Asumiendo que 2 es "completada"
ORDER BY fecha_vencimiento ASC;
