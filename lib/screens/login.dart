import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
          )),
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
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
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
                      Navigator.pushNamed(context, '/splash');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
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
                          color: Colors.white,
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
                            /* Navigator.pushNamed(context, '/register'); */
                          },
                          child: const Text(
                            'Regístrate',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
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
}