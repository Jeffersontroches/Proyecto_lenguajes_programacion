import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;

  Map<String, dynamic> horas = {
    'Academico': 0,
    'Deportivo': 0,
    'Social': 0,
    'Artístico-cultural': 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchHoras();
  }

  Future<void> _fetchHoras() async {
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('horas')
              .doc(user!.uid)
              .get();
      if (doc.exists) {
        setState(() {
          horas = {
            'Academico': doc['Academico'] ?? 0,
            'Deportivo': doc['Deportivo'] ?? 0,
            'Social': doc['Social'] ?? 0,
            'Artístico-cultural': doc['Artístico-cultural'] ?? 0,
          };
        });
      }
    }
  }

  void _mostrarDialogoActualizar() {
    final TextEditingController academicoController = TextEditingController(
      text: horas['Academico'].toString(),
    );
    final TextEditingController deportivoController = TextEditingController(
      text: horas['Deportivo'].toString(),
    );
    final TextEditingController socialController = TextEditingController(
      text: horas['Social'].toString(),
    );
    final TextEditingController artisticoController = TextEditingController(
      text: horas['Artístico-cultural'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Actualizar horas'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: academicoController,
                  decoration: const InputDecoration(labelText: 'Académico'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: deportivoController,
                  decoration: const InputDecoration(labelText: 'Deportivo'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: socialController,
                  decoration: const InputDecoration(labelText: 'Social'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: artisticoController,
                  decoration: const InputDecoration(
                    labelText: 'Artístico-cultural',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('horas')
                    .doc(user!.uid)
                    .set({
                      'Academico': int.parse(academicoController.text),
                      'Deportivo': int.parse(deportivoController.text),
                      'Social': int.parse(socialController.text),
                      'Artístico-cultural': int.parse(artisticoController.text),
                    });
                Navigator.pop(context);
                await _fetchHoras();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 245, 255),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  user?.photoURL ??
                      'https://ui-avatars.com/api/?name=User&background=random',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                user?.displayName ?? 'Nombre de Usuario',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                user?.email ?? 'Correo Electrónico',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    horas.entries.map((entry) {
                      return Container(
                        width: MediaQuery.of(context).size.width / 2 - 24,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 224, 235, 255),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              entry.value.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.key,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Actualizar Horas"),
                onPressed: _mostrarDialogoActualizar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 102, 255),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Cerrar Sesión"),
                onPressed: _cerrarSesion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
