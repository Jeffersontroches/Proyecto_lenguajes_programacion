import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/models/Publicacion.dart';
import 'package:proyecto/pages/ListadoInscritosPage.dart';
import 'package:proyecto/pages/create_publicacion_page.dart';

class DetallePublicacionPage extends StatefulWidget {
  final Publicaciones publicacion;

  const DetallePublicacionPage({super.key, required this.publicacion});

  @override
  State<DetallePublicacionPage> createState() => _DetallePublicacionPageState();
}

class _DetallePublicacionPageState extends State<DetallePublicacionPage> {
  bool _inscrito = false;
  int _inscritosCount = 0;

  @override
  void initState() {
    super.initState();
    verificarEstado();
  }

  Future<void> verificarEstado() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final firestore = FirebaseFirestore.instance;

    final query =
        await firestore
            .collection('inscritos')
            .where('userId', isEqualTo: user.uid)
            .where('idPublicacion', isEqualTo: widget.publicacion.id)
            .limit(1)
            .get();

    final inscritos =
        await firestore
            .collection('inscritos')
            .where('idPublicacion', isEqualTo: widget.publicacion.id)
            .get();

    if (mounted) {
      setState(() {
        _inscrito = query.docs.isNotEmpty;
        _inscritosCount = inscritos.docs.length;
      });
    }
  }

  Future<void> eliminarPublicacion() async {
    final firestore = FirebaseFirestore.instance;

    // Eliminar los registros de inscritos para esta publicación
    final inscritosQuery =
        await firestore
            .collection('inscritos')
            .where('idPublicacion', isEqualTo: widget.publicacion.id)
            .get();

    for (var doc in inscritosQuery.docs) {
      await doc.reference.delete();
    }

    // Eliminar la publicación
    await firestore
        .collection('publicacion')
        .doc(widget.publicacion.id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String currentUserId = user?.uid ?? '';

    final bool cuposLlenos = _inscritosCount >= widget.publicacion.cupos;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Publicación')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              widget.publicacion.titulo,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Info cards
            InfoCard(
              label: 'Descripción',
              value: widget.publicacion.descripcion,
            ),
            InfoCard(label: 'Área', value: widget.publicacion.area),
            InfoCard(label: 'Horas', value: '${widget.publicacion.horas}'),
            InfoCard(
              label: 'Cupos',
              value: '$_inscritosCount/${widget.publicacion.cupos}',
            ),
            InfoCard(
              label: 'Fecha',
              value:
                  '${widget.publicacion.fecha.toLocal().day}/${widget.publicacion.fecha.toLocal().month}/${widget.publicacion.fecha.toLocal().year}',
            ),
            const SizedBox(height: 10),

            if (widget.publicacion.userId == currentUserId) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: const Text("¿Eliminar publicación?"),
                          content: const Text(
                            "¿Estás seguro de que deseas eliminar esta publicación?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("Eliminar"),
                            ),
                          ],
                        ),
                  );

                  if (confirm == true) {
                    await eliminarPublicacion();

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Publicación y registros eliminados'),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete),
                label: const Text('Eliminar'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ListadoInscritosPage(
                            publicacionId: widget.publicacion.id!,
                          ),
                    ),
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text('Listado de inscritos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CreatePublicacionPage(
                            publicacion: widget.publicacion,
                          ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            const SizedBox(height: 10),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed:
                  (_inscrito || cuposLlenos)
                      ? null
                      : () async {
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('inscritos')
                              .add({
                                'userId': user.uid,
                                'nombre': user.displayName ?? 'Sin nombre',
                                'email': user.email ?? 'Sin correo',
                                'idPublicacion': widget.publicacion.id,
                                'timestamp': FieldValue.serverTimestamp(),
                              });

                          if (context.mounted) {
                            setState(() {
                              _inscrito = true;
                              _inscritosCount++;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Inscripción exitosa'),
                              ),
                            );
                          }
                        }
                      },
              icon: const Icon(Icons.how_to_reg),
              label: Text(
                _inscrito
                    ? 'Ya inscrito'
                    : cuposLlenos
                    ? 'Cupos llenos'
                    : 'Inscribirse',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    (_inscrito || cuposLlenos) ? Colors.grey : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const InfoCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Expanded(
                  child: Text(value, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
