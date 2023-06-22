import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app_movil/constants/colors.dart';
import 'package:app_movil/controllers/perfilController.dart';
import 'package:app_movil/widgets/drawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:app_movil/utils/api_google.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/maps_style.dart';
import 'package:geocoder2/geocoder2.dart';

class InicioConductorPage extends StatefulWidget {
  const InicioConductorPage({Key? key}) : super(key: key);

  @override
  State<InicioConductorPage> createState() => _InicioConductorPageState();
}

class _InicioConductorPageState extends State<InicioConductorPage> {
  /* Controlado Mapa */
  final Completer<GoogleMapController> _completer = Completer();

  /* Ubicacion actual */
  LocationData? currentLocation;

  /* Marker */
  Set<Marker> markers = {};

  /* Polylines */
  List<LatLng> polylineCoordinates = [];

  /* Puntos Inicio */
  double origenLatitude = 0;
  double origenLongitude = 0;

  /* Puntos Fin */
  double destinoLatitude = 0;
  double destinoLongitude = 0;

  /* Markers Flotanets */
  bool mostrarMarkerOrigen = false;
  bool mostrarMarkerDestino = false;

  /* Distancia de polynine */
  double totalDistance = 0.0;

  /* Direccion de Marker */
  String address = '';

  /* Direccion lugar Map Origen */
  String addressOrigen = '';

  /* Direccion lugar Map Destino */
  String addressDestino = '';

  /* Coordenadas del marker centro pantalla */
  LatLng? centerMarkerScreen;

  /* Loading Mapa */
  bool isLoading = false;

  /* Precio */
  double precio = 0.0;

  /* Trabajo comenzado */
  bool trabajoIniciado = false;

  Future<GoogleMapController> get _mapController async {
    return await _completer.future;
  }

