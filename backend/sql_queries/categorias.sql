-- ===================================================
-- CONSULTAS SQL PARA ENDPOINTS DE CATEGORÍAS
-- ===================================================

-- 1. CREAR CATEGORÍA
-- POST /categorias/crear

INSERT INTO categorias (nombre, color) 
VALUES ($1, $2) 
RETURNING *;

-- ===================================================

-- 2. OBTENER TODAS LAS CATEGORÍAS
-- GET /categorias

SELECT * FROM categorias 
ORDER BY nombre ASC;

-- ===================================================

-- 3. ACTUALIZAR CATEGORÍA
-- PUT /categorias/actualizar/:id

-- Verificar que la categoría existe
SELECT * FROM categorias 
WHERE id = $1;

-- Actualizar categoría
UPDATE categorias SET 
    nombre = $1,
    color = $2
WHERE id = $3 
RETURNING *;

-- ===================================================

-- 4. ELIMINAR CATEGORÍA
-- DELETE /categorias/eliminar/:id

-- Verificar que la categoría existe
SELECT * FROM categorias 
WHERE id = $1;

-- Eliminar categoría
DELETE FROM categorias 
WHERE id = $1;

-- ===================================================

-- 5. OBTENER CATEGORÍA POR ID
-- GET /categorias/:id

SELECT * FROM categorias 
WHERE id = $1;

-- ===================================================

-- 6. OBTENER CATEGORÍAS CON CONTADOR DE TAREAS
-- Consulta avanzada para obtener categorías con cantidad de tareas

SELECT 
    c.id,
    c.nombre,
    c.color,
    COUNT(t.id) as total_tareas
FROM categorias c
LEFT JOIN tareas t ON c.id = t.categoria_id
GROUP BY c.id, c.nombre, c.color
ORDER BY c.nombre ASC;

-- ===================================================

-- 7. BUSCAR CATEGORÍAS POR NOMBRE
-- Consulta para buscar categorías que contengan un texto específico

SELECT * FROM categorias 
WHERE LOWER(nombre) LIKE LOWER('%' || $1 || '%')
ORDER BY nombre ASC;

-- ===================================================

-- 8. OBTENER TAREAS POR CATEGORÍA
-- Consulta para obtener todas las tareas de una categoría específica

SELECT 
    t.*,
    u.nombre as usuario,
    l.nombre as lista,
    e.nombre as estado,
    p.nombre as prioridad
FROM tareas t
JOIN usuarios u ON t.usuario_id = u.id
JOIN listas l ON t.lista_id = l.id
JOIN estados e ON t.estado_id = e.id
JOIN prioridades p ON t.prioridad_id = p.id
WHERE t.categoria_id = $1
ORDER BY t.fecha_vencimiento ASC;
