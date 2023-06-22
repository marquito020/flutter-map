import 'package:app_movil/constants/colors.dart';
import 'package:app_movil/controllers/perfilController.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerWidget extends StatelessWidget {
  DrawerWidget(
      {Key? key,
      required this.nombrePerfil,
      required this.nro_registroPerfil,
      required this.pageNombre})
      : super(key: key);
  final String nombrePerfil;
  final String nro_registroPerfil;
  final String pageNombre;

  @override
  Widget build(BuildContext context) {
    String nombre = nombrePerfil;
    String nro_registro = nro_registroPerfil;
    return Drawer(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // Acción al presionar el botón
            },
            child: Container(
              color: primary,
              height: 160,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 30,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$nombre",
                            style: const TextStyle(
                              color: containerprimaryAccent,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$nro_registro",
                            style: const TextStyle(
                              color: containerprimaryAccent,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: containerprimaryAccent,
                    size: 40,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text("Reservar viaje"),
                  selected: pageNombre == "Reservar viaje" ? true : false,
                  horizontalTitleGap: 0.0,
                  leading: const Icon(Icons.directions_car),
                  selectedColor: primary,
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, '/reservarViajeLista');
                  },
                ),
                ListTile(
                  title: const Text("Solicitar viaje"),
                  selected: pageNombre == "Solicitar viaje" ? true : false,
                  leading: const Icon(Icons.directions_car),
                  horizontalTitleGap: 0.0,
                  selectedColor: primary,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/solicitarViaje');
                  },
                ),
                /* Metodo de pago */
                ListTile(
                  title: const Text("Método de pago"),
                  subtitle: const Text("Efectivo"),
                  selected: pageNombre == "Método de pago" ? true : false,
                  leading: const Icon(Icons.payment),
                  horizontalTitleGap: 0.0,
                  selectedColor: primary,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/metodoPago');
                  },
                ),
                /* Preferencias */
                ListTile(
                  title: const Text("Preferencias"),
                  selected: pageNombre == "Preferencias" ? true : false,
                  leading: const Icon(Icons.settings),
                  horizontalTitleGap: 0.0,
                  selectedColor: primary,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/preferencias');
                  },
                ),
                ListTile(
                  title: const Text("Historial de viajes"),
                  selected: pageNombre == "Historial de viajes" ? true : false,
                  leading: const Icon(Icons.history),
                  horizontalTitleGap: 0.0,
                  selectedColor: primary,
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, '/historialViajesPasajero');
                  },
                ),
                /* Registrarse como conductor */
                ListTile(
                  title: const Text("Registar Vehiculo"),
                  selected: pageNombre == "Registrar Conductor" ? true : false,
                  leading: const Icon(Icons.person_add),
                  horizontalTitleGap: 0.0,
                  selectedColor: primary,
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, '/registerConductor');
                  },
                ),
                /* Brevet */
                ListTile(
                  title: const Text("Brevet"),
                  selected: pageNombre == "Brevet" ? true : false,
                  leading: const Icon(Icons.person_add),
                  horizontalTitleGap: 0.0,
                  selectedColor: primary,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/brevet');
                  },
                ),
                /* Poner condicion para Conductor */
                const SizedBox(
                  height: 10,
                  child: Divider(
                    color: Colors.black,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                  child: Text(
                    "Conductor",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
                /* Inicio */
                ListTile(
                  title: const Text("Inicio"),
                  selected: pageNombre == "Inicio" ? true : false,
                  leading: const Icon(Icons.home),
                  horizontalTitleGap: 0.0,
                  selectedColor: primary,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/inicioConductor');
                  },
                ),
                /* Rutas */
                ListTile(
                  title: const Text("Rutas"),
                  selected: pageNombre == "Rutas" ? true : false,
                  leading: const Icon(Icons.map),
                  horizontalTitleGap: 0.0,
                  selectedColor: primary,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/guardarRuta');
                  },
                ),
                ListTile(
                  title: const Text("Historial de viajes"),
                  selected: pageNombre == "Historial de viajes" ? true : false,
                  leading: const Icon(Icons.history),
                  horizontalTitleGap: 0.0,
                  selectedColor: primary,
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, '/historialViajesConductor');
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text("Cerrar sesión"),
            leading: const Icon(Icons.logout),
            horizontalTitleGap: 0.0,
            onTap: () async {
              SharedPreferences user = await SharedPreferences.getInstance();
              await user.clear();
              Navigator.pushNamedAndRemoveUntil(
                  context, "/login", (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
