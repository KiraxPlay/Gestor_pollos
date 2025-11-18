import 'package:flutter/material.dart';
import 'vista_galpones.dart';
import 'ponedoras/vista_ponedoras.dart'; 

class MenuImagen extends StatelessWidget {
  const MenuImagen({super.key});
  static const String pollo = 'assets/images/carga2_galpones.png';
  static const String gallina = 'assets/images/ponedoras.png'; // Asegúrate de tener esta imagen

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bienvenido a SmartGalpon',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.yellow.shade300,
      ),
      backgroundColor: Colors.yellow,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.yellow.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // TARJETA ENGORDE (Lotes de pollos)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VistaLotes(),
                      ),
                    );
                  },
                  child: _buildMenuCard(
                    size: size,
                    imagePath: pollo,
                    title: 'Gestión de Engorde',
                    subtitle: 'Ver tus lotes de pollos',
                  ),
                ),
                const SizedBox(height: 30),
                // TARJETA PONEDORAS
                GestureDetector(
                  onTap: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => const VistaPonedoras(),
                       ),
                    );
                  },
                  child: _buildMenuCard(
                    size: size,
                    imagePath: gallina,
                    title: 'Gestión de Ponedoras',
                    subtitle: 'Ver tus gallinas ponedoras',
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required Size size,
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Container(
          width: size.width * 0.8,
          height: size.height * 0.3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.yellow.shade100,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}