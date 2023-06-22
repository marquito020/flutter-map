import 'package:app_movil/screens/guardar_ruta.dart';
import 'package:app_movil/screens/historial_viajes_conductor.dart';
import 'package:app_movil/screens/historial_viajes_pasajero.dart';
import 'package:app_movil/screens/inicio_conductor.dart';
import 'package:app_movil/screens/metodo_pago.dart';
import 'package:app_movil/screens/preferencias.dart';
import 'package:app_movil/screens/register.dart';
import 'package:app_movil/screens/register_brevet.dart';
import 'package:app_movil/screens/register_conductor.dart';
import 'package:app_movil/screens/reservar_viaje_lista.dart';
import 'package:app_movil/screens/solicitar_viaje.dart';
import 'package:app_movil/screens/login.dart';
import 'package:app_movil/screens/onboarding.dart';
import 'package:app_movil/screens/reservar_viaje.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Universidad Taxi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Montserrat'),
        initialRoute: '/onboarding',
        routes: <String, WidgetBuilder>{
          '/onboarding': (BuildContext context) => const Onboarding(),
          '/login': (BuildContext context) => const Login(),
          '/register': (BuildContext context) => const Register(),
          '/solicitarViaje': (BuildContext context) =>
              const SolicitarViajePage(),
          '/metodoPago': (BuildContext context) => const MetodoPagoPage(),
          '/historialViajesPasajero': (BuildContext context) =>
              const HistorialViajesPasajeroPage(),
          '/historialViajesConductor': (BuildContext context) =>
              const HistorialViajesConductorPage(),
          '/inicioConductor': (BuildContext context) =>
              const InicioConductorPage(),
          '/registerConductor': (BuildContext context) =>
              RegisterConductorPage(),
          '/preferencias': (BuildContext context) => PreferenciasPage(),
          '/brevet': (BuildContext context) => const RegisterBrevetPage(),
          '/guardarRuta': (BuildContext context) => const GuardarRutaPage(),
          '/reservarViajeLista': (BuildContext context) =>
              const ReservarViajeListaPage(),
        });
  }
}
