import 'dart:convert';
import 'package:app_movil/constants/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/perfilController.dart';
import '../utils/api_backend.dart';
import '../widgets/drawer.dart';
import 'package:http/http.dart' as http;

class HistorialViajesPasajeroPage extends StatefulWidget {
  const HistorialViajesPasajeroPage({Key? key}) : super(key: key);

  @override
  _HistorialViajesPasajeroPageState createState() =>
      _HistorialViajesPasajeroPageState();
}

class _HistorialViajesPasajeroPageState
    extends State<HistorialViajesPasajeroPage> {
  List<Map<String, dynamic>> viajes = [];
  String nombrePerfil = "";
  String nro_registro = "";
  int id_usuario = 0;
  List<Map<String, dynamic>> historialSolicitudes = [];

  @override
  void initState() {
    super.initState();
    cargarViajes();
    cargarDatosStore();
  }

  void cargarDatosStore() async {
    SharedPreferences user = await SharedPreferences.getInstance();
    nombrePerfil = user.getString('nombre')!;
    nro_registro = user.getString('nro_registro')!;
    id_usuario = user.getInt('id')!;
    print("id_usuario: $id_usuario");
  }

  void cargarViajes() async {
    var response = await http.get(
      Uri.parse('$apiBackend/soliviaje'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        historialSolicitudes =
            List<Map<String, dynamic>>.from(jsonResponse['soliViaje']);
        print(historialSolicitudes);
      });
      print(historialSolicitudes);
    } else {
      print('Error al obtener preferencias');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text(
          "Historial de Viajes",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      drawer: Drawer(
        child: DrawerWidget(
          nombrePerfil: nombrePerfil,
          nro_registroPerfil: nro_registro,
          pageNombre: "Historial de viajes",
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 16),
        child: ListView.builder(
          itemCount: historialSolicitudes.length,
          itemBuilder: (context, index) {
            if (historialSolicitudes[index]['id_usuario'] == id_usuario) {
              return InkWell(
                onTap: () {
                  // Acción al presionar el viaje en la lista
                  print(
                      "Viaje seleccionado: ${historialSolicitudes[index]['id']}");
                },
                child: ListTile(
                  leading: Icon(Icons.directions_car), // Agregar el icono aquí
                  title: Text(
                    "Hora: ${historialSolicitudes[index]['hora_p']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Cantidad de personas: ${historialSolicitudes[index]['cant_pasajeros']}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      /* const SizedBox(height: 8),
                    Text(
                      "Destino: ${historialSolicitudes[index]['estado']}",
                      style: const TextStyle(fontSize: 14),
                    ), */
                    ],
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
