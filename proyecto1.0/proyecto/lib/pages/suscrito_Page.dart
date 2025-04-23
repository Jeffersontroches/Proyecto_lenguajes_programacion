import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SuscritoPage extends StatefulWidget {
  const SuscritoPage({super.key});

  @override
  State<SuscritoPage> createState() => _SuscritoPageState();
}

class _SuscritoPageState extends State<SuscritoPage> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  Future<List<Map<String, dynamic>>> _fetchInscripciones() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('inscritos')
            .where('userId', isEqualTo: userId)
            .get();

    List<Map<String, dynamic>> lista = [];

    for (var doc in snapshot.docs) {
      final idPublicacion = doc['idPublicacion'];

      final publicacionSnap =
          await FirebaseFirestore.instance
              .collection('publicacion')
              .doc(idPublicacion)
              .get();

      if (publicacionSnap.exists) {
        lista.add({
          'inscripcionId': doc.id,
          'publicacionId': idPublicacion,
          'titulo': publicacionSnap['titulo'],
          'area': publicacionSnap['area'],
          'fecha': (publicacionSnap['fecha'] as Timestamp).toDate(),
        });
      }
    }

    return lista;
  }

  Future<void> _desuscribirse(String inscripcionId) async {
    await FirebaseFirestore.instance
        .collection('inscritos')
        .doc(inscripcionId)
        .delete();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 202, 225, 255),
              Color.fromARGB(255, 0, 177, 247),
              Color.fromARGB(255, 6, 0, 187),
              Color.fromARGB(255, 13, 0, 110),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Center(
              child: Text(
                "Mis Inscripciones",
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0), // Tono gris suave
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchInscripciones(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No estás inscrito en ninguna publicación.",
                        style: TextStyle(
                          color: Color(0xFFB0BEC5),
                        ), // Tono gris suave
                      ),
                    );
                  }

                  final publicaciones = snapshot.data!;

                  return ListView.builder(
                    itemCount: publicaciones.length,
                    itemBuilder: (context, index) {
                      final pub = publicaciones[index];

                      return Card(
                        color: const Color(0xFFF5F5F5), // Gris muy claro
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(pub['titulo']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Área: ${pub['area']}"),
                              Text(
                                "Fecha: ${pub['fecha'].toString().split(' ')[0]}",
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('¿Estás seguro?'),
                                      content: const Text(
                                        '¿Deseas desuscribirte de esta publicación?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await _desuscribirse(
                                              pub['inscripcionId'],
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Te has desuscrito.',
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text('Sí, eliminar'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
