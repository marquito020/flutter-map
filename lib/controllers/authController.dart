import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/api_backend.dart';

class AuthController {
  void login(String email, String password) async {
    var response = await http.post(
      Uri.parse('$apiBackend/login'),
      body: {
        'email': email,
        'password': password,
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

  void register(nombre, correo, password, registro, celular, imagen, carreara,
      google, sexo) async {
    print(nombre);
    print(correo);
    print(password);
    var rol = await getRoles();
    /* get Rol Usuario */

    var response = await http.post(Uri.parse('$apiBackend/usuarios'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "nombre": nombre,
          "correo": correo,
          "password": password,
          "nro_registro": registro,
          "celular": celular,
          "imagen": imagen,
          "carreara": carreara,
          "google": google,
          "sexo": sexo,
          "estado": 1,
          "id_rol": rol,
        }));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }
    } else {
      throw Exception('Error al obtener el perfil');
    }
  }

  void registerAuto(String placa, String modelo, String anio, String capacidad,
      String caracteristica, String idConductor) async {
    var response = await http.post(Uri.parse('$apiBackend/registerAuto'),
        body: ({
          'placa': placa,
          'modelo': modelo,
          'anio': anio,
          'capacidad': capacidad,
          'caracteristica': caracteristica,
          'idConductor': idConductor,
        }));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }
    } else {
      throw Exception('Error al obtener el perfil');
    }
  }

  Future<int> getRoles() async {
    var response = await http.get(Uri.parse('$apiBackend/roles'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }

      // Filtrar el JSON para obtener el ID del nombre_rol "USUARIO"
      var usuarioRol = data['rol'].firstWhere(
          (rol) => rol['nombre_rol'] == 'USUARIO',
          orElse: () => null);

      if (usuarioRol != null) {
        int usuarioId = usuarioRol['id'];
        print(usuarioId);
        return usuarioId;
      } else {
        throw Exception('No se encontró el rol "USUARIO"');
      }
    } else {
      throw Exception('Error al obtener el perfil');
    }
  }
}
