import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/api_backend.dart';

class procesoViajeController {
  Future<void> reservarViaje(
    double latitudInicio,
    double longitudInicio,
    double latitudFin,
    double longitudFin,
    double? latitudActual,
    double? longitudActual,
    DateTime horaPartida,
    DateTime horaLlegada,
    double costo,
    bool state,
    double costoTotal,
  ) async {
    var response = await http.post(
      Uri.parse('$apiBackend/solicitarViaje'),
      body: {
        'latitudInicio': latitudInicio,
        'longitudInicio': longitudInicio,
        'latitudFin': latitudFin,
        'longitudFin': longitudFin,
        'latitudActual': latitudActual,
        'longitudActual': longitudActual,
        'horaPartida': horaPartida,
        'horaLlegada': horaLlegada,
        'costo': costo,
        'state': state,
        'costoTotal': costoTotal,
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

  /* Solicitar viaje */
  Future<void> solicitarViaje(
    double latitudInicio,
    double longitudInicio,
    double latitudFin,
    double longitudFin,
    DateTime horaPartida,
    int capacidadPasajeros,
  ) async {
    var response = await http.post(
      Uri.parse('$apiBackend/solicitarViaje'),
      body: {
        'latitudInicio': latitudInicio,
        'longitudInicio': longitudInicio,
        'latitudFin': latitudFin,
        'longitudFin': longitudFin,
        'horaPartida': horaPartida,
        'capacidadPasajeros': capacidadPasajeros,
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

  Future<void> aceptarViaje(
    int idViaje,
    int idConductor,
  ) async {
    var response = await http.post(
      Uri.parse('$apiBackend/aceptarViaje'),
      body: {
        'idViaje': idViaje,
        'idConductor': idConductor,
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

  /* Calificacion viaje y comentario */
  Future<void> calificarViaje(
    int idViaje,
    double calificacion,
    String comentario,
  ) async {
    var response = await http.post(
      Uri.parse('$apiBackend/calificarViaje'),
      body: {
        'idViaje': idViaje,
        'calificacion': calificacion,
        'comentario': comentario,
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

  /* Registro viaje conductor */
  Future<void> registrarViajeConductor(
    int idViaje,
    int idConductor,
  ) async {
    var response = await http.post(
      Uri.parse('$apiBackend/registrarViajeConductor'),
      body: {
        'idViaje': idViaje,
        'idConductor': idConductor,
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
