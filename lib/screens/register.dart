import 'dart:io';

import 'package:app_movil/constants/colors.dart';
import 'package:app_movil/controllers/authController.dart';
import 'package:app_movil/utils/api_backend.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var nombreController = TextEditingController();
  var registroController = TextEditingController();
  var celularController = TextEditingController();
  var imagenController = TextEditingController();
  var carreraController = TextEditingController();
  bool google = false;
  bool isSexo = false;

  XFile? selectedImage;

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      selectedImage = pickedImage;
      print(selectedImage!.path);
    });
  }

  @override
  void initState() {
    google = false;
    isSexo = false;
    super.initState();
  }

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
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25, top: 30),
          child: Column(
            children: [
              const SizedBox(
                width: double.infinity,
                child: Text(
                  'Registro',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ),
              const SizedBox(height: 140),
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
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              /* Registro */
              TextFormField(
                controller: registroController,
                decoration: const InputDecoration(
                  labelText: 'Registro',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              /* Imagen input */
              ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: primary,
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.image_outlined),
                      SizedBox(width: 10),
                      Text('Seleccionar imagen'),
                    ],
                  )),
              SizedBox(height: 16),
              if (selectedImage != null)
                Image.file(
                  File(selectedImage!.path),
                  height: 200,
                ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: celularController,
                decoration: const InputDecoration(
                  labelText: 'Celular',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: carreraController,
                decoration: const InputDecoration(
                  labelText: 'Carrera de estudio',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  prefixIcon: Icon(
                    Icons.school_outlined,
                    color: Colors.grey,
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
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              /* Sexo */
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hombre',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                leading: Radio(
                  value: true,
                  groupValue: isSexo,
                  activeColor: primary,
                  onChanged: (value) {
                    setState(() {
                      print(value);
                      isSexo = value!;
                    });
                  },
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mujer',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                leading: Radio(
                  value: false,
                  groupValue: isSexo,
                  activeColor: primary,
                  onChanged: (value) {
                    setState(() {
                      print(value);
                      isSexo = value!;
                    });
                  },
                ),
              ),
              /* const SizedBox(height: 16),
              Text(
                'Selección actual: ${isSexo == true ? 'Hombre' : (isSexo == false ? 'Mujer' : 'Ninguno')}',
                style: TextStyle(fontSize: 16),
              ), */
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    /* Navigator.pushReplacementNamed(context, '/login'); */
                    var image = urlCloudinary(selectedImage);
                    imagenController.text = image.toString();
                    register();
                    /*  AuthController().register(
                      nombreController.text,
                      emailController.text,
                      passwordController.text,
                      registroController.text,
                      celularController.text,
                      image,
                      carreraController.text,
                      google,
                      isSexo,
                    ); */
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
                      'Registrarse',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: containerprimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> urlCloudinary(file) async {
    File fileBytes = File(file.path);
    final cloudinary = Cloudinary.signedConfig(
      apiKey: "281217171317886",
      apiSecret: "SGcS7K5qbrJYq4pZ1HjcuJLC24Q",
      cloudName: "dg2ugi96k",
    );
    final response = await cloudinary.upload(
        file: file.path,
        fileBytes: fileBytes.readAsBytesSync(),
        resourceType: CloudinaryResourceType.image,
        folder: 'phone',
        progressCallback: (count, total) {
          print('Uploading image from file with progress: $count/$total');
        });
    if (response.isSuccessful) {
      print('Get your image from with ${response.secureUrl}');
      return (response.secureUrl);
    }
    return null;
  }

  void register() async {
    final String nombre = nombreController.text;
    final String correo = emailController.text;
    final String password = passwordController.text;
    final String nro_registro = registroController.text;
    final String celular = celularController.text;

    var rol = await AuthController().getRoles();

    if (nombre.isEmpty ||
        correo.isEmpty ||
        password.isEmpty ||
        nro_registro.isEmpty ||
        celular.isEmpty) {
      print('Campo vacio');
    } else {
      var response = await http.post(
        Uri.parse('$apiBackend/usuarios'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "nombre": nombre,
          "correo": correo,
          "password": password,
          "nro_registro": nro_registro,
          "celular": celular,
          "google": google,
          "sexo": isSexo,
          "estado": true,
          "id_rol": rol,
        }),
      );
      if (response.statusCode == 200) {
        print('Registro exitoso');
        Navigator.pushNamed(context, '/login');
      } else {
        print('Registro fallido');
      }

      print('Registro exitoso');
    }
  }
}
