import 'package:flutter/material.dart';
import 'pages/home/home_page.dart';
import 'pages/sign_in/sign_in_page.dart';
import 'pages/sign_up/sign_up_page.dart';
import 'pages/reset/reset_page.dart';
import 'package:get/get.dart';
import 'services/controladorsesion.dart';
import 'pages/listas/lista_crear.dart';
import 'manejador_token.dart';
import 'pages/reset/reset_token.dart';
import 'package:app_links/app_links.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- AÑADE ESTA LÍNEA
import 'pages/tareas/crear_tarea_page.dart';
import 'pages/listas/lista_crear.dart';
import 'pages/tareas/ver_tarea_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null); // <-- AÑADE ESTA LÍNEA
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkingHandler.setupDeepLinks(navigatorKey.currentContext!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
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
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/sign-in', page: () => SignInPage()),
        GetPage(name: '/sign-up', page: () => SignUpPage()),
        GetPage(name: '/reset', page: () => ResetPage()),
        GetPage(name: '/reset-with-token', page: () => ResetTokenPage()),
        GetPage(name: '/crear-tarea', page: () => CrearTareaPage()),
        GetPage(name: '/crear-lista', page: () => CrearListaPage()),
        GetPage(name: '/ver-tarea', page: () => VerTareaPage()),
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
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/sign-in');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
