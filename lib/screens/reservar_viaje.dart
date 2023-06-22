import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:app_movil/constants/colors.dart';
import 'package:app_movil/controllers/procesoViajeController.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/perfilController.dart';
import '../utils/api_backend.dart';
import '../utils/api_google.dart';
import '../utils/maps_style.dart';

import 'package:image/image.dart' as img;

import 'package:http/http.dart' as http;

import '../widgets/drawer.dart';

class ReservarViajePage extends StatefulWidget {
  ReservarViajePage(
      {required this.polylineCoordinates,
      required this.id_soli_viaje,
      required this.hora_p,
      Key? key})
      : super(key: key);
  final String polylineCoordinates;
  final int id_soli_viaje;
  final String hora_p;

  @override
  State<ReservarViajePage> createState() => _ReservarViajePageState();
}

class _ReservarViajePageState extends State<ReservarViajePage> {
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

  /* Fecha reserva */
  DateTime fechaReserva = DateTime.now();

  /* Hora reserva */
  TimeOfDay horaReserva = TimeOfDay.now();

  /* Cantidad de pasajeros */
  int cantidadPasajeros = 0;

  /* costo total */
  double costoTotal = 0.0;

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

      calculatePolylineDistance(polylineCoordinates);
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

  void calculatePolylineDistance(List<LatLng> polylineCoordinates) {
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

  /* Selecionar Fecha */
  Future<void> seleccionarFecha() async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        Navigator.of(context).pop();
        fechaReserva = fechaSeleccionada;
      });
    }
  }

  /* Seleccionar Hora */
  Future<void> seleccionarHora() async {
    final TimeOfDay? horaSeleccionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (horaSeleccionada != null) {
      setState(() {
        Navigator.of(context).pop();
        horaReserva = horaSeleccionada;
      });
    }
  }

  List<LatLng> decodePolyline() {
    String polylineString = widget.polylineCoordinates;
    List<LatLng> polylineCoordinates = [];

    print("hola");

    final regex = RegExp(r"LatLng\((-?\d+\.\d+), (-?\d+\.\d+)\)");
    final matches = regex.allMatches(polylineString);

    for (final match in matches) {
      double latitude = double.parse(match.group(1)!);
      double longitude = double.parse(match.group(2)!);

      LatLng point = LatLng(latitude, longitude);
      polylineCoordinates.add(point);
    }

    calculatePolylineDistance(polylineCoordinates);
    calculateTime();
    calculatePrice();

    return polylineCoordinates;
  }

  final TextEditingController _searchController = TextEditingController();
  String nombrePerfil = "";
  String nro_registro = "";
  int id_usuario = 0;

  @override
  void initState() {
    _init();
    print("Coordenadas: ");
    print(widget.polylineCoordinates);
    getCurrentLocation();
    cargarDatosStore();
    /* polylineCoordinates = decodePolyline(widget.polylineCoordinates); */
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
            pageNombre: "Reservar viaje"),
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
                    points: decodePolyline(),
                    width: 5,
                  ),
                },
              ),
            ),
          if (destinoLatitude != 0 &&
              destinoLongitude != 0 &&
              mostrarMarkerDestino == false &&
              mostrarMarkerOrigen == false)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 237,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 10,
                    bottom: 10,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "TU VIAJE",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        children: [
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.1,
                                height: MediaQuery.of(context).size.width * 0.1,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: TextFormField(
                                    initialValue: addressOrigen,
                                    readOnly:
                                        true, // Desactivar la edición del campo de texto y el teclado
                                    /* controller: _controller, */
                                    decoration: const InputDecoration(
                                      hintText: 'Ingresa tu ubicación',
                                      hintStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                      ),
                                      labelText: 'Punto de partida',
                                      labelStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                      ),
                                      border: InputBorder.none,
                                      floatingLabelBehavior: FloatingLabelBehavior
                                          .always, // Hace que el labelText sea estático arriba
                                    ),
                                    onTap: () {
                                      _desplegableOrigenDestino(
                                          context); // Mostrar el desplegable cuando se toque el campo de texto
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ]),
                          Padding(
                            padding: const EdgeInsets.only(left: 56, right: 10),
                            child: SizedBox(
                              height: 1,
                              child: Container(
                                color: Colors.grey[300],
                              ),
                            ),
                          ),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.1,
                                height: MediaQuery.of(context).size.width * 0.1,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                child: const Icon(
                                  Icons.flag,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: TextFormField(
                                    initialValue: addressDestino,
                                    readOnly:
                                        true, // Desactivar la edición del campo de texto
                                    decoration: const InputDecoration(
                                      hintText: 'Destino',
                                      hintStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                      ),
                                      labelText: '¿A dónde vas?',
                                      labelStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                      ),
                                      border: InputBorder.none,
                                      floatingLabelBehavior: FloatingLabelBehavior
                                          .always, // Hace que el labelText sea estático arriba
                                    ),
                                    onTap: () {
                                      _desplegableOrigenDestino(
                                          context); // Mostrar el desplegable cuando se toque el campo de texto
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ])
                        ],
                      ),
                      /* Precio */
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Precio: ",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Bs $precio",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side:
                                    const BorderSide(color: Colors.transparent),
                              ),
                            ),
                            onPressed: () {},
                            child: const Icon(
                              Icons.payment,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Reservar viaje",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                double? latitudActual =
                                    currentLocation!.latitude;
                                double? longitudActual =
                                    currentLocation!.longitude;
                                /* hora actual */
                                DateTime now = DateTime.now();
                                procesoViajeController().reservarViaje(
                                    origenLatitude,
                                    origenLongitude,
                                    destinoLatitude,
                                    destinoLongitude,
                                    latitudActual,
                                    longitudActual,
                                    horaReserva as DateTime,
                                    now,
                                    precio,
                                    true,
                                    precio);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          /* Desplegador "¿Donde quieres ir?" */
          if (mostrarMarkerOrigen == false || mostrarMarkerDestino == false)
            if (destinoLatitude == 0 && destinoLongitude == 0)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)),
                  ),
                  child: Column(
                    children: [
                      /* Costo */
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Precio: ",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Bs $precio",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      /* Cantidad pasajeros */
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                /* Botón de disminuir cantidad de pasajeros */
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: const BorderSide(
                                          color: Colors.transparent),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (cantidadPasajeros > 1) {
                                      setState(() {
                                        cantidadPasajeros--;
                                        precio = precio / cantidadPasajeros;
                                        print(precio);
                                      });
                                    }
                                  },
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.black,
                                  ),
                                ),
                                /* Cantidad de pasajeros */
                                Text(
                                  cantidadPasajeros.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                /* Botón de aumentar cantidad de pasajeros */
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: const BorderSide(
                                          color: Colors.transparent),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (cantidadPasajeros < 4) {
                                      setState(() {
                                        cantidadPasajeros++;
                                        precio = precio / cantidadPasajeros;
                                      });
                                    }
                                  },
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
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
                          child: Row(
                            children: [
                              const Text('Reservar carrera'),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 10, bottom: 10),
                                child: SizedBox(
                                  width: 2,
                                  child: Container(
                                    color: containerprimaryAccent,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_forward),
                            ],
                          ),
                          onPressed: () {
                            /* _desplegableOrigenDestino(context); */
                            reservarCarrera(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (mostrarMarkerOrigen || mostrarMarkerDestino)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 130,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 10, bottom: 10),
                  child: Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Aceptar'),
                          onPressed: () {
                            _completer.future
                                .then((GoogleMapController controller) {
                              controller
                                  .getVisibleRegion()
                                  .then((LatLngBounds bounds) {
                                final LatLng centerLatLng = LatLng(
                                  (bounds.northeast.latitude +
                                          bounds.southwest.latitude) /
                                      2,
                                  (bounds.northeast.longitude +
                                          bounds.southwest.longitude) /
                                      2,
                                );
                                if (mostrarMarkerOrigen) {
                                  origenLatitude = centerLatLng.latitude;
                                  origenLongitude = centerLatLng.longitude;
                                  mostrarMarkerOrigen = false;
                                  addMarkerOrigen(
                                      origenLatitude, origenLongitude);
                                } else {
                                  destinoLatitude = centerLatLng.latitude;
                                  destinoLongitude = centerLatLng.longitude;
                                  mostrarMarkerDestino = false;
                                  addMarkerDestino(
                                      destinoLatitude, destinoLongitude);
                                }
                              });
                            });
                          }),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Cancelar'),
                          onPressed: () {
                            if (mostrarMarkerOrigen) {
                              mostrarMarkerOrigen = false;
                              addMarkerOrigen(origenLatitude, origenLongitude);
                            } else {
                              mostrarMarkerDestino = false;
                              addMarkerDestino(
                                  destinoLatitude, destinoLongitude);
                            }
                            setState(() {});
                          }),
                    ],
                  ),
                ),
              ),
            ),
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

          /* Marker Flotante Origen */
          if (mostrarMarkerOrigen)
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 38),
                child: Image.asset(
                  'assets/icons/mark_start.png',
                  width: 50,
                  height: 50,
                ),
              ),
            ),

          /* Texto FLotante de Direccion */
          if (mostrarMarkerOrigen || mostrarMarkerDestino)
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 110),
                child: Container(
                  color: isLoading ? Colors.transparent : Colors.white,
                  child: isLoading
                      ? const SizedBox(
                          width: 30,
                          height: 30,
                          child: SpinKitFadingCircle(
                            color: Colors.green,
                            size: 30,
                          ),
                        )
                      : Text(
                          address,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),

          /* MorKer Flotante Destino */
          if (mostrarMarkerDestino)
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 38),
                child: Image.asset(
                  'assets/icons/mark_end.png',
                  width: 50,
                  height: 50,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void pagarCarrera(id_soli_viaje, precio, context) async {
    int costo = precio ~/ cantidadPasajeros;
    var response = await http.post(Uri.parse('$apiBackend/pago'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "costo": costo,
          "estado_pago": true,
          "costo_total": precio,
          "estado": true,
          "id_soli_viaje": id_soli_viaje,
        }));
    if (response.statusCode == 200) {
      /* AlertDialog Calificar y comentar */
      print("Carrera pagada");
      var calificacion = 0;
      var comentario = "";
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Calificar y comentar'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Califique el viaje'),
                const SizedBox(
                  height: 10,
                ),
                RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 30,
                  itemPadding:
                      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    calificacion = rating.toInt();
                    print(rating);
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text('Comente el viaje'),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  onChanged: (text) {
                    comentario = text;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Comentario',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/reservarViajeLista");
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  var response =
                      await http.post(Uri.parse('$apiBackend/califcom'),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                          },
                          body: jsonEncode(<String, dynamic>{
                            "comentario": comentario,
                            "calificacion": calificacion,
                            "id_usuario": id_usuario,
                            "estado": true,
                            "id_soliviaje": id_soli_viaje,
                          }));
                  if (response.statusCode == 200) {
                    print("Comentario y calificacion agregados");
                    /* Mensaje */
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comentario y calificacion agregados'),
                      ),
                    );

                    Navigator.pushNamed(context, "/reservarViajeLista");
                  } else {
                    print("Error al agregar comentario y calificacion");
                  }
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } else {
      print("Error al pagar la carrera");
    }
  }

  void reservarCarrera(context) async {
    /* print("precio: " + ((precio / cantidadPasajeros).toInt()).toString());
    print("costo Total: " + precio.toString());
    print("id_soli_viaje: " + widget.id_soli_viaje.toString()); */
    var response = await http.post(Uri.parse('$apiBackend/soliviaje'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "strpolyline": widget.polylineCoordinates,
          "hora_p": widget.hora_p,
          "cant_pasajeros": cantidadPasajeros,
          "id_usuario": id_usuario,
          "id_ruta": widget.id_soli_viaje,
        }));
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);
      var data = jsonDecode(response.body);
      String id_soli_viaje = data['soliViaje']['id'].toString();
      /*
      print("id_soli_viaje: " + id_soli_viaje);
      int costo = (precio / cantidadPasajeros).toInt();
      int id_soli = widget.id_soli_viaje.toInt();
      var response2 = await http.post(Uri.parse('$apiBackend/pago/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            "costo": costo ~/ cantidadPasajeros,
            "estado_pago": true,
            "costo_total": costoTotal,
            "estado": true,
            "id_soli_viaje": id_soli_viaje,
          }));
      print(response2.body); */
      /* if (response.statusCode == 200) { */
      showDialog(
        /* Pagar */
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Pagar'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('¿Desea pagar ahora?'),
                const SizedBox(
                  height: 10,
                ),
                const Text('Costo total:'),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  precio.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  /* Mensaje Viaje reservado */
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Viaje reservado'),
                    ),
                  );
                  Navigator.pushNamed(context, "/reservarViajeLista");
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  pagarCarrera(id_soli_viaje, precio, context);
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
        /* TextButton(
            onPressed: () {
              AlertDialog(
                /* Pagar compartido o Pagar todo */
                title: const Text('Pagar'),
                content: const Text('¿Desea pagar ahora?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      pagarCarrera(id_soli_viaje, precio, context);
                    },
                    child: const Text('Pagar todo'),
                  ),
                  TextButton(
                    onPressed: () {
                      var costoCompartido = precio ~/ cantidadPasajeros;
                      pagarCarrera(id_soli_viaje, costoCompartido, context);
                    },
                    child: const Text('Pagar compartido'),
                  ),
                ],
              );
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Aceptar'),
          ),
        ], */
      );
      /* ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Viaje reservado'),
          ),
        );
        Navigator.pushNamed(context, '/reservarViajeLista'); */
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al reservar el viaje'),
        ),
      );
    }
    /* } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al reservar el viaje'),
        ),
      );
    } */
  }

  Future _desplegableOrigenDestino(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            ),
            height: MediaQuery.of(context).size.height * 0.9,
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    height: 5,
                    width: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(
                                  0, 15), // Desplazamiento vertical positivo
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  height:
                                      MediaQuery.of(context).size.width * 0.1,
                                  decoration: const BoxDecoration(
                                    color: primary,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: TextFormField(
                                      initialValue: addressOrigen,
                                      decoration: const InputDecoration(
                                        hintText: 'Ingresa tu ubicación',
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey,
                                        ),
                                        labelText: 'Punto de partida',
                                        labelStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey,
                                        ),
                                        border: InputBorder.none,
                                        floatingLabelBehavior: FloatingLabelBehavior
                                            .always, // Hace que el labelText sea estático arriba
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          /* searchAddr = value; */
                                        });
                                      },
                                    ),
                                  ),
                                  ButtonBar(
                                    buttonPadding: EdgeInsets
                                        .zero, // Elimina el padding de los botones
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          /* _controller.clear(); */
                                        },
                                        icon: const Icon(
                                          Icons.clear,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(0),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                const Color.fromARGB(
                                                    255, 235, 235, 235)),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        )),
                                      ),
                                      onPressed: () {
                                        if (origenLatitude != 0 &&
                                            origenLongitude != 0) {
                                          removeMarker(
                                              const MarkerId('origen'));
                                        }
                                        Navigator.pop(context);
                                        setState(() {
                                          mostrarMarkerOrigen = true;
                                        });
                                      },
                                      child: const Text('Mapa',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                          ))),
                                ],
                              ),
                            ]),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 56, right: 10),
                              child: SizedBox(
                                height: 1,
                                child: Container(
                                  color: Colors.grey[300],
                                ),
                              ),
                            ),
                            Row(children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  height:
                                      MediaQuery.of(context).size.width * 0.1,
                                  decoration: const BoxDecoration(
                                    color: primary,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: const Icon(
                                    Icons.flag,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: TextFormField(
                                      initialValue: addressDestino,
                                      decoration: const InputDecoration(
                                        hintText: 'Destino',
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey,
                                        ),
                                        labelText: '¿A donde vas?',
                                        labelStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey,
                                        ),
                                        border: InputBorder.none,
                                        floatingLabelBehavior: FloatingLabelBehavior
                                            .always, // Hace que el labelText sea estático arriba
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          /* searchAddr = value; */
                                        });
                                      },
                                    ),
                                  ),
                                  ButtonBar(
                                    buttonPadding: EdgeInsets
                                        .zero, // Elimina el padding de los botones
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          /* _controller.clear(); */
                                        },
                                        icon: const Icon(
                                          Icons.clear,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(0),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                const Color.fromARGB(
                                                    255, 235, 235, 235)),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        )),
                                      ),
                                      onPressed: () {
                                        if (destinoLatitude != 0 &&
                                            destinoLongitude != 0) {
                                          removeMarker(
                                              const MarkerId('destino'));
                                        }
                                        Navigator.pop(context);
                                        setState(() {
                                          mostrarMarkerDestino = true;
                                        });
                                      },
                                      child: const Text('Mapa',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                          ))),
                                ],
                              ),
                            ])
                          ],
                        )),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Column(
                          children: [
                            ElevatedButton(
                                onPressed: seleccionarFecha,
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: containerprimaryAccent,
                                    backgroundColor: primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    )),
                                child: const Text(
                                  'Seleccionar fecha',
                                  style: TextStyle(fontSize: 16),
                                )),
                            const SizedBox(height: 5),
                            ElevatedButton(
                              onPressed: seleccionarHora,
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  )),
                              child: const Text(
                                'Seleccionar hora',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Fecha seleccionada: ${fechaReserva.toString()}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Hora seleccionada: ${horaReserva.format(context)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          );
        });
  }
}
