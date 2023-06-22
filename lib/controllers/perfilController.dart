import 'dart:convert';

import 'package:app_movil/utils/api_backend.dart';
import 'package:app_movil/utils/datos_perfil.dart';
import 'package:app_movil/utils/datos_personas.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PerfilController {
  obtenerPerfil() async {
    var response = await http.get(Uri.parse('$apiBackend/perfil'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Error al obtener el perfil');
    }
  }

  void metodoPago(String metodo) async {
    var response = await http.post(
      Uri.parse('$apiBackend/metodoPago'),
      body: {
        'metodo': metodo,
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }
    } else {
      throw Exception('Error al obtener el perfil');
    }
  }
}
