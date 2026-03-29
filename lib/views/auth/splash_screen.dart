import 'package:flutter/material.dart';
import 'package:gestorgalpon_app/services/auth_service.dart';
import 'package:gestorgalpon_app/views/Home.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Pequeña pausa para mostrar el splash
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final loggedIn = await AuthService.isLoggedIn();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => loggedIn ? const MenuImagen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade300,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Image(
                image: AssetImage('assets/images/smartGalpon_icon.png'),
                width: 80,
                height: 80,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SmartGalpon',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.black54),
          ],
        ),
      ),
    );
  }
}