import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/models/Publicacion.dart';
import 'package:proyecto/widgets/actionButon.dart';
import 'package:proyecto/widgets/infoCard.dart';

class DetallePublicacionPage extends StatefulWidget {
  final Publicaciones publicacion;

  const DetallePublicacionPage({super.key, required this.publicacion});

  @override
  State<DetallePublicacionPage> createState() => DetallePublicacionPageState();
}

class DetallePublicacionPageState extends State<DetallePublicacionPage> {
  bool _inscrito = false;
  int _inscritosCount = 0;
  int _totalInscripciones = 0;

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

    final todasInscripciones =
        await firestore
            .collection('inscritos')
            .where('userId', isEqualTo: user.uid)
            .get();

    if (mounted) {
      setState(() {
        _inscrito = query.docs.isNotEmpty;
        _inscritosCount = inscritos.docs.length;
        _totalInscripciones = todasInscripciones.docs.length;
      });
    }
  }

  Future<void> eliminarPublicacion() async {
    final firestore = FirebaseFirestore.instance;

    final inscritosQuery =
        await firestore
            .collection('inscritos')
            .where('idPublicacion', isEqualTo: widget.publicacion.id)
            .get();

    for (var doc in inscritosQuery.docs) {
      await doc.reference.delete();
    }

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
              ActionButton(
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
                icon: Icons.delete,
                label: 'Eliminar',
                color: Colors.red,
              ),
              const SizedBox(height: 10),
              ActionButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/listadoInscritos',
                    arguments: widget.publicacion.id!,
                  );
                },
                icon: Icons.list,
                label: 'Listado de inscritos',
                color: Colors.green,
              ),
              const SizedBox(height: 10),
              ActionButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/crearPublicacion',
                    arguments: widget.publicacion,
                  );
                },
                icon: Icons.edit,
                label: 'Editar',
                color: Colors.orange,
              ),
            ],

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed:
                  (_inscrito || cuposLlenos || _totalInscripciones >= 10)
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
                              _totalInscripciones++;
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
                    : (cuposLlenos
                        ? 'Cupos llenos'
                        : (_totalInscripciones >= 10
                            ? 'Máximo de 10 inscripciones'
                            : 'Inscribirse')),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    (_inscrito || cuposLlenos || _totalInscripciones >= 10)
                        ? Colors.grey
                        : Colors.blue,
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
