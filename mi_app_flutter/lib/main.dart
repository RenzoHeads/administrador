import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'services/controladorsesion.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/sign_in/sign_in_page.dart';
import 'pages/sign_up/sign_up_page.dart';
import 'pages/reset/reset_page.dart';
import 'manejador_token.dart';
import 'pages/reset/reset_token.dart';
import 'pages/tareas/crear_tarea_page.dart';
import 'pages/listas/lista_crear.dart';
import 'pages/home/home_page.dart';
import 'pages/calendario/calendario_page.dart';
import 'pages/buscador/buscador_page.dart';
import 'pages/notificaciones/notificacion_page.dart';
import 'pages/widgets/custom_fab.dart';
import 'pages/tareas/editar_tarea_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
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
        GetPage(
          name: '/main',
          page: () => const MainLayout(),
        ), // Main layout fijo
        GetPage(name: '/sign-in', page: () => SignInPage()),
        GetPage(name: '/sign-up', page: () => SignUpPage()),
        GetPage(name: '/reset', page: () => ResetPage()),
        GetPage(name: '/reset-with-token', page: () => ResetTokenPage()),
        GetPage(name: '/crear-tarea', page: () => CrearTareaPage()),
        GetPage(name: '/crear-lista', page: () => CrearListaPage()),
        //editar tarea con tarea id de paraametro
        GetPage(
          name: '/editar-tarea/:id',
          page:
              () => EditarTareaPage(
                tareaId: int.tryParse(Get.parameters['id'] ?? '') ?? 0,
              ),
        ),
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
        Get.offAllNamed('/main'); // Ir al layout con barra inferior
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

// MAIN LAYOUT FIJO CON BOTTOM NAV BAR
class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    CalendarioPage(),
    BuscadorPage(),
    NotificacionPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),

      floatingActionButton: CustomFAB(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    this.currentIndex = 0,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/icon_home.svg',
                color: currentIndex == 0 ? Colors.green : Colors.grey,
                width: 24,
                height: 24,
              ),
              onPressed: () => onTap(0),
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/icon_calendar.svg',
                color: currentIndex == 1 ? Colors.green : Colors.grey,
                width: 24,
                height: 24,
              ),
              onPressed: () => onTap(1),
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/icon_search.svg',
                color: currentIndex == 2 ? Colors.green : Colors.grey,
                width: 24,
                height: 24,
              ),
              onPressed: () => onTap(2),
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/icon_bell.svg',
                color: currentIndex == 3 ? Colors.green : Colors.grey,
                width: 24,
                height: 24,
              ),
              onPressed: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}
