import 'dart:convert';

import 'package:app_movil/screens/reservar_viaje.dart';
import 'package:app_movil/utils/api_backend.dart';
import 'package:app_movil/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/colors.dart';

import 'package:http/http.dart' as http;

class ReservarViajeListaPage extends StatefulWidget {
  const ReservarViajeListaPage({super.key});

  @override
  State<ReservarViajeListaPage> createState() => _ReservarViajeListaPageState();
}

class _ReservarViajeListaPageState extends State<ReservarViajeListaPage> {
  String nombrePerfil = "";
  String nro_registro = "";

  /* Lista Rutas */
  List<Map<String, dynamic>> rutas = [];

  get apiUrl => null;

  void cargarDatosStore() async {
    SharedPreferences user = await SharedPreferences.getInstance();
    nombrePerfil = user.getString('nombre')!;
    nro_registro = user.getString('nro_registro')!;
  }

  @override
  void initState() {
    cargarDatosStore();
    listarRutas();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Reservar viaje",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primary,
      ),
      drawer: DrawerWidget(
          nombrePerfil: nombrePerfil,
          nro_registroPerfil: nro_registro,
          pageNombre: "Reservar viaje"),
      body: Stack(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: rutas.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: ListTile(
                  title: Text("Hora: " + rutas[index]['hora_p'].toString()),
                  subtitle: Text("Cantidad pasajeros limite: " +
                      rutas[index]['cant_pasajero'].toString()),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      print('Ver ruta');
                      print(rutas[index]['id']);
                      /* print(rutas[index]['strpolyline']); */
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservarViajePage(
                            polylineCoordinates: rutas[index]['strpolyline'],
                            id_soli_viaje: rutas[index]['id'],
                            hora_p: rutas[index]['hora_p'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void listarRutas() async {
    SharedPreferences user = await SharedPreferences.getInstance();
    int id_usuario = user.getInt('id')!;

    var response = await http.get(
      Uri.parse("$apiBackend/ruta"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        rutas = List<Map<String, dynamic>>.from(jsonResponse['ruta']);
        print(rutas);
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }
}
