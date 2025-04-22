import 'package:flutter/material.dart';
import 'package:mobile/services/api_services.dart';

class DetailsCapteurPage extends StatefulWidget {
  final String capteurId;

  const DetailsCapteurPage({Key? key, required this.capteurId})
      : super(key: key);

  @override
  State<DetailsCapteurPage> createState() => _DetailsCapteurPageState();
}

class _DetailsCapteurPageState extends State<DetailsCapteurPage> {
  Map<String, dynamic> capteur = {};
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCapteurById();
  }

  // Récupération des infos du capteur
  Future<void> fetchCapteurById() async {
    try {
      Map<String, dynamic> data =
          await ApiService.getRequest('capteurs/${widget.capteurId}');
      setState(() {
        capteur = data;
        isLoading = false;
      });
    } catch (e) {
      print("Erreur de récupération des capteurs : $e");
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de récupération des données du capteur.';
      });
    }
  }

  // Suppression du capteur
  Future<void> deleteCapteur() async {
    try {
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Es-tu sûr de vouloir supprimer ce capteur ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await ApiService.deleteRequest('capteurs/${widget.capteurId}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Capteur supprimé avec succès")),
        );
        Navigator.pop(context); // Retour à la page précédente
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la suppression.")),
      );
    }
  }

  // Désactivation du capteur (Pause)
  Future<void> toggleCapteurStatus(bool newStatus) async {
    try {
      await ApiService.putRequest(
        'capteurs/${capteur['_id']}',
        {'status': newStatus}, // Changer le statut pour "désactif"
      );
      setState(() {
        capteur['status'] = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Capteur mis en pause")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Erreur lors de la désactivation du capteur.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(capteur['nom'] ?? 'Capteur'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child:
                      Text(errorMessage, style: TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: capteur['image'] != null
                              ? Image.network(
                                  '${ApiService.baseUrlImg}${capteur['image']}',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image_not_supported,
                                  size: 100, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        capteur['nom'] ?? 'Nom inconnu',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Type : ${capteur['type'] ?? 'Inconnu'}",
                        style:
                            const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Valeur : ${capteur['valeur'] ?? 'N/A'} unités",
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Statut : ${capteur['status'] ? 'Activé' : 'Désactivé'}",
                        style: TextStyle(
                          fontSize: 18,
                          color:
                              capteur['status'] ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            toggleCapteurStatus(
                                (capteur['status']) ? false : true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: capteur['status']
                                ? Colors.green
                                : Colors.orange,
                          ),
                          child: Text(
                            capteur['status'] ? 'Lancer' : 'Mettre en pause',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: deleteCapteur,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text('Supprimer',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
