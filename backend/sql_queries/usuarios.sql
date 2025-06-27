-- ===================================================
-- CONSULTAS SQL PARA ENDPOINTS DE USUARIOS
-- ===================================================

-- 1. LOGIN - Validar usuario
-- POST /usuario/validar
SELECT * FROM usuarios 
WHERE nombre = $1;

-- Verificación de contraseña (se hace en el código Ruby)
-- Si coincide la contraseña, se genera JWT

-- ===================================================

-- 2. CREAR USUARIO
-- POST /usuario/crear-usuario

-- Verificar si el nombre de usuario ya existe
SELECT COUNT(*) FROM usuarios 
WHERE nombre = $1;

-- Verificar si el email ya existe
SELECT COUNT(*) FROM usuarios 
WHERE email = $1;

-- Insertar nuevo usuario
INSERT INTO usuarios (nombre, contrasena, email) 
VALUES ($1, $2, $3) 
RETURNING *;

-- ===================================================

-- 3. ELIMINAR USUARIO
-- DELETE /usuario/eliminar/:id

-- Obtener usuario por ID para verificar existencia
SELECT * FROM usuarios 
WHERE id = $1;

-- Eliminar usuario
DELETE FROM usuarios 
WHERE id = $1;

-- ===================================================

-- 4. VERIFICAR SI CORREO EXISTE
-- GET /usuario/verificar-correo/:email

SELECT * FROM usuarios 
WHERE email = $1;

-- ===================================================

-- 5. OBTENER USUARIO POR ID
-- GET /usuario/:id

SELECT id, nombre, email FROM usuarios 
WHERE id = $1;

-- ===================================================

-- 6. ASIGNAR TOKEN FCM A USUARIO
-- POST /usuario/:id/token-fcm

UPDATE usuarios 
SET token_fcm = $1 
WHERE id = $2 
RETURNING *;

-- ===================================================

-- 7. OBTENER DATOS COMPLETOS DE USUARIO
-- GET /usuarios/:id/datos_completos

-- Obtener usuario con sus listas y tareas
SELECT 
    u.id as usuario_id,
    u.nombre,
    u.email,
    u.token_fcm,
    l.id as lista_id,
    l.nombre as lista_nombre,
    l.descripcion as lista_descripcion,
    l.color as lista_color,
    COUNT(t.id) as total_tareas
FROM usuarios u
LEFT JOIN listas l ON u.id = l.usuario_id
LEFT JOIN tareas t ON l.id = t.lista_id
WHERE u.id = $1
GROUP BY u.id, u.nombre, u.email, u.token_fcm, l.id, l.nombre, l.descripcion, l.color;

-- ===================================================

-- 8. SUBIR FOTO DE PERFIL
-- POST /usuario/:id/foto-perfil

-- Actualizar URL de foto de perfil
UPDATE usuarios 
SET foto_perfil_url = $1 
WHERE id = $2 
RETURNING *;

-- ===================================================

-- 9. OBTENER URL DE FOTO DE PERFIL
-- GET /usuario/:id/foto-perfil

SELECT foto_perfil_url FROM usuarios 
WHERE id = $1;

-- ===================================================

-- 10. ELIMINAR FOTO DE PERFIL
-- DELETE /usuario/:id/foto-perfil

UPDATE usuarios 
SET foto_perfil_url = NULL 
WHERE id = $1 
RETURNING *;

-- ===================================================

-- 11. SOLICITAR RECUPERACIÓN DE CONTRASEÑA
-- POST /usuario/solicitar-recuperacion

-- Buscar usuario por email
SELECT * FROM usuarios 
WHERE email = $1;

-- Insertar token de recuperación en tabla de tokens (si existe)
INSERT INTO password_recovery_tokens (usuario_id, token, fecha_expiracion, utilizado) 
VALUES ($1, $2, $3, false);

-- ===================================================

-- 12. RESTABLECER CONTRASEÑA CON TOKEN
-- PUT /usuario/restablecer-contrasena

-- Verificar token válido
SELECT prt.*, u.* 
FROM password_recovery_tokens prt
JOIN usuarios u ON prt.usuario_id = u.id
WHERE prt.token = $1 
AND prt.fecha_expiracion > NOW() 
AND prt.utilizado = false;

-- Actualizar contraseña
UPDATE usuarios 
SET contrasena = $1 
WHERE id = $2;

-- Marcar token como utilizado
UPDATE password_recovery_tokens 
SET utilizado = true 
WHERE token = $1;

-- ===================================================

-- 13. VERIFICAR TOKEN DE RECUPERACIÓN
-- GET /usuario/verificar-token/:token

SELECT * FROM password_recovery_tokens 
WHERE token = $1 
AND fecha_expiracion > NOW() 
AND utilizado = false;
