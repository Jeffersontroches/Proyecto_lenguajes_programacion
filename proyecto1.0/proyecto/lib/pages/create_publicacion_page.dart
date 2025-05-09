import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/models/Publicacion.dart';
import 'package:proyecto/widgets/CustomTextField.dart';

class CreatePublicacionPage extends StatefulWidget {
  final Publicaciones? publicacion;

  const CreatePublicacionPage({super.key, this.publicacion});

  @override
  State<CreatePublicacionPage> createState() => CreatePublicacionPageState();
}

class CreatePublicacionPageState extends State<CreatePublicacionPage> {
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

    final pub = widget.publicacion;
    if (pub != null) {
      titulo.text = pub.titulo;
      descripcion.text = pub.descripcion;
      cupos.text = pub.cupos.toString();
      horas.text = pub.horas.toString();
      selectedDateTime = pub.fecha;
      fechaController.text =
          '${pub.fecha.day.toString().padLeft(2, '0')}/${pub.fecha.month.toString().padLeft(2, '0')}/${pub.fecha.year}';
      selectedArea = pub.area;
    }

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
    final isEditing = widget.publicacion != null;
    final labelStyle = TextStyle(
      color: Colors.white.withOpacity(0.9),
      fontSize: 16,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 202, 225, 255),
        title: Text(isEditing ? 'Editar Publicación' : 'Crear Publicación'),
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
            padding: const EdgeInsets.all(19.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Título', style: labelStyle),
                CustomTextField(
                  controller: titulo,
                  focusNode: tituloFocus,
                  hint: 'Título',
                ),
                const SizedBox(height: 5),

                Text('Descripción', style: labelStyle),
                CustomTextField(
                  controller: descripcion,
                  focusNode: descripcionFocus,
                  hint: 'Descripción',
                ),
                const SizedBox(height: 5),

                Text('Cupos disponibles', style: labelStyle),
                CustomTextField(
                  controller: cupos,
                  focusNode: cuposFocus,
                  hint: 'Cupos',
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 5),

                Text('Horas a asignar', style: labelStyle),
                CustomTextField(
                  controller: horas,
                  focusNode: horasFocus,
                  hint: 'Horas',
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 5),

                Text('Fecha de la actividad', style: labelStyle),
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
                const SizedBox(height: 5),

                Text('Seleccione área', style: labelStyle),
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
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (selectedDateTime == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Por favor selecciona una fecha.')),
            );
            return;
          }

          if (cupos.text.isEmpty || horas.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Por favor completa los campos de cupos y horas.',
                ),
              ),
            );
            return;
          }

          final cuposValue = int.tryParse(cupos.text);
          final horasValue = int.tryParse(horas.text);

          if (cuposValue == null || horasValue == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Los campos de cupos y horas solo deben contener números.',
                ),
              ),
            );
            return;
          }

          final finalDateTime = DateTime(
            selectedDateTime!.year,
            selectedDateTime!.month,
            selectedDateTime!.day,
            DateTime.now().hour,
            DateTime.now().minute,
          );

          final userId = FirebaseAuth.instance.currentUser?.uid;

          if (userId != null) {
            final isEditing = widget.publicacion != null;
            final docRef =
                isEditing
                    ? FirebaseFirestore.instance
                        .collection('publicacion')
                        .doc(widget.publicacion!.id)
                    : FirebaseFirestore.instance
                        .collection('publicacion')
                        .doc();

            Publicaciones data = Publicaciones(
              id: docRef.id,
              titulo: titulo.text,
              descripcion: descripcion.text,
              cupos: cuposValue,
              fecha: finalDateTime,
              horas: horasValue,
              area: selectedArea,
              userId: userId,
            );

            await docRef.set(data.toFirestoreDataBase());

            if (!context.mounted) return;

            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isEditing ? 'Publicación actualizada' : 'Publicación creada',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo obtener el ID del usuario'),
              ),
            );
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
