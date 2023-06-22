import 'dart:convert';

import 'package:app_movil/constants/colors.dart';
import 'package:app_movil/utils/api_backend.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/perfilController.dart';
import '../widgets/drawer.dart';
import 'package:http/http.dart' as http;

class MetodoPagoPage extends StatefulWidget {
  const MetodoPagoPage({Key? key}) : super(key: key);

  @override
  _MetodoPagoPageState createState() => _MetodoPagoPageState();
}

class _MetodoPagoPageState extends State<MetodoPagoPage> {
  String selectedPaymentMethod = "Efectivo";
  String nombrePerfil = "";
  String nro_registro = "";
  int id_usuario = 0;

  /* Datos Tarjeta */
  var nombre_titular = TextEditingController();
  var nro_tarjeta = TextEditingController();
  DateTime fech_ven = DateTime.now();
  var cv = TextEditingController();

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

  void showAddPaymentMethodModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Agregar método de pago",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nombre_titular,
                decoration: const InputDecoration(
                  labelText: "Nombre del titular",
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nro_tarjeta,
                decoration: const InputDecoration(
                  labelText: "Número de tarjeta",
                  prefixIcon: Icon(Icons.credit_card),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: cv,
                decoration: const InputDecoration(
                  labelText: "CV",
                  prefixIcon: Icon(Icons.security),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: seleccionarFechaVencimiento,
                  style: ElevatedButton.styleFrom(
                      foregroundColor: containerprimaryAccent,
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),
                  child: const Text(
                    'Fecha de vencimineto',
                    style: TextStyle(fontSize: 16),
                  )),
              const SizedBox(height: 5),
              Text(
                'Fecha seleccionada: ${fech_ven.toString()}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  /* BorderRadius */
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  // Lógica para agregar el método de pago
                  registrarTarjeta();
                },
                child: const Text(
                  "Guardar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Selección de método de pago",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primary,
      ),
      drawer: DrawerWidget(
        nombrePerfil: nombrePerfil,
        nro_registroPerfil: nro_registro,
        pageNombre: "Método de pago",
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Método de pago seleccionado: $selectedPaymentMethod",
              style: const TextStyle(fontSize: 18),
            ),
          ),
          ListTile(
            title: const Text("Efectivo"),
            leading: const Icon(Icons.attach_money),
            trailing: Radio(
              value: "Efectivo",
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value as String;
                });
              },
            ),
          ),
          ListTile(
            title: const Text("Tarjeta de débito o crédito"),
            leading: const Icon(Icons.credit_card),
            trailing: Radio(
              value: "Tarjeta",
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value as String;
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            minimumSize:
                Size(double.infinity, 50), // Agrega el alto deseado aquí
          ),
          onPressed: () {
            // Lógica para guardar el método de pago seleccionado
            showAddPaymentMethodModal(context);
          },
          child: Text("Agregar método de pago"),
        ),
      ),
    );
  }

  Future<void> seleccionarFechaVencimiento() async {
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

  void registrarTarjeta() async {
    if (nro_tarjeta != 0 &&
        nombre_titular.text.isNotEmpty &&
        cv.text.isNotEmpty) {
      var Fecha_Vencimiento = DateFormat('yyyy-MM-dd').format(fech_ven);
      var response = await http.post(Uri.parse('$apiBackend/targeta'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            "nom_titular": nombre_titular.text,
            "num_targeta": nro_tarjeta.text,
            "fech_ven": Fecha_Vencimiento,
            "csv": cv.text,
            "id_usuario": id_usuario
          }));
      if (response.statusCode == 200) {
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tarjeta registrada'),
        ));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error al registrar la tarjeta'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error al registrar la tarjeta'),
      ));
    }
  }
}
