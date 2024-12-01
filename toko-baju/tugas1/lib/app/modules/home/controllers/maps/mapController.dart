import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class ferdhantController extends GetxController {
  //TODO: Implement HomeController

  final MapController mapController = MapController();
  LatLng? currentLocation;
  RxString locationMessage = "Mencari Lat dan Long...".obs;
  RxBool loading = false.obs;

  Future<void> getCurrentLocation() async {
    loading.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        throw Exception('Location service not enabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied forever');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      print(position);
      locationMessage.value =
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
      currentLocation = LatLng(position.latitude, position.longitude);
      mapController.move(LatLng(position.latitude, position.longitude), 16.0);
    } catch (e) {
      locationMessage.value = 'Gagal mendapatkan lokasi';
    } finally {
      loading.value = false;
    }
  }

  void openGoogleMaps() async {
    if (currentLocation != null) {
      final url =
          'https://www.google.com/maps?q=${currentLocation?.latitude},${currentLocation?.longitude}';
      launchURL(url);
    }
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}