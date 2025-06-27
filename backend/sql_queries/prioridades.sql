-- ===================================================
-- CONSULTAS SQL PARA ENDPOINTS DE PRIORIDADES
-- ===================================================

-- 1. OBTENER TODAS LAS PRIORIDADES
-- GET /prioridades

SELECT * FROM prioridades 
ORDER BY id ASC;

-- ===================================================

-- 2. OBTENER PRIORIDAD POR ID
-- GET /prioridades/:id

SELECT * FROM prioridades 
WHERE id = $1;

-- ===================================================

-- 3. OBTENER PRIORIDADES CON CONTADOR DE TAREAS
-- Consulta avanzada para obtener prioridades con cantidad de tareas

SELECT 
    p.id,
    p.nombre,
    p.descripcion,
    p.nivel,
    p.color,
    COUNT(t.id) as total_tareas
FROM prioridades p
LEFT JOIN tareas t ON p.id = t.prioridad_id
GROUP BY p.id, p.nombre, p.descripcion, p.nivel, p.color
ORDER BY p.nivel DESC;  -- Ordenar por nivel de prioridad (alta a baja)

-- ===================================================

-- 4. OBTENER TAREAS POR PRIORIDAD
-- Consulta para obtener todas las tareas con una prioridad específica

SELECT 
    t.*,
    u.nombre as usuario,
    l.nombre as lista,
    c.nombre as categoria,
    e.nombre as estado
FROM tareas t
JOIN usuarios u ON t.usuario_id = u.id
JOIN listas l ON t.lista_id = l.id
JOIN categorias c ON t.categoria_id = c.id
JOIN estados e ON t.estado_id = e.id
WHERE t.prioridad_id = $1
ORDER BY t.fecha_vencimiento ASC;

-- ===================================================

-- 5. ESTADÍSTICAS DE PRIORIDADES POR USUARIO
-- Consulta para obtener estadísticas de prioridades para un usuario específico

SELECT 
    p.id,
    p.nombre,
    p.nivel,
    COUNT(t.id) as cantidad_tareas
FROM prioridades p
LEFT JOIN tareas t ON p.id = t.prioridad_id AND t.usuario_id = $1
GROUP BY p.id, p.nombre, p.nivel
ORDER BY p.nivel DESC;

-- ===================================================

-- 6. OBTENER TAREAS DE ALTA PRIORIDAD PENDIENTES
-- Consulta útil para mostrar tareas urgentes

SELECT 
    t.*,
    u.nombre as usuario,
    l.nombre as lista,
    c.nombre as categoria
FROM tareas t
JOIN usuarios u ON t.usuario_id = u.id
JOIN listas l ON t.lista_id = l.id
JOIN categorias c ON t.categoria_id = c.id
JOIN prioridades p ON t.prioridad_id = p.id
WHERE t.prioridad_id = 3  -- Asumiendo que 3 es "Alta prioridad"
AND t.estado_id != 2      -- No completadas
AND t.usuario_id = $1
ORDER BY t.fecha_vencimiento ASC;
