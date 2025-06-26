# Implementación JWT en Flutter - Guía de Uso

## 🔐 Funcionalidad JWT Implementada

Se ha agregado la funcionalidad JWT a tu aplicación Flutter para asegurar todas las comunicaciones con el backend. Esta implementación incluye:

### 📁 Archivos Creados/Modificados

#### 1. **AuthService** (`lib/services/auth_service.dart`)
- Servicio centralizado para manejo de JWT tokens
- Almacenamiento local del token
- Headers automáticos con autorización
- Manejo de respuestas 401 (no autorizado)

#### 2. **ControladorSesionUsuario** (Actualizado)
- Integración con JWT para inicio/cierre de sesión
- Verificación automática de tokens válidos
- Almacenamiento seguro del JWT

#### 3. **Servicios Actualizados con JWT**
Todos los servicios han sido actualizados para usar JWT:
- `usuario_service.dart`
- `tarea_service.dart`
- `lista_service.dart`
- `inicio_service.dart`
- `categoria_service.dart`
- `etiqueta_service.dart`
- `recordatorio_service.dart`
- `estado_service.dart`
- `prioridad_service.dart`

## 🚀 Cómo Funciona

### 1. **Inicio de Sesión**
```dart
// Cuando el usuario se autentica exitosamente
Map<String, dynamic> loginResponse = {
  "usuario": {...},
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
};

// El JWT se guarda automáticamente
await controladorSesion.iniciarSesion(
  usuarioId,
  nombre,
  contrasena,
  email,
  foto,
  tokenFCM,
  jwtToken: loginResponse['token'], // JWT se guarda aquí
);
```

### 2. **Peticiones Automáticas con JWT**
```dart
// Antes (sin JWT)
final response = await http.get(
  url,
  headers: {'Content-Type': 'application/json'},
);

// Ahora (con JWT automático)
final headers = await AuthService.getAuthHeaders();
final response = await http.get(url, headers: headers);

// Los headers incluyen automáticamente:
// {
//   'Content-Type': 'application/json; charset=UTF-8',
//   'Accept': 'application/json',
//   'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
// }
```

### 3. **Manejo Automático de Errores de Autenticación**
```dart
// Si el servidor responde 401 (token inválido/expirado)
AuthService.handleHttpResponse(response);
// - Elimina automáticamente el token inválido
// - Redirige al usuario a la pantalla de login
```

## 🛡️ Endpoints Protegidos

### Rutas Públicas (No requieren JWT):
- `POST /usuario/validar` - Login
- `POST /usuario/crear-usuario` - Registro
- `GET /usuario/verificar-correo/:email` - Verificar email
- `POST /usuario/solicitar-recuperacion` - Solicitar reset
- `PUT /usuario/restablecer-contrasena` - Reset con token
- `GET /usuario/verificar-token/:token` - Verificar token reset

### Rutas Protegidas (Requieren JWT):
- **Usuarios**: Todas las operaciones CRUD, foto de perfil, actualizaciones
- **Tareas**: Crear, leer, actualizar, eliminar tareas
- **Listas**: Crear, leer, actualizar, eliminar listas
- **Categorías**: Todas las operaciones
- **Etiquetas**: Todas las operaciones
- **Recordatorios**: Todas las operaciones
- **Estados**: Consultar estados disponibles
- **Prioridades**: Consultar prioridades disponibles

## 📋 Ejemplo de Uso Completo

### Crear una Nueva Tarea
```dart
// El servicio maneja automáticamente el JWT
final tareaService = TareaService();

final response = await tareaService.crearTareaConEtiquetas(
  usuarioId: usuarioId,
  listaId: listaId,
  titulo: "Mi nueva tarea",
  descripcion: "Descripción de la tarea",
  fechaCreacion: DateTime.now().toIso8601String(),
  fechaVencimiento: DateTime.now().add(Duration(days: 7)).toIso8601String(),
  categoriaId: 1,
  estadoId: 1,
  prioridadId: 2,
  etiquetas: [1, 2, 3],
);

// Si el JWT es inválido, el usuario será redirigido automáticamente al login
```

### Verificar Estado de Sesión
```dart
// Verificar si hay una sesión válida con JWT
final controladorSesion = Get.find<ControladorSesionUsuario>();
bool sesionValida = await controladorSesion.esSesionValida();

if (!sesionValida) {
  // Redirigir a login
  Get.offAllNamed('/sign-in');
}
```

## 🔧 Configuración Adicional

### 1. **Interceptor para Peticiones HTTP** (Opcional)
Si quieres agregar un interceptor global para todas las peticiones HTTP:

```dart
// En main.dart o donde configures tu app
class HttpInterceptor {
  static Future<http.Response> get(Uri url) async {
    final headers = await AuthService.getAuthHeaders();
    final response = await http.get(url, headers: headers);
    AuthService.handleHttpResponse(response);
    return response;
  }
  
  static Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    final authHeaders = await AuthService.getAuthHeaders();
    final response = await http.post(url, headers: authHeaders, body: body);
    AuthService.handleHttpResponse(response);
    return response;
  }
}
```

### 2. **Middleware de Verificación**
Para proteger rutas específicas en tu app:

```dart
class AuthMiddleware {
  static Future<bool> checkAuth() async {
    final hasToken = await AuthService.hasValidToken();
    if (!hasToken) {
      Get.offAllNamed('/sign-in');
      return false;
    }
    return true;
  }
}
```

## ⚠️ Consideraciones Importantes

1. **Token Expiration**: El backend debe manejar la expiración de tokens
2. **Refresh Tokens**: Considera implementar refresh tokens para sesiones largas
3. **Logout**: El método `cerrarSesion()` elimina automáticamente el JWT
4. **Seguridad**: Los tokens se almacenan localmente usando SharedPreferences

## 🐛 Debugging

Para debuggear problemas con JWT:

```dart
// Verificar si hay token
String? token = await AuthService.getJwtToken();
print('JWT Token: $token');

// Verificar headers
Map<String, String> headers = await AuthService.getAuthHeaders();
print('Headers: $headers');
```

## ✅ Estado Actual

- ✅ JWT implementado en todos los servicios
- ✅ Almacenamiento automático del token al login
- ✅ Headers automáticos en todas las peticiones
- ✅ Manejo automático de respuestas 401
- ✅ Verificación de sesión al iniciar la app
- ✅ Limpieza de token al cerrar sesión
- ✅ Servicios de Estado y Prioridad actualizados

¡Tu aplicación ahora está completamente integrada con el sistema JWT de tu backend!
