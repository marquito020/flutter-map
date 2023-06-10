import 'dart:async';
import 'dart:convert';

import 'package:app_movil/utils/maps_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Completer<GoogleMapController> _completer = Completer();
  LocationData? currentLocation;
  bool perseguirUbicacion = false;
  bool mostrarMarcador = true;
  Set<Marker> markers = {}; // Conjunto de marcadores

  List<LatLng> polylineCoordinates = [];

  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(19.431821420416085, -99.13240671157838),
    zoom: 14.4746,
  );

  Future<GoogleMapController> get _mapController async {
    return await _completer.future;
  }

  _init() async {
    (await _mapController).setMapStyle(jsonEncode(mapStyle));
  }

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((LocationData locationData) {
      setState(() {
        currentLocation = locationData;
      });
    });

    GoogleMapController googleMapController = await _completer.future;

    location.onLocationChanged.listen((LocationData locationData) {
      setState(() {
        if (perseguirUbicacion) {
          googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(locationData.latitude!, locationData.longitude!),
                zoom: 13.5,
              ),
            ),
          );
        }
        currentLocation = locationData;
      });
    });
  }

  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) async {
    final GoogleMapController controller = await _mapController;
    return controller.getLatLng(screenCoordinate);
  }

  void addMarker(LatLng position) async {
    final ByteData imageData = await rootBundle.load('assets/icons/mark.png');
    final Uint8List bytes = imageData.buffer.asUint8List();
    final img.Image? originalImage = img.decodeImage(bytes);
    final img.Image resizedImage =
        img.copyResize(originalImage!, width: 88, height: 140);
    final resizedImageData = img.encodePng(resizedImage);
    final BitmapDescriptor bitmapDescriptor =
        BitmapDescriptor.fromBytes(resizedImageData);

    final newMarker = Marker(
      markerId: MarkerId(DateTime.now().millisecondsSinceEpoch.toString()),
      position: position,
      icon: bitmapDescriptor,
    );
    setState(() {
      markers.add(newMarker);
      createPolylines(position);
    });
  }

  void createPolylines(LatLng position) async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyB7NyPjOpe124gfoeWrg_8Knwv-rcvslT8",
      PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      PointLatLng(position.latitude, position.longitude),
    );

    if (result.status == 'OK') {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    mostrarMarcador = false;

    setState(() {});
  }

  void removeMarker(MarkerId markerId) {
    setState(() {
      markers.removeWhere((marker) => marker.markerId == markerId);
      polylineCoordinates.clear();
      mostrarMarcador = true;
    });
  }

  @override
  void initState() {
    _init();
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: (GoogleMapController controller) {
                _completer.complete(controller);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: markers,
              polylines: {
                Polyline(
                  polylineId: const PolylineId('polyLine'),
                  color: Colors.red,
                  points: polylineCoordinates,
                  width: 5,
                ),
              },
              onTap: (LatLng position) {
                if (markers.isEmpty) {
                  addMarker(position);
                } else {
                  removeMarker(markers.first.markerId);
                }
              },
            ),
          ),
          if (mostrarMarcador)
            Center(
              heightFactor: 13.0,
              child: Opacity(
                opacity: markers.isEmpty ? 1.0 : 0.0,
                child: Image.asset(
                  'assets/icons/mark.png',
                  width: 50,
                  height: 50,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _completer.future.then((GoogleMapController controller) {
                controller.getVisibleRegion().then((LatLngBounds bounds) {
                  final LatLng centerLatLng = LatLng(
                    (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
                    (bounds.northeast.longitude + bounds.southwest.longitude) /
                        2,
                  );
                  if (markers.isEmpty) {
                    addMarker(centerLatLng);
                  } else {
                    removeMarker(markers.first.markerId);
                  }
                });
              });
            },
            child: markers.isEmpty
                ? const Icon(Icons.add_location)
                : const Icon(Icons.delete),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () async {
              final GoogleMapController controller = await _mapController;
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(
                      currentLocation!.latitude!,
                      currentLocation!.longitude!,
                    ),
                    zoom: 18,
                  ),
                ),
              );
            },
            child: const Icon(Icons.gps_fixed),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                perseguirUbicacion = !perseguirUbicacion;
              });
            },
            child: const Icon(Icons.location_searching),
          ),
        ],
      ),
    );
  }
}
