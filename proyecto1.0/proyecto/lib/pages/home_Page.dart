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
      // appBar: AppBar(
      //   title: const Text('Horas voae'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.logout),
      //       onPressed: () async {
      //         await FirebaseAuth.instance.signOut();
      //         if (!context.mounted) return;
      //         Navigator.of(context).pushReplacementNamed('/login');
      //       },
      //     ),
      //   ],
      // ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('publicacion')
                .withConverter<Publicaciones>(
                  fromFirestore: (snapshot, _) {
                    final data = snapshot.data()!;
                    data['id'] = snapshot.id; //id del documento

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
            return Center(child: CircularProgressIndicator());
          }

          print(snapshot.data);

          if (snapshot.hasError) {
            return Center(child: Text('Error: ' + snapshot.error.toString()));
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'No hay informacion de publicaciones ' +
                    snapshot.error.toString(),
              ),
            );
          }
          final publicacion =
              snapshot.data!.docs.map((doc) => doc.data()).toList();

          // final publicacion  = List<Map<String, dynamic>>.from(
          //   snapshot.data!.docs.map(
          //     (doc) => doc.data(),
          //   ),
          // );

          if (publicacion.isEmpty) {
            return Center(child: Text('No hay publicaciones'));
          }

          return ListView.builder(
            itemCount: publicacion.length,
            itemBuilder: (context, index) {
              final Publicacion = publicacion[index];

              return Dismissible(
                secondaryBackground: Container(
                  color: Colors.green,
                  child: const Icon(Icons.edit),
                ),
                background: Container(
                  color: Colors.red,
                  child: const Icon(Icons.delete),
                ),
                key: Key(Publicacion.id!),
                child: ListTile(
                  title: Text(Publicacion.titulo),
                  subtitle: Text(Publicacion.descripcion),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => DetallePublicacionPage(
                              publicacion: Publicacion,
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
          ;
        },
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
