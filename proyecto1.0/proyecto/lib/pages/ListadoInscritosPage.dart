import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListadoInscritosPage extends StatelessWidget {
  final String publicacionId;

  const ListadoInscritosPage({super.key, required this.publicacionId});

  @override
  Widget build(BuildContext context) {
    final inscritosRef = FirebaseFirestore.instance
        .collection('inscritos')
        .where('idPublicacion', isEqualTo: publicacionId);

    return Scaffold(
      appBar: AppBar(title: const Text('Listado de Inscritos')),
      body: StreamBuilder<QuerySnapshot>(
        stream: inscritosRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No hay inscritos aún.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final nombre = data['nombre'] ?? 'Sin nombre';
              final email = data['email'] ?? 'Sin correo';

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(nombre),
                subtitle: Text(email),
              );
            },
          );
        },
      ),
    );
  }
}
