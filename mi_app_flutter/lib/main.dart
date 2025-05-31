import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'services/controladorsesion.dart';
import 'services/usuario_service.dart';

import 'pages/sign_in/sign_in_page.dart';
import 'pages/sign_up/sign_up_page.dart';
import 'pages/reset/reset_page.dart';
import 'pages/reset/reset_token.dart';
import 'pages/tareas/crear_tarea_page.dart';
import 'pages/tareas/editar_tarea_page.dart';
import 'pages/principal/principal_page.dart';

/// Manejo de notificaciones en segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔕 Notificación en segundo plano: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);

  // Configurar notificaciones en background antes de inicializar Firebase
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp();

  // Configurar el canal de notificaciones
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Escuchar cambio de token FCM
  FirebaseMessaging.instance.onTokenRefresh.listen((nuevoToken) async {
    print("🔄 Token FCM actualizado: $nuevoToken");

    final sesion = Get.find<ControladorSesionUsuario>();
    if (sesion.sesionIniciada.value && sesion.usuarioActual.value != null) {
      final id = sesion.usuarioActual.value!.id!;
      await UsuarioService().updateUserTokenFCM(id, nuevoToken);
    }
  });

  // Inyectar controlador de sesión permanentemente
  Get.put(ControladorSesionUsuario(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    // Notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print(' Notificación en primer plano: ${message.notification!.title}');
        Get.snackbar(
          message.notification!.title ?? 'Notificación',
          message.notification!.body ?? '',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      title: 'Administrador de Tareas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => SplashScreen()),
        GetPage(name: '/main', page: () => const PrincipalPage()),
        GetPage(name: '/sign-in', page: () => SignInPage()),
        GetPage(name: '/sign-up', page: () => SignUpPage()),
        GetPage(name: '/reset', page: () => ResetPage()),
        GetPage(name: '/reset-with-token', page: () => ResetTokenPage()),
        GetPage(name: '/crear-tarea', page: () => CrearTareaPage()),
        GetPage(name: '/editar-tarea', page: () => EditarTareaPage()),
      ],
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ControladorSesionUsuario sesionControlador = Get.find();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  _checkAuthentication() async {
    await sesionControlador.verificarEstadoSesion();
    Future.delayed(const Duration(seconds: 1), () {
      if (sesionControlador.sesionIniciada.value) {
        Get.offAllNamed('/main');
      } else {
        Get.offAllNamed('/sign-in');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
