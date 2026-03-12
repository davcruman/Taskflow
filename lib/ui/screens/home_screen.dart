import 'package:flutter/material.dart';
// Importa aquí el servicio de tu colega cuando lo tenga
// import '../../data/services/auth_service.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool isLogin = true; // Controla si estamos en login o registro
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      
      // AQUÍ LLAMARÁS A LAS FUNCIONES DE TU COLEGA (Persona B)
      // Ejemplo: 
      // if (isLogin) { await AuthService().iniciarSesion(...) } 
      // else { await AuthService().registrarUsuario(...) }

      await Future.delayed(const Duration(seconds: 2)); // Simulación
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Icon(Icons.task_alt, size: 100, color: Theme.of(context).primaryColor),
                const SizedBox(height: 20),
                Text(isLogin ? "Bienvenido" : "Crear Cuenta", 
                     style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                
                // Campo Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                  validator: (value) => (value == null || !value.contains('@')) ? "Email no válido" : null,
                ),
                const SizedBox(height: 15),
                
                // Campo Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Contraseña", border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.length < 6) ? "Mínimo 6 caracteres" : null,
                ),
                const SizedBox(height: 30),

                // Botón Principal
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading 
                      ? const CircularProgressIndicator() 
                      : Text(isLogin ? "Entrar" : "Registrarse"),
                  ),
                ),

                // Botón Secundario para cambiar modo
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(isLogin 
                    ? "¿No tienes cuenta? Regístrate" 
                    : "¿Ya tienes cuenta? Inicia sesión"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}