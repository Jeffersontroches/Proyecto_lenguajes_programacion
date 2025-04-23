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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchInscripciones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No estás inscrito en ninguna publicación."),
            );
          }

          final publicaciones = snapshot.data!;

          return ListView.builder(
            itemCount: publicaciones.length,
            itemBuilder: (context, index) {
              final pub = publicaciones[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(pub['titulo']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Área: ${pub['area']}"),
                      Text("Fecha: ${pub['fecha'].toString().split(' ')[0]}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _desuscribirse(pub['inscripcionId']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
