import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'client/home_screen.dart'; // Asegúrate de que esta ruta sea correcta

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores de texto con los datos predefinidos para facilitar pruebas
  final TextEditingController _emailController = TextEditingController(text: "admin@migna.com");
  final TextEditingController _passController = TextEditingController();

  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      // Intentamos iniciar sesión
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );

      // Si funciona, vamos al Home
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen())
        );
      }
    } on FirebaseAuthException catch (e) {
      // AQUÍ CAPTURAMOS EL ERROR DE FIREBASE (CONTRASEÑA, USUARIO, ETC.)
      String message = "Ocurrió un error desconocido";

      if (e.code == 'user-not-found') {
        message = "No existe un usuario con ese correo.\n¿Lo creaste en la consola de Firebase?";
      } else if (e.code == 'wrong-password') {
        message = "La contraseña es incorrecta.";
      } else if (e.code == 'invalid-credential') {
        message = "Credenciales inválidas o mal formadas.";
      } else {
        message = "Error: ${e.message}";
      }

      _showErrorDialog(message);

    } catch (e) {
      // AQUÍ CAPTURAMOS EL ERROR "PIGEON" O CUALQUIER OTRO
      _showErrorDialog("Error del sistema:\n$e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error de Ingreso"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Entendido"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo limpio
      appBar: AppBar(
        title: const Text("Acceso Administrativo"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo o Icono de seguridad
              const Icon(Icons.security, size: 80, color: Colors.indigo),
              const SizedBox(height: 40),

              // Campo Usuario
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Correo Admin",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),

              // Campo Contraseña
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),

              // Botón Ingresar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("INGRESAR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}