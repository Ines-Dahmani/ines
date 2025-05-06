import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http_parser/http_parser.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? imagePath;
  String? role;
  String? serreId;

  @override
  void initState() {
    super.initState();
    getUserRole();
  }

  Future<String> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Service de localisation désactivé';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'Permission refusée';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Permission refusée définitivement';
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      final placemark = placemarks.first;
      return '${placemark.locality}, ${placemark.country}';
    } else {
      return '${position.latitude}, ${position.longitude}';
    }
  }

  Future<void> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role');
      serreId = prefs.getString('serreId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Capteur Air',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 48) / 2,
                  child: _buildWeatherItem("🌡️", "25° C", "Température"),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 48) / 2,
                  child: _buildWeatherItem("💧", "60%", "Humidité"),
                ),
                SizedBox(
                  width: double.infinity,
                  child: const Text(
                    'Capteur Sol',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 48) / 2,
                  child: _buildWeatherItem("🌡️", "25° C", "Température"),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 48) / 2,
                  child: _buildWeatherItem("💧", "60%", "Humidité"),
                ),
                SizedBox(
                  width: double.infinity,
                  child: const Text(
                    'Autre donne de serre',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 48) / 2,
                  child: _buildWeatherItem("🫁", "450ppm", "CO₂"),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 48) / 2,
                  child: _buildWeatherItem("💨", "1200 lux", "Luminosité"),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Historique',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: [
                        FlSpot(0, 20),
                        FlSpot(1, 23),
                        FlSpot(2, 25),
                        FlSpot(3, 26),
                        FlSpot(4, 28),
                        FlSpot(5, 30),
                        FlSpot(6, 27),
                      ],
                      barWidth: 3,
                      color: Colors.green,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Alertes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const AlertCard(
              title: 'Température critique',
              value: '30°C',
              color: Colors.red,
            ),
            const AlertCard(
              title: 'Humidité faible',
              value: '40%',
              color: Colors.orange,
            ),
            const SizedBox(height: 75),
          ],
        ),
      ),
      floatingActionButton: (role == 'admin')
          ? FloatingActionButton(
              onPressed: () => _showCreateSerreForm(context),
              child: const Icon(Icons.add_box_rounded),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildWeatherInfo() {
    double itemWidth = (MediaQuery.of(context).size.width - 48) / 2;

    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: [
        SizedBox(
          width: itemWidth,
          child: _buildWeatherItem("🌡️", "25° C", "Température"),
        ),
        SizedBox(
          width: itemWidth,
          child: _buildWeatherItem("💧", "60%", "Humidité"),
        ),
        SizedBox(
          width: itemWidth,
          child: _buildWeatherItem("🫁", "450ppm", "CO₂"),
        ),
        SizedBox(
          width: itemWidth,
          child: _buildWeatherItem("💨", "1200 lux", "Luminosité"),
        ),
      ],
    );
  }

  Widget _buildWeatherItem(String icon, String value, String label) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSerreForm(BuildContext context) {
    final nomController = TextEditingController();
    final tailleController = TextEditingController();
    final localisationController = TextEditingController();
    String? localImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateModal) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Créer une nouvelle serre",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nomController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                  TextField(
                    controller: tailleController,
                    decoration: const InputDecoration(labelText: 'Taille'),
                  ),
                  TextField(
                    controller: localisationController,
                    decoration:
                        const InputDecoration(labelText: 'Localisation'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Caméra'),
                        onPressed: () async {
                          final picked = await ImagePicker()
                              .pickImage(source: ImageSource.camera);
                          if (picked != null) {
                            setStateModal(() {
                              localImagePath = picked.path;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo),
                        label: const Text('Galerie'),
                        onPressed: () async {
                          final picked = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            setStateModal(() {
                              localImagePath = picked.path;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (localImagePath != null)
                    Image.file(
                      File(localImagePath!),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.location_on),
                    label: const Text("Utiliser ma position"),
                    onPressed: () async {
                      String location = await getCurrentLocation();
                      localisationController.text = location;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (nomController.text.isEmpty ||
                          tailleController.text.isEmpty ||
                          localisationController.text.isEmpty ||
                          localImagePath == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Tous les champs sont requis.")),
                        );
                        return;
                      }

                      try {
                        FormData formData = FormData.fromMap({
                          'nom': nomController.text,
                          'taille': tailleController.text,
                          'localisation': localisationController.text,
                          'image': await MultipartFile.fromFile(
                            localImagePath!,
                            filename: 'image.jpg',
                            contentType: MediaType('image', 'jpeg'),
                          ),
                        });

                        var res = await ApiService.postRequestImage(
                            'serres', formData);

                        // Actualiser la liste des serres après création (par exemple, si tu as une méthode pour la récupérer)
                        setState(() {
                          // Recharger ou ajouter la nouvelle serre à ta liste locale de serres ici si nécessaire
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Serre créée avec succès.")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Erreur lors de la création.")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 145, 189, 146),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      shadowColor: Colors.grey.withOpacity(0.5),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    child: const Text("Créer"),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

class AlertCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const AlertCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
