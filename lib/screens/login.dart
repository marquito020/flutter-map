import 'package:app_movil/constants/colors.dart';
import 'package:app_movil/controllers/authController.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_backend.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

/* Controller Login */
var emailController = TextEditingController();
var passwordController = TextEditingController();

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
          )), */
      body: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 30, left: 25),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                'Bienvenido de nuevo',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.grey,
                    ),
                    /* prefixIconConstraints: BoxConstraints(
                      minWidth: 0,
                      minHeight: 50,
                    ), */
                    suffixIcon: Icon(
                      Icons.check,
                      color: Colors.grey,
                    ),
                    suffixIconConstraints: BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Colors.grey,
                    ),
                    /* prefixIconConstraints: BoxConstraints(
                      minWidth: 0,
                      minHeight: 50,
                    ), */
                    constraints: BoxConstraints.expand(height: 50),
                    suffixIcon: Icon(
                      Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    suffixIconConstraints: BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      /* Navigator.pushReplacementNamed(
                          context, '/solicitarViaje'); */
                      login();
                      /* AuthController()
                          .login(emailController.text, passwordController.text); */
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Text(
                        'Ingresar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: containerprimary,
                        ),
                      ),
                    ),
                  ),
                ),

                /* Register */
                SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿No tienes una cuenta?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            'Regístrate',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void login() async {
    var email = emailController.text;
    var password = passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      var response = await http.post(
        Uri.parse('$apiBackend/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "correo": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print(response.statusCode);
        if (jsonResponse['user'] != null) {
          SharedPreferences user = await SharedPreferences.getInstance();
          user.setString('token', jsonResponse['token']);
          user.setString('correo', jsonResponse['user']['correo']);
          user.setString('nombre', jsonResponse['user']['nombre']);
          user.setString('nro_registro', jsonResponse['user']['nro_registro']);
          user.setInt('id', jsonResponse['user']['id']);

          print("Ingresado");
          Navigator.pushReplacementNamed(context, '/solicitarViaje');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario o contraseña incorrectos'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al iniciar sesión'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese todos los campos'),
        ),
      );
    }
  }
}
