import 'dart:convert';
import 'dart:io';
import 'package:app_movil/constants/colors.dart';
import 'package:app_movil/controllers/authController.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/perfilController.dart';
import '../utils/api_backend.dart';
import '../widgets/drawer.dart';

import 'package:http/http.dart' as http;

class RegisterConductorPage extends StatefulWidget {
  const RegisterConductorPage({Key? key}) : super(key: key);

  @override
  _RegisterConductorPageState createState() => _RegisterConductorPageState();
}

class _RegisterConductorPageState extends State<RegisterConductorPage> {
  final _formKey = GlobalKey<FormState>();
  String _numeroPlaca = '';
  String _modeloVehiculo = '';
  String _anioVehiculo = '';
  String _capacidadVehiculo = '';
  /* String _caracteristicaEspecial = ''; */
  String img = '';

  XFile? selectedImage;

  /* Obtener de SharedPreferences */
  int id_usuario = 0;
  String nombrePerfil = "";
  String nro_registro = "";

  @override
  void initState() {
    cargarDatosStore();
    super.initState();
  }

  void cargarDatosStore() async {
    SharedPreferences user = await SharedPreferences.getInstance();
    nombrePerfil = user.getString('nombre')!;
    nro_registro = user.getString('nro_registro')!;
    id_usuario = user.getInt('id')!;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Procesar los datos del formulario
      _formKey.currentState!.save();
      // Realizar las acciones necesarias con los datos ingresados
      print('Número de placa: $_numeroPlaca');
      print('Modelo de vehículo: $_modeloVehiculo');
      print('Año de vehículo: $_anioVehiculo');
      print('Capacidad de vehículo: $_capacidadVehiculo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text('Registrar Conductor'),
      ),
      drawer: Drawer(
        child: DrawerWidget(
          nombrePerfil: nombrePerfil,
          nro_registroPerfil: nro_registro,
          pageNombre: 'Registrar Conductor',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Número de placa',
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el número de placa';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _numeroPlaca = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Modelo de vehículo',
                    prefixIcon: Icon(Icons.model_training),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el modelo de vehículo';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _modeloVehiculo = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Año de vehículo',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el año de vehículo';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _anioVehiculo = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Capacidad de vehículo',
                    prefixIcon: Icon(Icons.people),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la capacidad de vehículo';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _capacidadVehiculo = value!;
                  },
                ),
                const SizedBox(height: 20),
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
                /* TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Característica especial',
                    prefixIcon: Icon(Icons.info),
                  ),
                  onSaved: (value) {
                    _caracteristicaEspecial = value!;
                  },
                ),
                const SizedBox(height: 20), */
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: registrarVehiculo,
                    child: const Text('Registrar vehículo'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      selectedImage = pickedImage;
      print(selectedImage!.path);
    });
  }

  Future<String?> urlCloudinary(file) async {
    if (file != null) {
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
        return (response.secureUrl).toString();
      }
      return null;
    } else {
      print('No se seleccionó ninguna imagen');
    }
    ;
  }

  void registrarVehiculo() async {
    if (selectedImage != null) {
      var imagen = await urlCloudinary(selectedImage);
      img = imagen.toString();
      print("Imagen: $img");
      if (_formKey.currentState!.validate() && img != null) {
        _formKey.currentState!.save();
        print('Número de placa: $_numeroPlaca');
        print('Modelo de vehículo: $_modeloVehiculo');
        print('Año de vehículo: $_anioVehiculo');
        print('Capacidad de vehículo: $_capacidadVehiculo');
        print('Url de imagen: $img');
        var response = await http.post(
          Uri.parse('$apiBackend/vehiculo'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            "num_placa": _numeroPlaca,
            "modelo": _modeloVehiculo,
            "año": _anioVehiculo,
            "cap_pasajeros": _capacidadVehiculo,
            "img": img,
            "estado": true,
            "id_usuario": id_usuario,
          }),
        );

        print(response.body);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehículo registrado correctamente'),
            ),
          );
          Navigator.pushNamed(context, '/registerConductor');
          /* Navigator.pushNamed(context, 'home'); */
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al registrar el vehículo'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor ingrese todos los datos'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione una imagen'),
        ),
      );
    }
  }
}
