import 'package:flutter/material.dart';

class inputTexto extends StatefulWidget{
  const inputTexto({super.key});

  @override
  State<inputTexto> createState() => _inputTextoState();
}

class _inputTextoState extends State<inputTexto>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context){
    return Form(
      key: _formKey,
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Ingresa la clave de la licencia',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese la clave de la licencia';
          }
          return null;
        },
        onSaved: (value) {
          // Aquí puedes guardar el valor ingresado
          print('Texto ingresado: $value');
        },
      ),
    );
  }
}