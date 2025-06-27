-- ===================================================
-- CONSULTAS SQL PARA ENDPOINTS DE ETIQUETAS
-- ===================================================

-- 1. CREAR ETIQUETA
-- POST /etiquetas/crear

INSERT INTO etiquetas (nombre, color) 
VALUES ($1, $2) 
RETURNING *;

-- ===================================================

-- 2. ACTUALIZAR ETIQUETA
-- PUT /etiquetas/actualizar/:id

-- Verificar que la etiqueta existe
SELECT * FROM etiquetas 
WHERE id = $1;

-- Actualizar etiqueta
UPDATE etiquetas SET 
    nombre = $1,
    color = $2
WHERE id = $3 
RETURNING *;

-- ===================================================

-- 3. ELIMINAR ETIQUETA
-- DELETE /etiquetas/eliminar/:id

-- Verificar que la etiqueta existe
SELECT * FROM etiquetas 
WHERE id = $1;

-- Eliminar etiqueta (las relaciones se eliminan por CASCADE)
DELETE FROM etiquetas 
WHERE id = $1;

-- ===================================================

-- 4. OBTENER ETIQUETA POR NOMBRE
-- GET /etiquetas/obtener/:nombre

SELECT * FROM etiquetas 
WHERE nombre = $1;

-- ===================================================

-- 5. OBTENER ETIQUETA POR ID
-- GET /etiquetas/:id

SELECT * FROM etiquetas 
WHERE id = $1;

-- ===================================================

-- 6. OBTENER ETIQUETAS DE UNA TAREA
-- GET /tareas/:id/etiquetas

SELECT e.* 
FROM etiquetas e
JOIN tarea_etiquetas te ON e.id = te.etiqueta_id
WHERE te.tarea_id = $1
ORDER BY e.nombre ASC;

-- ===================================================

-- 7. OBTENER ETIQUETAS DE TODAS LAS TAREAS DE UN USUARIO
-- GET /usuarios/:id/etiquetas

SELECT DISTINCT e.* 
FROM etiquetas e
JOIN tarea_etiquetas te ON e.id = te.etiqueta_id
JOIN tareas t ON te.tarea_id = t.id
WHERE t.usuario_id = $1
ORDER BY e.nombre ASC;

-- ===================================================

-- 8. OBTENER TODAS LAS ETIQUETAS
-- Consulta general para obtener todas las etiquetas

SELECT * FROM etiquetas 
ORDER BY nombre ASC;

-- ===================================================

-- 9. OBTENER ETIQUETAS CON CONTADOR DE TAREAS
-- Consulta avanzada para obtener etiquetas con cantidad de tareas

SELECT 
    e.id,
    e.nombre,
    e.color,
    COUNT(te.tarea_id) as total_tareas
FROM etiquetas e
LEFT JOIN tarea_etiquetas te ON e.id = te.etiqueta_id
GROUP BY e.id, e.nombre, e.color
ORDER BY e.nombre ASC;

-- ===================================================

-- 10. BUSCAR ETIQUETAS POR NOMBRE
-- Consulta para buscar etiquetas que contengan un texto específico

SELECT * FROM etiquetas 
WHERE LOWER(nombre) LIKE LOWER('%' || $1 || '%')
ORDER BY nombre ASC;

-- ===================================================

-- 11. OBTENER TAREAS POR ETIQUETA
-- Consulta para obtener todas las tareas que tienen una etiqueta específica

SELECT 
    t.*,
    u.nombre as usuario,
    l.nombre as lista,
    c.nombre as categoria,
    e.nombre as estado,
    p.nombre as prioridad
FROM tareas t
JOIN tarea_etiquetas te ON t.id = te.tarea_id
JOIN usuarios u ON t.usuario_id = u.id
JOIN listas l ON t.lista_id = l.id
JOIN categorias c ON t.categoria_id = c.id
JOIN estados e ON t.estado_id = e.id
JOIN prioridades p ON t.prioridad_id = p.id
WHERE te.etiqueta_id = $1
ORDER BY t.fecha_vencimiento ASC;

-- ===================================================

-- 12. ASIGNAR ETIQUETA A TAREA
-- Consulta para crear relación entre tarea y etiqueta

INSERT INTO tarea_etiquetas (tarea_id, etiqueta_id) 
VALUES ($1, $2)
ON CONFLICT (tarea_id, etiqueta_id) DO NOTHING;

-- ===================================================

-- 13. REMOVER ETIQUETA DE TAREA
-- Consulta para eliminar relación entre tarea y etiqueta

DELETE FROM tarea_etiquetas 
WHERE tarea_id = $1 
AND etiqueta_id = $2;
