import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/api_backend.dart';

class historialController {
  Future<void> historialViajesPasajero() async {
    var response = await http.get(Uri.parse('$apiBackend/historialViajesPasajero'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }
      return data;
    } else {
      throw Exception('Error al obtener el perfil');
    }
  }

  /* Historial viajes de conductor */
  Future<void> historialViajesConductor() async {
    var response = await http.get(Uri.parse('$apiBackend/historialViajesConductor'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }
      return data;
    } else {
      throw Exception('Error al obtener el perfil');
    }
  }
}