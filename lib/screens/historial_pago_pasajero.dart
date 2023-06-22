import 'dart:convert';
import 'package:app_movil/constants/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/perfilController.dart';
import '../utils/api_backend.dart';
import '../widgets/drawer.dart';
import 'package:http/http.dart' as http;

class HistorialPagosPage extends StatefulWidget {
  const HistorialPagosPage({Key? key}) : super(key: key);

  @override
  _HistorialPagosPageState createState() => _HistorialPagosPageState();
}

class _HistorialPagosPageState extends State<HistorialPagosPage> {
  List<Map<String, dynamic>> viajes = [];
  String nombrePerfil = "";
  String nro_registro = "";
  int id_usuario = 0;
  List<Map<String, dynamic>> historialSolicitudes = [];
  List<Map<String, dynamic>> historialPagos = [];
  List<Map<String, dynamic>> listaRelacionada = [];

  @override
  void initState() {
    super.initState();
    cargarDatosStore();
    cargarViajes();
    /* cargarPagos(); */
    /* cargarListaRelacionada(); */
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
        cargarPagos();
      });
      /*  print(historialSolicitudes); */
    } else {
      print('Error al obtener preferencias');
    }
  }

  void cargarPagos() async {
    var response = await http.get(
      Uri.parse('$apiBackend/pago'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        historialPagos = List<Map<String, dynamic>>.from(jsonResponse['pago']);
        print(historialPagos);
      });
      /* print(historialPagos); */
      cargarListaRelacionada();
    } else {
      print('Error al obtener preferencias');
    }
  }

  void cargarListaRelacionada() {
    for (var i = 0; i < historialSolicitudes.length; i++) {
      for (var j = 0; j < historialPagos.length; j++) {
        if (historialSolicitudes[i]['id'] ==
                historialPagos[j]['id_soli_viaje'] &&
            historialSolicitudes[i]['id_usuario'] == id_usuario) {
          listaRelacionada.add({
            'id': historialSolicitudes[i]['id'],
            'cant_pasajeros': historialSolicitudes[i]['cant_pasajeros'],
            'soliviaje': historialSolicitudes[i],
            'pago': historialPagos[j],
          });
        }
      }
    }
    print(listaRelacionada);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text(
          "Historial de pagos",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      drawer: Drawer(
        child: DrawerWidget(
          nombrePerfil: nombrePerfil,
          nro_registroPerfil: nro_registro,
          pageNombre: "Historial de pagos",
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 16),
        child: ListView.builder(
          itemCount: listaRelacionada.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                // Acción al presionar el viaje en la lista
                print("Viaje seleccionado: ${listaRelacionada[index]['id']}");
              },
              child: ListTile(
                leading: Icon(Icons.directions_car), // Agregar el icono aquí
                title: Text(
                  "Hora: ${listaRelacionada[index]['soliviaje']['hora_p']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Costo total: ${listaRelacionada[index]['pago']['costo_total']}",
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
          },
        ),
      ),
    );
  }
}
