import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_logger.dart'; // <--- IMPORTANTE

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isLogin = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    AppLogger.i("Pantalla de Login cargada");
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    // Log de validación previa
    if (!_formKey.currentState!.validate()) {
      AppLogger.w("Intento de envío de formulario inválido");
      return;
    }

    setState(() => isLoading = true);
    String? error;

    final action = isLogin ? "LOGIN" : "REGISTRO";
    AppLogger.i("Iniciando proceso de $action para: ${_emailController.text}");

    try {
      if (isLogin) {
        error = await _authService.iniciarSesion(_emailController.text, _passwordController.text);
      } else {
        error = await _authService.registrar(_emailController.text, _passwordController.text);
        if (error == null && mounted) {
          AppLogger.i("Registro exitoso, mostrando SnackBar");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("¡Registro completado! 🎉"), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e, stack) {
      error = "Error inesperado en la interfaz";
      AppLogger.e("Excepción capturada en LoginScreen._submit", e, stack);
    }

    if (mounted) {
      setState(() => isLoading = false);
      if (error != null) {
        AppLogger.w("El proceso de $action falló: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        AppLogger.i("$action completado con éxito");
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.task_alt, 
                  size: 100, 
                  color: isDarkMode ? Colors.deepPurpleAccent : Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  isLogin ? "Bienvenido" : "Crear Cuenta", 
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                  validator: (value) => (value == null || !value.contains('@')) ? "Email no válido" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Contraseña", border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.length < 6) ? "Mínimo 6 caracteres" : null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : Text(isLogin ? "Entrar" : "Registrarse"),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => isLogin = !isLogin);
                    AppLogger.i("Usuario cambió modo de pantalla a: ${isLogin ? 'Login' : 'Registro'}");
                  },
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