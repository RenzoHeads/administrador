-- ===================================================
-- CONSULTAS SQL PARA ENDPOINTS DE ESTADOS
-- ===================================================

-- 1. OBTENER TODOS LOS ESTADOS
-- GET /estados

SELECT * FROM estados 
ORDER BY id ASC;

-- ===================================================

-- 2. OBTENER ESTADO POR ID
-- GET /estados/:id

SELECT * FROM estados 
WHERE id = $1;

-- ===================================================

-- 3. OBTENER ESTADOS CON CONTADOR DE TAREAS
-- Consulta avanzada para obtener estados con cantidad de tareas

SELECT 
    e.id,
    e.nombre,
    e.descripcion,
    e.color,
    COUNT(t.id) as total_tareas
FROM estados e
LEFT JOIN tareas t ON e.id = t.estado_id
GROUP BY e.id, e.nombre, e.descripcion, e.color
ORDER BY e.id ASC;

-- ===================================================

-- 4. OBTENER TAREAS POR ESTADO
-- Consulta para obtener todas las tareas en un estado específico

SELECT 
    t.*,
    u.nombre as usuario,
    l.nombre as lista,
    c.nombre as categoria,
    p.nombre as prioridad
FROM tareas t
JOIN usuarios u ON t.usuario_id = u.id
JOIN listas l ON t.lista_id = l.id
JOIN categorias c ON t.categoria_id = c.id
JOIN prioridades p ON t.prioridad_id = p.id
WHERE t.estado_id = $1
ORDER BY t.fecha_vencimiento ASC;

-- ===================================================

-- 5. ESTADÍSTICAS DE ESTADOS POR USUARIO
-- Consulta para obtener estadísticas de estados para un usuario específico

SELECT 
    e.id,
    e.nombre,
    COUNT(t.id) as cantidad_tareas
FROM estados e
LEFT JOIN tareas t ON e.id = t.estado_id AND t.usuario_id = $1
GROUP BY e.id, e.nombre
ORDER BY e.id ASC;
