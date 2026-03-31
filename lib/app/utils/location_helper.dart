import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'app_logger.dart';

class LocationHelper {
  static Future<Map<String, String>?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.w('Location services are disabled', tag: 'LocationHelper');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppLogger.w('Location permissions denied', tag: 'LocationHelper');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppLogger.w('Location permissions permanently denied',
            tag: 'LocationHelper');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = 'Unknown';
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        address =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country} - ${place.postalCode}';
      }

      return {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
        'address': address,
      };
    } catch (e) {
      AppLogger.e('Error getting location: $e', tag: 'LocationHelper');
      return null;
    }
  }
}
