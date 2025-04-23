import 'package:cloud_firestore/cloud_firestore.dart';

class Publicaciones {
  String? id;
  String titulo;
  String descripcion;
  int horas;
  int cupos;
  DateTime fecha;
  String area;

  Publicaciones({
    this.id,
    required this.area,
    required this.horas,
    required this.titulo,
    required this.descripcion,
    required this.cupos,
    required this.fecha,
  });

  factory Publicaciones.fromJson(Map<String, dynamic> json) {
    return Publicaciones(
      id: json['id'],
      area: json['area'],
      horas: json['horas'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      cupos: json['cupos'],
      fecha: (json['fecha'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestoreDataBase() {
    return {
      'area': area,
      'horas': horas,
      'titulo': titulo,
      'descripcion': descripcion,
      'cupos': cupos,
      'fecha': fecha,
    };
  }
}
