import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gestorgalpon_app/layouts/components/inputtext.dart';
import 'package:gestorgalpon_app/models/licencia/licencia.dart';
import 'package:gestorgalpon_app/services/licencia/guardarLiscencia.dart';
import 'package:gestorgalpon_app/views/Home.dart';
import 'package:gestorgalpon_app/models/licencia/licencia.dart'; // tu clase Licencia

class LicenciaInvalidaScreen extends StatefulWidget {
  const LicenciaInvalidaScreen({super.key});

  @override
  State<LicenciaInvalidaScreen> createState() => _LicenciaInvalidaScreenState();
}

class _LicenciaInvalidaScreenState extends State<LicenciaInvalidaScreen> {
  String? _deviceId;
  final TextEditingController _licenciaController = TextEditingController();
  String _mensaje = "";

  @override
  void initState() {
    super.initState();
    cargarDeviceId();
  }

  Future<void> cargarDeviceId() async {
    final id = await LicenciaService.getDeviceId();
    setState(() {
      _deviceId = id;
    });
  }

  Future<void> validarLicencia() async {
  try {
    final licenciaTexto = _licenciaController.text.trim();

    if (licenciaTexto.isEmpty || _deviceId == null) {
      setState(() {
        _mensaje = "Por favor, ingrese la licencia.";
      });
      return;
    }

    try {
      // Intentar parsear el JSON de la licencia
      final Map<String, dynamic> jsonData = json.decode(licenciaTexto);
      final licencia = Licencia.fromJson(jsonData);

      if (licencia.esValida(_deviceId!)) {
        await LicenciaService.guardarLicencia(licencia);
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MenuImagen()),
        );
      } else {
        setState(() {
          _mensaje = "Licencia inválida o no corresponde a este dispositivo.";
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = "Error al procesar la licencia. Asegúrate de pegar todo completo desde el '{' hasta el '}'.";
      });
    }
  } catch (e) {
    setState(() {
      _mensaje = "Error inesperado: $e";
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Licencia vencida')),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _deviceId == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Tu licencia es inválida o ha expirado.',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Este es tu ID de dispositivo:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SelectableText(
                      _deviceId!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Cópialo y envíalo para que te generen una nueva licencia.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Si ya tienes una nueva licencia, ingrésala a continuación:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // Input para pegar la licencia
                    TextField(
                      controller: _licenciaController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Pega aquí tu licencia",
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 15),

                    ElevatedButton(
                      onPressed: validarLicencia,
                      child: const Text("Activar"),
                    ),

                    const SizedBox(height: 6),
                    Text(
                      _mensaje,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
