import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/models/Publicacion.dart';
import 'package:proyecto/pages/DetallePublicacionPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        if (!context.mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
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
        child: StreamBuilder(
          stream:
              FirebaseFirestore.instance
                  .collection('publicacion')
                  .withConverter<Publicaciones>(
                    fromFirestore: (snapshot, _) {
                      final data = snapshot.data()!;
                      data['id'] = snapshot.id;
                      return Publicaciones.fromJson(data);
                    },
                    toFirestore:
                        (Publicacion, _) => Publicacion.toFirestoreDataBase(),
                  )
                  .orderBy('fecha', descending: false)
                  .snapshots(),
          builder: (
            context,
            AsyncSnapshot<QuerySnapshot<Publicaciones>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No hay publicaciones'));
            }

            final publicaciones =
                snapshot.data!.docs.map((doc) => doc.data()).toList();

            return ListView.builder(
              itemCount: publicaciones.length,
              itemBuilder: (context, index) {
                final publicacion = publicaciones[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => DetallePublicacionPage(
                                publicacion: publicacion,
                              ),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 4,
                      shadowColor: Colors.grey.withOpacity(0.4),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              publicacion.titulo,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),

                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text('Área: ${publicacion.area}'),
                                  backgroundColor: Colors.indigo.shade100,
                                ),
                                Chip(
                                  label: Text('${publicacion.horas} horas'),
                                  backgroundColor: Colors.lightBlue.shade100,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text('Cupos: ${publicacion.cupos}'),
                                  backgroundColor: Colors.green.shade100,
                                ),
                                Text(
                                  'Fecha: ${publicacion.fecha.day}/${publicacion.fecha.month}/${publicacion.fecha.year}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/publicacion');
        },
        child: const Icon(Icons.add),
        tooltip: 'Agregar nueva entrada',
      ),
    );
  }
}