  _init() async {
    (await _mapController).setMapStyle(jsonEncode(mapStyle));
  }

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((LocationData locationData) async {
      currentLocation = locationData;
      final ByteData imageData =
          await rootBundle.load('assets/icons/mark_start.png');
      final Uint8List bytes = imageData.buffer.asUint8List();
      final img.Image? originalImage = img.decodeImage(bytes);
      final img.Image resizedImage =
          img.copyResize(originalImage!, width: 88, height: 140);
      final resizedImageData = img.encodePng(resizedImage);
      final BitmapDescriptor bitmapDescriptor =
          BitmapDescriptor.fromBytes(resizedImageData);
      final newMarker = Marker(
        markerId: const MarkerId("origen"),
        position:
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        icon: bitmapDescriptor,
      );
      origenLatitude = currentLocation!.latitude!;
      origenLongitude = currentLocation!.longitude!;
      markers.add(newMarker);
      address = await getAddressFromMarker(
          currentLocation!.latitude!, currentLocation!.longitude!);
      addressOrigen = address;
      setState(() {});
    });
  }

  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) async {
    final GoogleMapController controller = await _mapController;
    return controller.getLatLng(screenCoordinate);
  }

  void addMarkerOrigen(double latitude, double longitude) async {
    final ByteData imageData =
        await rootBundle.load('assets/icons/mark_start.png');
    final Uint8List bytes = imageData.buffer.asUint8List();
    final img.Image? originalImage = img.decodeImage(bytes);
    final img.Image resizedImage =
        img.copyResize(originalImage!, width: 88, height: 140);
    final resizedImageData = img.encodePng(resizedImage);
    final BitmapDescriptor bitmapDescriptor =
        BitmapDescriptor.fromBytes(resizedImageData);
    final newMarker = Marker(
      markerId: const MarkerId("origen"),
      position: LatLng(latitude, longitude),
      icon: bitmapDescriptor,
    );
    markers.add(newMarker);
    address = await getAddressFromMarker(latitude, longitude);
    addressOrigen = address;
    if (destinoLatitude != 0 && destinoLongitude != 0) {
      createPolylines();
    }
    setState(() {});
  }

  void addMarkerDestino(double latitude, double longitude) async {
    final ByteData imageData =
        await rootBundle.load('assets/icons/mark_end.png');
    final Uint8List bytes = imageData.buffer.asUint8List();
    final img.Image? originalImage = img.decodeImage(bytes);
    final img.Image resizedImage =
        img.copyResize(originalImage!, width: 88, height: 140);
    final resizedImageData = img.encodePng(resizedImage);
    final BitmapDescriptor bitmapDescriptor =
        BitmapDescriptor.fromBytes(resizedImageData);
    final newMarker = Marker(
      markerId: const MarkerId("destino"),
      position: LatLng(latitude, longitude),
      icon: bitmapDescriptor,
    );
    markers.add(newMarker);
    address = await getAddressFromMarker(latitude, longitude);
    addressDestino = address;
    if (origenLatitude != 0 && origenLongitude != 0) {
      createPolylines();
    }
    setState(() {});
  }

  void createPolylines() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      apiGoogle,
      PointLatLng(origenLatitude, origenLongitude),
      PointLatLng(destinoLatitude, destinoLongitude),
    );

    if (result.status == 'OK') {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      calculatePolylineDistance();
      calculateTime();
      calculatePrice();

      // Obtén el GoogleMapController
      GoogleMapController controller = await _mapController;

      // Crea una lista de LatLng que contiene todos los puntos del polyline
      List<LatLng> allPoints = [
        LatLng(origenLatitude, origenLongitude),
        ...polylineCoordinates,
        LatLng(destinoLatitude, destinoLongitude),
      ];

      // Calcula los límites del polyline
      LatLngBounds bounds = boundsFromLatLngList(allPoints);

      // Ajusta la cámara para mostrar los límites del polyline en toda la pantalla
      controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 130.0),
      );
    }

    setState(() {});
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double? minLat, maxLat, minLng, maxLng;

    for (final latLng in list) {
      if (minLat == null || latLng.latitude < minLat) {
        minLat = latLng.latitude;
      }
      if (maxLat == null || latLng.latitude > maxLat) {
        maxLat = latLng.latitude;
      }
      if (minLng == null || latLng.longitude < minLng) {
        minLng = latLng.longitude;
      }
      if (maxLng == null || latLng.longitude > maxLng) {
        maxLng = latLng.longitude;
      }
    }

    return LatLngBounds(
      northeast: LatLng(maxLat!, maxLng!),
      southwest: LatLng(minLat!, minLng!),
    );
  }

  void calculatePolylineDistance() {
    totalDistance = 0.0;

    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      final LatLng start = polylineCoordinates[i];
      final LatLng end = polylineCoordinates[i + 1];

      final double segmentDistance = calculateDistance(start, end);
      totalDistance += segmentDistance;
    }

    totalDistance = double.parse(totalDistance.toStringAsFixed(2));

    if (kDebugMode) {
      print('Distancia total de la polilínea: $totalDistance km');
    }
  }

  double calculateDistance(LatLng start, LatLng end) {
    const int earthRadius = 6371; // Radio de la Tierra en kilómetros

    final double lat1 = start.latitude * pi / 180;
    final double lon1 = start.longitude * pi / 180;
    final double lat2 = end.latitude * pi / 180;
    final double lon2 = end.longitude * pi / 180;

    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;

    final double a =
        pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final double distance = earthRadius * c;
    return distance;
  }

  void calculateTime() {
    // Velocidad promedio a pie en km/h
    const double walkingSpeed = 5.0;

    // Velocidad promedio en automóvil en km/h
    const double carSpeed = 60.0;

    // Calcula el tiempo estimado en minutos
    double walkingTime = (totalDistance / walkingSpeed) * 60;
    double carTime = (totalDistance / carSpeed) * 60;

    // Convierte el tiempo a formato horas:minutos
    String walkingTimeFormatted = formatTime(walkingTime);
    String carTimeFormatted = formatTime(carTime);

    if (kDebugMode) {
      print('Tiempo estimado a pie: $walkingTimeFormatted');
      print('Tiempo estimado en automóvil: $carTimeFormatted');
    }
  }

  String formatTime(double time) {
    int hours = (time / 60).floor();
    int minutes = (time % 60).round();

    String hoursString = hours.toString().padLeft(2, '0');
    String minutesString = minutes.toString().padLeft(2, '0');

    return '$hoursString:$minutesString';
  }

  void calculatePrice() {
    // Precio por kilómetro en bs
    const double pricePerKm = 4.0;

    double price = totalDistance * pricePerKm;
    precio = price;

    if (kDebugMode) {
      print('Precio estimado: \$$price');
    }
  }

  void removeMarker(MarkerId markerId) {
    setState(() {
      markers.removeWhere((marker) => marker.markerId == markerId);
      polylineCoordinates.clear();
    });
  }

  getAddressFromMarker(double latitude, double longitude) async {
    try {
      if (isLoading) {
        setState(() {});
      } else {
        GeoData dataGeo = await Geocoder2.getDataFromCoordinates(
            latitude: latitude,
            longitude: longitude,
            googleMapApiKey: apiGoogle);
        isLoading = false;
        address = dataGeo.address;
        if (kDebugMode) {
          print("Dirección: $address");
        }
        return address;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  getAddressFromLatLng() async {
    try {
      if (isLoading) {
        setState(() {});
      } else {
        GeoData dataGeo = await Geocoder2.getDataFromCoordinates(
            latitude: centerMarkerScreen!.latitude,
            longitude: centerMarkerScreen!.longitude,
            googleMapApiKey: apiGoogle);
        setState(() {
          isLoading = false;
          address = dataGeo.address;
          if (kDebugMode) {
            print("Dirección: $address");
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
      setState(() {
        isLoading = true;
      });
    }
  }

  void startTimer(BuildContext context) {
    int contador = 5;

    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (contador == 0) {
        timer.cancel();
        Navigator.pop(context); // Cerrar el diálogo al terminar el contador
      } else {
        contador--;
      }
    });
  }

  final TextEditingController _searchController = TextEditingController();
  String nombrePerfil = "";
  String nro_registro = "";

  @override
  void initState() {
    _init();
    getCurrentLocation();
    /* cargarDatosStore(); */
    super.initState();
  }

  void cargarDatosStore() async {
    SharedPreferences user = await SharedPreferences.getInstance();
    nombrePerfil = user.getString('nombre')!;
    nro_registro = user.getString('nro_registro')!;
  }

  @override
  void dispose() {
    // Dispose el TextEditingController al finalizar
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: DrawerWidget(
            nombrePerfil: nombrePerfil,
            nro_registroPerfil: nro_registro,
            pageNombre: "Inicio"),
      ),
      body: Stack(
        children: [
          if (currentLocation == null)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: LatLng(
                      currentLocation!.latitude!,
                      currentLocation!.longitude!,
                    ),
                    zoom: 14.5),
                onMapCreated: (GoogleMapController controller) {
                  _completer.complete(controller);
                },
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                trafficEnabled: false,
                mapType: MapType.normal,
                compassEnabled: false,
                markers: markers,
                onCameraMove: (CameraPosition? position) {
                  if (kDebugMode) {
                    print("Camera Move");
                  }
                  isLoading = false;
                  centerMarkerScreen = position!.target;
                  isLoading = true;
                  getAddressFromLatLng();
                },
                onCameraIdle: () {
                  if (kDebugMode) {
                    print("Camera Idle");
                  }
                  isLoading = false;
                  getAddressFromLatLng();
                },
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('polyLine'),
                    color: Colors.blue,
                    points: polylineCoordinates,
                    width: 5,
                  ),
                },
              ),
            ),

          /* Desplegador "Iniciar trabajo" */
          if (mostrarMarkerOrigen == false || mostrarMarkerDestino == false)
            if (destinoLatitude == 0 && destinoLongitude == 0)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 25, right: 25, top: 10, bottom: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: containerprimaryAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        "Iniciar trabajo",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        trabajoIniciado = true;
                        setState(() {});
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            startTimer(context);
                            return AlertDialog(
                              title: const Text('Contador de 10 segundos'),
                              content: HookBuilder(builder: (context) {
                                final contador = useState(10);
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        'Tiempo restante: ${contador.value} segundos'),
                                  ],
                                );
                              }),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),

          /* Desplegador "Contador de 10 segundos" */

          /* Desplegador "Finalizar trabajo" */
          if (trabajoIniciado)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 10, bottom: 10),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Finalizar trabajo'),
                      onPressed: () {
                        if (kDebugMode) {
                          print("Finalizar trabajo");
                        }
                        setState(() {
                          trabajoIniciado = false;
                        });
                      }),
                ),
              ),
            ),

          /* Drawe */
          Container(
            margin: const EdgeInsets.only(top: 40, left: 10),
            child: Builder(
              builder: (BuildContext context) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      heroTag: 'open_drawer',
                      backgroundColor: Colors.black54,
                      elevation: 0,
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: const Icon(Icons.menu, color: Colors.white),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
