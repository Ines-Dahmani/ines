import 'package:flutter/material.dart';
import 'package:mobile/pages/details_capteur.dart';
import 'package:mobile/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class CapteurPage extends StatefulWidget {
  const CapteurPage({Key? key}) : super(key: key);

  @override
  CapteurPageState createState() => CapteurPageState();
}

class CapteurPageState extends State<CapteurPage> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> allCapteurs = [];
  List<dynamic> filteredCapteurs = [];
  String? role;

  @override
  void initState() {
    super.initState();
    fetchCapteurs();
    getUserRole();
  }

  Future<void> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role');
    });
  }

  Future<void> fetchCapteurs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? serreId = prefs.getString('serreId');

    if (serreId == null) {
      print("⚠️ serreId est null !");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucune serre sélectionnée.")),
      );
      return;
    }

    try {
      List<dynamic> data =
          await ApiService.getRequest('capteurs/bySerre/$serreId');
      setState(() {
        allCapteurs = data;
        filteredCapteurs = List.from(data);
      });
    } catch (e) {
      print("Erreur de récupération des capteurs : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de récupération des capteurs.")),
      );
    }
  }

  void filterCapteurs(String query) {
    setState(() {
      filteredCapteurs = allCapteurs
          .where((capteur) => (capteur['nom']?.toLowerCase() ?? '')
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Rechercher un capteur...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: filterCapteurs,
            ),
          ),
          Expanded(
            child: filteredCapteurs.isEmpty
                ? const Center(child: Text("Aucun capteur trouvé"))
                : SingleChildScrollView(
                    child: Wrap(
                      children: filteredCapteurs.map((capteur) {
                        return SizedBox(
                          width: itemWidth,
                          height: 150,
                          child: buildCapteurCard(
                            imagePath: capteur['image'] ?? '',
                            value: capteur['valeur']?.toString() ?? 'N/A',
                            label: capteur['nom'] ?? 'Nom inconnu',
                            status: capteur['status'] ?? false,
                            capteurId: capteur['_id'] ?? '',
                            capteurData: capteur,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: (role == 'admin')
          ? FloatingActionButton(
              onPressed: () => showCreateCapteurForm(context),
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void showCreateCapteurForm(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    String? selectedType;
    String? selectedImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Créer un nouveau capteur",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nom"),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration:
                        const InputDecoration(labelText: "Type de capteur"),
                    items: [
                      'Température',
                      'Humidité',
                      'Luminosité',
                      'CO2',
                      'Humidité du sol',
                    ].map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final image = await ImagePicker()
                              .pickImage(source: ImageSource.camera);
                          if (image != null) {
                            setModalState(() {
                              selectedImagePath = image.path;
                            });
                          }
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Caméra"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final image = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setModalState(() {
                              selectedImagePath = image.path;
                            });
                          }
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text("Galerie"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String? serreId = prefs.getString('serreId');

                      if (serreId == null ||
                          nameController.text.isEmpty ||
                          selectedType == null ||
                          selectedImagePath == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Veuillez remplir tous les champs.")),
                        );
                        return;
                      }

                      try {
                        var formData = FormData.fromMap({
                          'nom': nameController.text,
                          'type': selectedType,
                          'serre': serreId,
                          'image': await MultipartFile.fromFile(
                            selectedImagePath!,
                            filename: 'capteur.jpg',
                          ),
                        });

                        await ApiService.postRequest("capteurs", formData);

                        if (context.mounted) Navigator.pop(context);
                        fetchCapteurs();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Capteur ajouté avec succès.")),
                        );
                      } catch (e) {
                        print("Erreur lors de la création : $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Erreur lors de la création du capteur.")),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget buildCapteurCard({
    required String imagePath,
    required String value,
    required String label,
    required bool status,
    required String capteurId,
    required Map<String, dynamic> capteurData,
  }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
      child: Row(
        children: [
          imagePath.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      ApiService.baseUrlImg + imagePath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : const SizedBox(width: 100, height: 100),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Valeur: $value'),
                  const SizedBox(height: 4),
                  Text(
                    status ? 'Activé' : 'Désactivé',
                    style: TextStyle(
                      color: status ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailsCapteurPage(capteurId: capteurId),
                        ),
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text(
                      'Détails',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
