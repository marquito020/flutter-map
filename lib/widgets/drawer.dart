import 'package:app_movil/constants/colors.dart';
import 'package:app_movil/controllers/perfilController.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerWidget extends StatefulWidget {
  DrawerWidget({
    Key? key,
    required this.nombrePerfil,
    required this.nro_registroPerfil,
    required this.pageNombre,
  }) : super(key: key);

  final String nombrePerfil;
  final String nro_registroPerfil;
  final String pageNombre;

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  SharedPreferences? user;

  @override
  void initState() {
    super.initState();
    obtenerSharedPreferences();
  }

  Future<void> obtenerSharedPreferences() async {
    user = await SharedPreferences.getInstance();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return CircularProgressIndicator();
    }

    String nombre = widget.nombrePerfil;
    String nro_registro = widget.nro_registroPerfil;
    int id_rol = user!.getInt('id_rol')!;

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
          /* if (id_rol == 2) */
          Expanded(
            child: ListView(
              children: [
                if (id_rol == 1) ...[
                  ListTile(
                    title: const Text("Reservar viaje"),
                    selected: widget.pageNombre == "Reservar viaje",
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
                    selected: widget.pageNombre == "Solicitar viaje",
                    leading: const Icon(Icons.directions_car),
                    horizontalTitleGap: 0.0,
                    selectedColor: primary,
                    onTap: () {
                      Navigator.pushReplacementNamed(
                          context, '/solicitarViaje');
                    },
                  ),
                  ListTile(
                    title: const Text("Método de pago"),
                    subtitle: const Text("Efectivo"),
                    selected: widget.pageNombre == "Método de pago",
                    leading: const Icon(Icons.payment),
                    horizontalTitleGap: 0.0,
                    selectedColor: primary,
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/metodoPago');
                    },
                  ),
                  ListTile(
                    title: const Text("Preferencias"),
                    selected: widget.pageNombre == "Preferencias",
                    leading: const Icon(Icons.settings),
                    horizontalTitleGap: 0.0,
                    selectedColor: primary,
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/preferencias');
                    },
                  ),
                  /* Historial Pago */
                  ListTile(
                    title: const Text("Historial de pagos"),
                    selected: widget.pageNombre == "Historial de pagos",
                    leading: const Icon(Icons.history),
                    horizontalTitleGap: 0.0,
                    selectedColor: primary,
                    onTap: () {
                      Navigator.pushReplacementNamed(
                          context, '/historialPagosPasajero');
                    },
                  ),
                  ListTile(
                    title: const Text("Historial de viajes"),
                    selected: widget.pageNombre == "Historial de viajes",
                    leading: const Icon(Icons.history),
                    horizontalTitleGap: 0.0,
                    selectedColor: primary,
                    onTap: () {
                      Navigator.pushReplacementNamed(
                          context, '/historialViajesPasajero');
                    },
                  ),
                ],
                if (id_rol == 2) ...[
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
                  ListTile(
                    title: const Text("Inicio"),
                    selected: widget.pageNombre == "Inicio",
                    leading: const Icon(Icons.home),
                    horizontalTitleGap: 0.0,
                    selectedColor: primary,
                    onTap: () {
                      Navigator.pushReplacementNamed(
                          context, '/inicioConductor');
                    },
                  ),
                  ListTile(
                    title: const Text("Registrar Vehiculo"),
                    selected: widget.pageNombre == "Registrar Conductor",
                    leading: const Icon(Icons.person_add),
                    horizontalTitleGap: 0.0,
                    selectedColor: primary,
                    onTap: () {
                      Navigator.pushReplacementNamed(
                          context, '/registerConductor');
                    },
                  ),
                  ListTile(
                    title: const Text("Brevet"),
                    selected: widget.pageNombre == "Brevet",
                    leading: const Icon(Icons.person_add),
                    horizontalTitleGap: 0.0,
                    selectedColor: primary,
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/brevet');
                    },
                  ),
                  ListTile(
                    title: const Text("Rutas"),
                    selected: widget.pageNombre == "Rutas",
                    leading: const Icon(Icons.map),
                    horizontalTitleGap: 0.0,
                    selectedColor: primary,
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/guardarRuta');
                    },
                  ),
                  ListTile(
                    title: const Text("Historial de viajes"),
                    selected: widget.pageNombre == "Historial de viajes",
                    leading: const Icon(Icons.history),
                    horizontalTitleGap: 0.0,
                    selectedColor: primary,
                    onTap: () {
                      Navigator.pushReplacementNamed(
                          context, '/historialViajesConductor');
                    },
                  ),
                ],
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
