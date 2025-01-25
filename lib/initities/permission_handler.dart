import 'dart:async';
import 'package:permission_handler/permission_handler.dart';


enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
}

Future<LocationPermissionStatus> getLocationPermission() async {

  if (!await Permission.location.serviceStatus.isEnabled) {
    return LocationPermissionStatus.serviceDisabled;
  }

  final locationStatus = await Permission.location.status;

  if (locationStatus.isDenied) {
    final result = await Permission.location.request();
    if (result.isGranted) {
      return LocationPermissionStatus.granted;
    } else {
      return LocationPermissionStatus.denied;
    }
  } else if (locationStatus.isPermanentlyDenied) {
    openAppSettings();
    return LocationPermissionStatus.permanentlyDenied;
  }
  return LocationPermissionStatus.granted; // Fallback case
}