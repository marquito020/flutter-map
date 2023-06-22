import 'package:app_movil/constants/colors.dart';
import 'package:app_movil/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/api_backend.dart';

class PreferenciasPage extends StatefulWidget {
  @override
  _PreferenciasPageState createState() => _PreferenciasPageState();
}

class _PreferenciasPageState extends State<PreferenciasPage> {
  final TextEditingController preferencias = TextEditingController();

  String nombrePerfil = "";
  String nro_registro = "";
  int id_usuario = 0;
  List<Map<String, dynamic>> preferenciasList = [];

  @override
  void initState() {
    cargarDatosStore();
    getPreferencias();
    super.initState();
  }

  void cargarDatosStore() async {
    SharedPreferences user = await SharedPreferences.getInstance();
    nombrePerfil = user.getString('nombre')!;
    nro_registro = user.getString('nro_registro')!;
    id_usuario = user.getInt('id')!;
  }

  @override
  void dispose() {
    preferencias.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Añadir Preferencias",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primary,
      ),
      drawer: DrawerWidget(
          nombrePerfil: nombrePerfil,
          nro_registroPerfil: nro_registro,
          pageNombre: "Preferencias"),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: preferencias,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'Preferencias',
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // Acciones al guardar las preferencias
                  String textoPreferencias = preferencias.text;
                  print('Preferencias guardadas: $textoPreferencias');
                  preferenciasPost();
                },
                child: Text('Guardar'),
              ),
            ),

            /* ListView preferencias */
            ListView.builder(
              shrinkWrap: true,
              itemCount: preferenciasList.length,
              itemBuilder: (BuildContext context, int index) {
                if (preferenciasList[index]['estado'] != false &&
                    preferenciasList[index]['id_usuario'] == id_usuario) {
                  return Card(
                    child: ListTile(
                      title: Text(preferenciasList[index]['preferencia']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          print('Eliminar preferencia');
                          print(preferenciasList[index]['id']);
                          deletePreferencia(preferenciasList[index]['id']);
                        },
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void getPreferencias() async {
    var response = await http.get(
      Uri.parse('$apiBackend/pref'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        preferenciasList =
            List<Map<String, dynamic>>.from(jsonResponse['preferencia']);
      });
      print(preferenciasList);
    } else {
      print('Error al obtener preferencias');
    }
  }

  void deletePreferencia(id) async {
    var response = await http.delete(
      Uri.parse('$apiBackend/pref/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      print('Preferencia eliminada');
      print(response.body);
      /* Mensaje Guardado exitosamente */
      final snackBar = SnackBar(
        content: Text('Preferencia eliminada'),
        action: SnackBarAction(
          label: 'Cerrar',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pushNamed(context, '/preferencias');
    } else {
      print('Error al eliminar preferencia');
    }
  }

  void preferenciasPost() async {
    final String preferncia = preferencias.text;

    if (preferncia.isNotEmpty) {
      var response = await http.post(
        Uri.parse('$apiBackend/pref'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "preferencia": preferncia,
          "estado": "1",
          "id_usuario": id_usuario,
        }),
      );

      if (response.statusCode == 200) {
        print('Preferencia guardada');
        /* Mensaje Guardado exitosamente */
        final snackBar = SnackBar(
          content: Text('Preferencia guardada'),
          action: SnackBarAction(
            label: 'Cerrar',
            onPressed: () {},
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pushNamed(context, '/preferencias');
      } else {
        print('Error al guardar preferencia');
      }
    }
  }
}
