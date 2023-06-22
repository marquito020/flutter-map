import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../constants/colors.dart';
import '../widgets/drawer.dart';

import 'package:http/http.dart' as http;

import '../utils/api_backend.dart';

class RegisterBrevetPage extends StatefulWidget {
  const RegisterBrevetPage({super.key});

  @override
  State<RegisterBrevetPage> createState() => _RegisterBrevetPageState();
}

class _RegisterBrevetPageState extends State<RegisterBrevetPage> {
  final _formKey = GlobalKey<FormState>();

  /* Brevet controller */
  final TextEditingController numero = TextEditingController();
  DateTime fech_emi = DateTime.now();
  DateTime fech_ven = DateTime.now();
  final TextEditingController categoria = TextEditingController();
  String img_frontal = '';
  String img_reverso = '';

  XFile? seleFrontalFrontal;
  XFile? seleFrontalReverso;

  /* Obtener de SharedPreferences */
  int id_usuario = 0;
  String nombrePerfil = "";
  String nro_registro = "";

  void cargarDatosStore() async {
    SharedPreferences user = await SharedPreferences.getInstance();
    nombrePerfil = user.getString('nombre')!;
    nro_registro = user.getString('nro_registro')!;
    id_usuario = user.getInt('id')!;
  }

  @override
  void initState() {
    // TODO: implement initState
    cargarDatosStore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text('Brevet'),
      ),
      drawer: Drawer(
        child: DrawerWidget(
          nombrePerfil: nombrePerfil,
          nro_registroPerfil: nro_registro,
          pageNombre: 'Brevet',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Registrar Brevet",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: numero,
                decoration: const InputDecoration(
                  labelText: "Numero de brevet",
                  prefixIcon: Icon(Icons.person),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: seleccionarFechaEmi,
                  style: ElevatedButton.styleFrom(
                      foregroundColor: containerprimaryAccent,
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),
                  child: const Text(
                    'Fecha de emision',
                    style: TextStyle(fontSize: 16),
                  )),
              const SizedBox(height: 5),
              Text(
                'Fecha seleccionada: ${fech_emi.toString()}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: seleccionarFechaVen,
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
                child: const Text(
                  'Fecha de vencimiento',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Fecha seleccionada: ${fech_ven.toString()}',
                style: const TextStyle(fontSize: 16),
              ),
              TextFormField(
                controller: categoria,
                decoration: const InputDecoration(
                  labelText: "Categoria",
                  prefixIcon: Icon(Icons.security),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _imagenFrontal,
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
                      Text('Imagen Frontal'),
                    ],
                  )),
              SizedBox(height: 16),
              if (seleFrontalFrontal != null)
                Image.file(
                  File(seleFrontalFrontal!.path),
                  height: 200,
                ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: _imagenReverso,
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
                      Text('Imagen Reverso'),
                    ],
                  )),
              SizedBox(height: 16),
              if (seleFrontalReverso != null)
                Image.file(
                  File(seleFrontalReverso!.path),
                  height: 200,
                ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    /* BorderRadius */
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    // Lógica para agregar el método de pago
                    registarBrevet();
                  },
                  child: const Text(
                    "Guardar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> seleccionarFechaEmi() async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        /* Navigator.of(context).pop(); */
        fech_emi = fechaSeleccionada;
      });
    }
  }

  Future<void> seleccionarFechaVen() async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        /* Navigator.of(context).pop(); */
        fech_ven = fechaSeleccionada;
      });
    }
  }

  Future<void> _imagenFrontal() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      seleFrontalFrontal = pickedImage;
      print(seleFrontalFrontal!.path);
    });
  }

  Future<void> _imagenReverso() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      seleFrontalReverso = pickedImage;
      print(seleFrontalReverso!.path);
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

  void registarBrevet() async {
    if (seleFrontalFrontal != null && seleFrontalReverso != null) {
      var img_frontalUrl = await urlCloudinary(seleFrontalFrontal);
      img_frontal = img_frontalUrl.toString();
      var img_reversolUrl = await urlCloudinary(seleFrontalReverso);
      img_reverso = img_reversolUrl.toString();

      String fech_emiDate = DateFormat('yyyy-MM-dd').format(fech_emi);
      String fech_venDate = DateFormat('yyyy-MM-dd').format(fech_ven);

      if (numero.text.isNotEmpty && categoria.text.isNotEmpty) {
        var response = await http.post(
          Uri.parse('$apiBackend/brevet'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            "numero": numero.text,
            "fech_emi": fech_emiDate,
            "fech_ven": fech_venDate,
            "categoria": categoria.text,
            "img_frontal": img_frontal,
            "img_reverso": img_reverso,
            "id_usuario": id_usuario
          }),
        );
        print(response.body);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Brevet registrado correctamente'),
            ),
          );
          Navigator.pushNamed(context, '/brevet');
          /* Navigator.pushNamed(context, 'home'); */
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al registrar el vehículo'),
            ),
          );
        }
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
