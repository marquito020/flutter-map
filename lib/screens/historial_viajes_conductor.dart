import 'dart:convert';
import 'package:app_movil/constants/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/perfilController.dart';
import '../widgets/drawer.dart';

class HistorialViajesConductorPage extends StatefulWidget {
  const HistorialViajesConductorPage({Key? key}) : super(key: key);

  @override
  _HistorialViajesConductorPageState createState() =>
      _HistorialViajesConductorPageState();
}

class _HistorialViajesConductorPageState
    extends State<HistorialViajesConductorPage> {
  List<Map<String, dynamic>> viajes = [];
  String nombrePerfil = "";
  String nro_registro = "";

  @override
  void initState() {
    super.initState();
    cargarViajes();
    /* cargarDatosStore(); */
  }

  void cargarDatosStore() async {
    SharedPreferences user = await SharedPreferences.getInstance();
    nombrePerfil = user.getString('nombre')!;
    nro_registro = user.getString('nro_registro')!;
  }

  void cargarViajes() {
    // Simular carga de datos desde un JSON
    String jsonViajes = '''
    [
      {
        "id": 1,
        "pasajero": "John Doe",
        "destino": "Destino 1",
        "horaSalida": "09:00 AM",
        "horaLlegada": "10:00 AM",
        "fecha": "2023-06-16",
        "calificacion": 4.5
      },
      {
        "id": 2,
        "pasajero": "Jane Smith",
        "destino": "Destino 2",
        "horaSalida": "11:30 AM",
        "horaLlegada": "12:30 PM",
        "fecha": "2023-06-17",
        "calificacion": 3.8
      },
      {
        "id": 3,
        "pasajero": "Mike Johnson",
        "destino": "Destino 3",
        "horaSalida": "02:15 PM",
        "horaLlegada": "03:15 PM",
        "fecha": "2023-06-18",
        "calificacion": 4.2
      }
    ]
    ''';

    // Decodificar el JSON y cargar los viajes
    List<dynamic> listaViajes = jsonDecode(jsonViajes);
    viajes = List<Map<String, dynamic>>.from(listaViajes);
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
          itemCount: viajes.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> viaje = viajes[index];
            return InkWell(
              onTap: () {
                // Acción al presionar el viaje en la lista
                print("Viaje seleccionado: ${viaje['id']}");
              },
              child: ListTile(
                leading: Icon(Icons.directions_car), // Agregar el icono aquí
                title: Text(
                  "Pasajero: ${viaje['pasajero']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Destino: ${viaje['destino']}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tiempo: ${viaje['horaSalida']} - ${viaje['horaLlegada']}",
                      style: const TextStyle(fontSize: 14),
                    ),
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
