import 'package:flutter/material.dart';
import 'package:mobile/pages/details_actionneur.dart';
import 'package:mobile/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class ActionneurPage extends StatefulWidget {
  const ActionneurPage({Key? key}) : super(key: key);

  @override
  ActionneurPageState createState() => ActionneurPageState();
}

class ActionneurPageState extends State<ActionneurPage> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> allActionneurs = [];
  List<dynamic> filteredActionneurs = [];
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    fetchActionneurs(); // Récupère les actionneurs depuis l’API.
    checkUserRole(); // Vérifie si l'utilisateur est admin via SharedPreferences.
  }

  Future<void> checkUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    setState(() {
      isAdmin = (role == 'admin');
    });
  }

  Future<void> fetchActionneurs() async {
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
          await ApiService.getRequest('actionneurs/bySerre/$serreId');
      setState(() {
        allActionneurs = data;
        filteredActionneurs = List.from(data);
      });
    } catch (e) {
      print("Erreur de récupération des actionneurs : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Erreur de récupération des actionneurs.")),
      );
    }
  }

  void filterActionneurs(String query) {
    setState(() {
      filteredActionneurs = allActionneurs
          .where((actionneur) => (actionneur['name']?.toLowerCase() ?? '')
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
                hintText: "Rechercher un actionneur...",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: filterActionneurs,
            ),
          ),
          Expanded(
            child: filteredActionneurs.isEmpty
                ? const Center(child: Text("Aucun actionneur trouvé"))
                : SingleChildScrollView(
                    child: Wrap(
                      children: filteredActionneurs.map((actionneur) {
                        return SizedBox(
                          width: itemWidth,
                          height: 150,
                          child: buildActionneurItem(
                            imagePath: actionneur['image'] ?? '',
                            value: actionneur['valeur']?.toString() ?? 'N/A',
                            label: actionneur['name'] ?? 'Nom inconnu',
                            status: actionneur['status'],
                            actionneurId: actionneur['_id'] ?? '',
                            actionneurData: actionneur,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                showCreateActionneurForm(context);
              },
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void showCreateActionneurForm(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    String? selectedImagePath;
    String? selectedType; // Déclare ici la variable selectedType

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
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
                const Text("Créer un nouvel actionneur",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nom"),
                ),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: "Type"),
                  items: [
                    "Pompe",
                    "Ventilateur",
                    "Éclairage",
                    "Chauffage",
                    "Brumisateur",
                  ].map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
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
                          setState(() {
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
                          setState(() {
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
                            content: Text("Veuillez remplir tous les champs.")),
                      );
                      return;
                    }

                    try {
                      FormData formData = FormData.fromMap({
                        'name': nameController.text,
                        'type': selectedType,
                        'serreId': serreId,
                        'status': false,
                        'image': await MultipartFile.fromFile(
                          selectedImagePath!,
                          filename: 'actionneur.jpg',
                          contentType: MediaType('image', 'jpeg'),
                        ),
                      });

                      await ApiService.postRequestImage(
                          "actionneurs", formData);

                      Navigator.pop(context);
                      fetchActionneurs();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Actionneur ajouté avec succès.")),
                      );
                    } catch (e) {
                      print("Erreur lors de la création : $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Erreur lors de la création de l'actionneur.")),
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
      },
    );
  }

  Widget buildActionneurItem({
    required String imagePath,
    required String value,
    required String label,
    required bool status,
    required String actionneurId,
    required Map<String, dynamic> actionneurData,
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
                      fit: BoxFit.fill,
                    ),
                  ),
                )
              : const SizedBox(),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150,
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                status ? 'Activé' : 'Désactivé',
                style: TextStyle(color: status ? Colors.green : Colors.red),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailsActionneurPage(actionneurId: actionneurId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 177, 224, 177)),
                    child: const Text(
                      'Détails',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
