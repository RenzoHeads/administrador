// =============== ListasGridWidget.dart ===============
import 'package:flutter/material.dart';
import '../../widgets/lista/lista_item.dart';
import '../../../models/lista.dart';
import '../../listas/visualizar-lista/visualizar_lista_page.dart';

class ListasGridWidget extends StatelessWidget {
  final List<Lista> listas;
  final Function(int) onTap;

  const ListasGridWidget({Key? key, required this.listas, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (listas.isEmpty) {
      return const Center(child: Text('No hay listas disponibles'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: listas.length,
      itemBuilder: (context, index) {
        final lista = listas[index];
        return ListaItemWidget(
          key: ValueKey(lista.id),
          listaId: lista.id!,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VisualizarListaPage(listaId: lista.id!),
              ),
            );
          },
        );
      },
    );
  }
}
