-- ===================================================
-- AGREGAR COLUMNA 'activado' A LA TABLA RECORDATORIOS
-- ===================================================

-- Agregar columna activado (por defecto TRUE - activado)
ALTER TABLE recordatorios 
ADD COLUMN activado BOOLEAN DEFAULT TRUE;

-- Actualizar todos los recordatorios existentes para que estén activados
UPDATE recordatorios 
SET activado = TRUE 
WHERE activado IS NULL;

-- ===================================================
-- CONSULTAS ADICIONALES PARA LOS NUEVOS ENDPOINTS
-- ===================================================

-- 1. DESACTIVAR TODOS LOS RECORDATORIOS DE UN USUARIO
-- PUT /recordatorios/desactivar-usuario/:usuario_id

UPDATE recordatorios 
SET activado = FALSE 
WHERE tarea_id IN (
    SELECT id FROM tareas WHERE usuario_id = $1
);

-- ===================================================

-- 2. ACTIVAR TODOS LOS RECORDATORIOS DE UN USUARIO
-- PUT /recordatorios/activar-usuario/:usuario_id

UPDATE recordatorios 
SET activado = TRUE 
WHERE tarea_id IN (
    SELECT id FROM tareas WHERE usuario_id = $1
);

-- ===================================================

-- 3. ACTIVAR RECORDATORIOS DE TAREAS DE PRIORIDAD ALTA PARA UN USUARIO
-- PUT /recordatorios/activar-prioridad-alta/:usuario_id

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

-- 4. OBTENER RECORDATORIOS ACTIVOS PARA EL SCHEDULER
-- (Actualización de la consulta existente)

SELECT r.*, t.titulo as tarea_titulo, t.usuario_id
FROM recordatorios r
JOIN tareas t ON r.tarea_id = t.id
WHERE DATE_TRUNC('minute', r.fecha_hora) = $1
AND r.enviado = FALSE
AND r.activado = TRUE  -- Solo recordatorios activados
ORDER BY r.fecha_hora ASC;
