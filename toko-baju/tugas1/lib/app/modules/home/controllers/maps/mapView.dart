
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tugas_1/app/modules/home/controllers/maps/mapController.dart';

class Mapview extends StatefulWidget {
  const Mapview({super.key});

  @override
  State<Mapview> createState() => _HomeViewState();
}

class _HomeViewState extends State<Mapview> {
  TextEditingController addressController = TextEditingController();
  ferdhantController homeController = Get.put(ferdhantController());
  final MapController _mapController =
      MapController(); // Menambahkan MapController

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Koordinat'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Masukkan Alamat",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _convertAddressToLatLng,
            child: const Text('Cari Lokasi'),
          ),
          const SizedBox(height: 20),
          homeController.loading.value
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: homeController.getCurrentLocation,
                  child: const Text('Cari Lokasi'),
                ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: homeController.openGoogleMaps,
            child: const Text('Buka Google Maps'),
          ),
          Obx(() => Text(homeController.locationMessage.value)),
          Expanded(
            child: FlutterMap(
              mapController:
                  homeController.mapController, // Menambahkan controller peta
              options: MapOptions(
                initialCenter:
                    LatLng(0, 0), // Memastikan peta dimulai pada lokasi default
                initialZoom: 16.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://tile.openstreetmap.org/{z}/{x}/{y}.png", // URL tanpa subdomain
                ),
                MarkerLayer(
                  markers: homeController.currentLocation == null
                      ? []
                      : [
                          Marker(
                            point: homeController.currentLocation!,
                            width: 40.0,
                            height: 40.0,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 30.0,
                            ),
                          ),
                        ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk mengonversi alamat menjadi latitude dan longitude
  Future<void> _convertAddressToLatLng() async {
    try {
      // Mengambil geocode (latitude dan longitude) dari alamat yang dimasukkan
      List<Location> locations =
          await locationFromAddress(addressController.text);
      print('Lokasi ditemukan: ${locations}');

      if (locations.isNotEmpty) {
        setState(() {
          homeController.locationMessage.value =
              'Latitude: ${locations.first.latitude}, Longitude: ${locations.first.longitude}';
          homeController.currentLocation =
              LatLng(locations.first.latitude, locations.first.longitude);
        });
        // Memindahkan peta ke lokasi yang ditemukan
        homeController.mapController
            .move(homeController.currentLocation!, 16.0);
      } else {
        _showError("Alamat tidak ditemukan");
      }
    } catch (e) {
      _showError("Terjadi kesalahan: $e");
    }
  }

  // Fungsi untuk menampilkan pesan error
  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}