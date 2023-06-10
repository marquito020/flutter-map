/* import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class RequestPermission extends StatefulWidget {
  const RequestPermission({super.key});

  @override
  State<RequestPermission> createState() => _RequestPermissionState();
}

class _RequestPermissionState extends State<RequestPermission>
    with WidgetsBindingObserver {
  bool _fromSettings = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kDebugMode) {
      print("AppLifecycleState::: $state");
    }

    if (state == AppLifecycleState.resumed && _fromSettings) {
      _check();
    }
  }

  _check() async {
    final bool hasAccess = await Permission.locationWhenInUse.isGranted;
    if (hasAccess) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/request_permission');
    }
  }

  Future<void> _request() async {
    final PermissionStatus status =
        await Permission.locationWhenInUse.request();

    if (kDebugMode) {
      print("status $status");
    }

    switch (status) {
      case PermissionStatus.denied:
        break;
      case PermissionStatus.granted:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case PermissionStatus.restricted:
        break;
      case PermissionStatus.limited:
        break;
      case PermissionStatus.permanentlyDenied:
        await openAppSettings();
        _fromSettings = true;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
          width: double.infinity,
          height: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Necesitamos tu permiso para acceder a tu ubicación',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: this._request,
                child: const Text('Permitir acceso'),
              ),
            ],
          )),
    );
  }
}
 */