import 'package:flutter/material.dart';
import 'package:proyecto/models/Publicacion.dart';

class DetallePublicacionPage extends StatelessWidget {
  final Publicaciones publicacion;

  const DetallePublicacionPage({super.key, required this.publicacion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(publicacion.titulo)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Título: ${publicacion.titulo}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text('Descripción: ${publicacion.descripcion}'),
            SizedBox(height: 8),
            Text('Área: ${publicacion.area}'),
            SizedBox(height: 8),
            Text('Horas: ${publicacion.horas}'),
            SizedBox(height: 8),
            Text('Cupos: ${publicacion.cupos}'),
            SizedBox(height: 8),
            Text('Fecha: ${publicacion.fecha.toLocal()}'),
          ],
        ),
      ),
    );
  }
}
