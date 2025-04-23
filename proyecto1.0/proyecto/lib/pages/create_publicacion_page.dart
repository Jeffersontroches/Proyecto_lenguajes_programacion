import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto/models/Publicacion.dart';
import 'package:proyecto/widgets/CustomTextField.dart';

class CreateMoviePage extends StatefulWidget {
  const CreateMoviePage({super.key});

  @override
  State<CreateMoviePage> createState() => _CreateMoviePageState();
}

class _CreateMoviePageState extends State<CreateMoviePage> {
  final titulo = TextEditingController(text: 'Ingrese título');
  final descripcion = TextEditingController(text: 'ingrese descripcion');
  final cupos = TextEditingController(text: 'cupos Disponibles');
  final horas = TextEditingController(text: 'Horas a asignar');
  final fechaController = TextEditingController();

  DateTime? selectedDateTime;

  final FocusNode tituloFocus = FocusNode();
  final FocusNode descripcionFocus = FocusNode();
  final FocusNode cuposFocus = FocusNode();
  final FocusNode horasFocus = FocusNode();

  final List<String> areaOptions = [
    'academico-cientifico',
    'Deportivas',
    'sociales',
    'Artisticoculturales',
  ];
  String selectedArea = 'Deportivas';

  @override
  void initState() {
    super.initState();
    tituloFocus.addListener(() {
      if (tituloFocus.hasFocus && titulo.text == 'Ingrese título') {
        titulo.clear();
      }
    });
    descripcionFocus.addListener(() {
      if (descripcionFocus.hasFocus &&
          descripcion.text == 'ingrese descripcion') {
        descripcion.clear();
      }
    });
    cuposFocus.addListener(() {
      if (cuposFocus.hasFocus && cupos.text == 'cupos Disponibles') {
        cupos.clear();
      }
    });
    horasFocus.addListener(() {
      if (horasFocus.hasFocus && horas.text == 'Horas a asignar') {
        horas.clear();
      }
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDateTime = pickedDate;
        fechaController.text =
            '${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}';
      });
    }
  }

  @override
  void dispose() {
    tituloFocus.dispose();
    descripcionFocus.dispose();
    cuposFocus.dispose();
    horasFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 202, 225, 255),
        title: const Text('Crear Película'),
      ),
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: titulo,
                  focusNode: tituloFocus,
                  hint: 'Título',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: descripcion,
                  focusNode: descripcionFocus,
                  hint: 'Descripción',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: cupos,
                  focusNode: cuposFocus,
                  hint: 'Cupos',
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: horas,
                  focusNode: horasFocus,
                  hint: 'Horas',
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _selectDateTime(context),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      focusNode: FocusNode(),

                      controller: fechaController,
                      hint: 'Selecciona Fecha',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Seleccione área',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedArea,
                        dropdownColor: Colors.blue.shade800,
                        style: const TextStyle(color: Colors.white),
                        items:
                            areaOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedArea = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Verificar que la fecha esté seleccionada
          if (selectedDateTime != null && horas.text.isNotEmpty) {
            // Aseguramos que la fecha esté en el formato correcto (zona horaria local)
            final finalDateTime = DateTime(
              selectedDateTime!.year,
              selectedDateTime!.month,
              selectedDateTime!.day,
              DateTime.now().hour,
              DateTime.now().minute,
            );

            Publicaciones data = Publicaciones(
              id: null,
              titulo: titulo.text,
              descripcion: descripcion.text,
              cupos: int.parse(cupos.text),
              fecha: finalDateTime, // Usamos la fecha en la zona horaria local
              horas: int.parse(horas.text),
              area: selectedArea,
            );

            final newDoc = await FirebaseFirestore.instance
                .collection('publicacion')
                .add(data.toFirestoreDataBase());

            if (!context.mounted) return;

            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('publicación ${data.titulo} creada')),
            );
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
