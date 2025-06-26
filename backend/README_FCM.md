# 📱 Sistema de Notificaciones FCM con Recordatorios (Firebase Admin SDK)

## 🚀 Configuración Inicial

### 1. Instalar dependencias
```bash
bundle install
```

### 2. Configurar Firebase Admin SDK

#### Paso 1: Obtener credenciales de Firebase
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Configuración del proyecto** (ícono de engranaje)
4. Pestaña **Cuentas de servicio**
5. Clica en **"Generar nueva clave privada"**
6. Descarga el archivo JSON

#### Paso 2: Configurar variables de entorno
```bash
# Crear archivo .env desde el ejemplo
cp .env.example .env

# Editar .env y agregar las credenciales del JSON descargado:
FIREBASE_PROJECT_ID=tu-proyecto-firebase-id
FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\nMIIEvQ...tu_clave_privada_aqui\n-----END PRIVATE KEY-----
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@tu-proyecto.iam.gserviceaccount.com
```

#### Paso 3: Verificar configuración
```bash
ruby setup_firebase_admin.rb
```

### 3. Actualizar Base de Datos
```sql
-- Ejecutar el script SQL en PostgreSQL
psql -h prograweb-202402-1507-db.postgres.database.azure.com -U postgres -d aulas -f migrations/update_recordatorios_table.sql
```

O ejecutar manualmente:
```sql
ALTER TABLE recordatorios ADD COLUMN IF NOT EXISTS enviado BOOLEAN DEFAULT FALSE;
ALTER TABLE recordatorios ADD COLUMN IF NOT EXISTS fecha_envio TIMESTAMP;
ALTER TABLE recordatorios ADD COLUMN IF NOT EXISTS intentos_envio INTEGER DEFAULT 0;
ALTER TABLE recordatorios ADD COLUMN IF NOT EXISTS error_envio TEXT;

CREATE INDEX IF NOT EXISTS idx_recordatorios_fecha_hora_enviado 
ON recordatorios (fecha_hora, enviado);
```

## 🔧 Funcionamiento

### Sistema Automático
- El scheduler revisa la tabla `recordatorios` **cada minuto**
- Busca recordatorios donde `fecha_hora` coincida con el minuto actual
- Solo procesa recordatorios con `enviado = false`
- Envía notificación FCM al `token_fcm` especificado
- Marca el recordatorio como enviado

### Manejo de Errores
- **Reintentos**: Máximo 3 intentos por recordatorio
- **Errores persistentes**: Después de 3 fallos, se marca como enviado para evitar loops
- **Logs detallados**: Cada operación se registra en consola

## 📋 Nuevos Endpoints

### 1. Obtener recordatorios pendientes
```http
GET /recordatorios/{tarea_id}/pendientes
```

### 2. Enviar recordatorio manualmente (testing)
```http
POST /recordatorios/{id}/enviar
```

### 3. Estadísticas de recordatorios por usuario
```http
GET /recordatorios/stats/{usuario_id}
```
Respuesta:
```json
{
  "total": 15,
  "pendientes": 5,
  "enviados": 8,
  "fallidos": 2
}
```

### 4. Resetear recordatorio para reenvío
```http
PUT /recordatorios/{id}/reset
```

## 🔄 Flujo de Trabajo

### Crear Recordatorio
```http
POST /recordatorios/crear
Content-Type: application/json

{
  "tarea_id": 426,
  "fecha_hora": "2025-06-25T14:30:00",
  "token_fcm": "f1234567890abcdef...",
  "mensaje": "Recordatorio: Completar tarea pendiente"
}
```

### Verificación Automática
1. **Cada minuto** el sistema verifica:
   - `fecha_hora` truncada al minuto = hora actual
   - `enviado = false`

2. **Si encuentra coincidencias**:
   - Envía notificación FCM
   - Actualiza `enviado = true`
   - Registra `fecha_envio`

## 🧪 Testing

### 1. Crear recordatorio para testing inmediato
```bash
# Crear recordatorio para el siguiente minuto
curl -X POST http://localhost:4567/recordatorios/crear \
  -H "Content-Type: application/json" \
  -d '{
    "tarea_id": 1,
    "fecha_hora": "2025-06-25T14:31:00",
    "token_fcm": "tu_token_fcm_de_testing",
    "mensaje": "Test de recordatorio"
  }'
```

### 2. Enviar recordatorio manualmente
```bash
curl -X POST http://localhost:4567/recordatorios/1/enviar
```

### 3. Ver logs en tiempo real
```bash
# Los logs aparecen en la consola del servidor
tail -f logs/sinatra.log  # si tienes logging a archivo
```

## 📱 Configuración del Cliente (Android/iOS)

### Android (Firebase)
```kotlin
// En tu app Android, obtener el token FCM:
FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
    val token = task.result
    // Enviar este token al servidor cuando el usuario se registre
}
```

### iOS (Firebase)
```swift
// En tu app iOS:
Messaging.messaging().token { token, error in
    if let token = token {
        // Enviar este token al servidor
    }
}
```

## 🔍 Monitoreo y Logs

El sistema imprime logs detallados:
```
📅 ReminderScheduler iniciado - verificando recordatorios cada minuto
⏰ 2025-06-25 14:30:00 - Ejecutando verificación de recordatorios...
🔍 Verificando recordatorios para: 2025-06-25 14:30:00
📋 Encontrados 2 recordatorios pendientes
📤 Enviando recordatorio ID: 123 para tarea: 456
✅ Recordatorio 123 enviado exitosamente
❌ Error enviando recordatorio 124: Invalid registration token
```

## ⚠️ Consideraciones de Producción

1. **Variables de entorno**: Nunca commitear la clave FCM
2. **Rate limiting**: FCM tiene límites de envío
3. **Tokens inválidos**: Los tokens FCM pueden expirar
4. **Monitoreo**: Implementar alertas para fallos consecutivos
5. **Base de datos**: Considerar índices adicionales para grandes volúmenes

## 🚨 Solución de Problemas

### Error: "FCM no configurado"
- Verificar que `FCM_SERVER_KEY` esté en el archivo `.env`
- Reiniciar el servidor después de agregar la variable

### Error: "Invalid registration token"
- El token FCM del dispositivo es inválido o expiró
- El dispositivo debe generar un nuevo token

### Recordatorios no se envían
- Verificar que el scheduler esté corriendo: buscar logs "⏰"
- Comprobar que `fecha_hora` esté en formato correcto
- Verificar que `enviado = false`

### Performance lenta
- Verificar índices en la tabla `recordatorios`
- Considerar archivar recordatorios antiguos

## 📊 Estructura de Base de Datos Actualizada

```sql
Table: recordatorios
├── id (PRIMARY KEY)
├── tarea_id (FOREIGN KEY)
├── fecha_hora (TIMESTAMP) 
├── token_fcm (TEXT)
├── mensaje (TEXT)
├── enviado (BOOLEAN DEFAULT FALSE) ← NUEVO
├── fecha_envio (TIMESTAMP) ← NUEVO  
├── intentos_envio (INTEGER DEFAULT 0) ← NUEVO
└── error_envio (TEXT) ← NUEVO
```
