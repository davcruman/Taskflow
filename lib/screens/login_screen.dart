import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); 
  final AuthService _authService = AuthService();

  bool isLogin = true;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose(); 
    super.dispose();
  }

  void _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Introduce un email válido para recuperar la clave")),
      );
      return;
    }

    AppLogger.i("Solicitando reset de clave para $email");
    final error = await _authService.recuperarContrasena(email);
    
    if (mounted) {
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enlace enviado. Revisa tu correo 📧"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    String? error;

    try {
      if (isLogin) {
        error = await _authService.iniciarSesion(_emailController.text, _passwordController.text);
      } else {
        error = await _authService.registrar(
          _emailController.text, 
          _passwordController.text, 
          _nameController.text
        );
      }
    } catch (e) {
      error = "Error inesperado";
    }

    if (mounted) {
      setState(() => isLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Icon(Icons.task_alt, size: 80, color: isDarkMode ? Colors.deepPurpleAccent : Colors.blue),
                const SizedBox(height: 10),
                Text(isLogin ? "Bienvenido" : "Crear Cuenta", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 25),

                // --- CAMPO NOMBRE (Con capitalización de palabras) ---
                if (!isLogin) ...[
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words, // Ej: "juan perez" -> "Juan Perez"
                    decoration: const InputDecoration(
                      labelText: "Nombre Completo", 
                      border: OutlineInputBorder(), 
                      prefixIcon: Icon(Icons.person)
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? "Dinos tu nombre" : null,
                  ),
                  const SizedBox(height: 15),
                ],

                // --- EMAIL (Sin mayúsculas automáticas) ---
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none, // <--- Evita la mayúscula inicial
                  decoration: const InputDecoration(
                    labelText: "Email", 
                    border: OutlineInputBorder(), 
                    prefixIcon: Icon(Icons.email)
                  ),
                  validator: (value) {
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (value == null || !emailRegex.hasMatch(value)) return "Introduce un email real";
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // --- CONTRASEÑA COMPLEJA (Problema 3) ---
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña", 
                    border: OutlineInputBorder(), 
                    prefixIcon: Icon(Icons.lock)
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Escribe una contraseña";
                    
                    // Al menos 8 caracteres, una mayúscula y un número
                    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[0-9]).{8,}$');
                    if (!passwordRegex.hasMatch(value)) {
                      return "Usa 8+ caracteres, una mayúscula y un número";
                    }
                    return null;
                  },
                ),

                if (isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: const Text("¿Olvidaste tu contraseña?", style: TextStyle(fontSize: 13)),
                    ),
                  ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading ? const CircularProgressIndicator() : Text(isLogin ? "Entrar" : "Registrarse"),
                  ),
                ),

                TextButton(
                  onPressed: () => setState(() {
                    isLogin = !isLogin;
                    _formKey.currentState?.reset(); 
                  }),
                  child: Text(isLogin ? "¿No tienes cuenta? Regístrate" : "¿Ya tienes cuenta? Inicia sesión"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}