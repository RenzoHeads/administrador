import 'package:flutter/material.dart';

class ListaIAModal extends StatefulWidget {
  final Function(String prompt) onGenerar;
  final VoidCallback? onClose;
  const ListaIAModal({Key? key, required this.onGenerar, this.onClose})
    : super(key: key);

  @override
  State<ListaIAModal> createState() => _ListaIAModalState();
}

class _ListaIAModalState extends State<ListaIAModal> {
  final TextEditingController _controller = TextEditingController();
  bool _cargando = false;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.psychology,
                    color: Color(0xFF8B5CF6),
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Generar con IA',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose ?? () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Qué tipo de lista necesitas?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText:
                      'Ejm: Lista de compras para la semana, preparativos para un viaje, tareas para mi proyecto...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF6F7FB),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_box_rounded, color: Colors.white),
                  label:
                      _cargando
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            'Generar Lista',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      _cargando
                          ? null
                          : () async {
                            final prompt = _controller.text.trim();
                            if (prompt.isEmpty) return;
                            setState(() => _cargando = true);
                            await widget.onGenerar(prompt);
                            setState(() => _cargando = false);
                          },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
