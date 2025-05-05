import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_links/app_links.dart';

class DeepLinkingHandler {
  static bool _initialUriHandled = false;

  static Future<void> setupDeepLinks(BuildContext context) async {
    final appLinks = AppLinks();

    // Manejar enlaces entrantes con la app en foreground/background
    appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleDeepLink(context, uri);
        }
      },
      onError: (err) {
        debugPrint('Error en stream de links: $err');
      },
    );

    // Manejar enlace inicial al abrir la app
    if (!_initialUriHandled) {
      try {
        // Método correcto para obtener el enlace inicial
        final Uri? initialUri = await appLinks.getInitialLink();
        if (initialUri != null) {
          _initialUriHandled = true;
          _handleDeepLink(context, initialUri);
        }
      } on PlatformException catch (e) {
        debugPrint('Error de plataforma: ${e.message}');
      } on FormatException catch (e) {
        debugPrint('Error de formato: ${e.message}');
      }
    }
  }

  static void _handleDeepLink(BuildContext context, Uri uri) {
    debugPrint('Deep Link Recibido: ${uri.toString()}');

    if (uri.scheme == 'miappflutter' && uri.host == 'recuperar') {
      final token = uri.queryParameters['token'];

      if (token != null && token.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(
            context,
          ).pushNamed('/reset-with-token', arguments: {'token': token});
        });
      }
    }
  }
}
