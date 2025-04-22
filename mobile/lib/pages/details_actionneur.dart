import 'package:flutter/material.dart';
import 'package:mobile/services/api_services.dart';

class DetailsActionneurPage extends StatefulWidget {
  final String actionneurId;

  const DetailsActionneurPage({Key? key, required this.actionneurId})
      : super(key: key);

  @override
  State<DetailsActionneurPage> createState() => _DetailsActionneurPageState();
}

class _DetailsActionneurPageState extends State<DetailsActionneurPage> {
  Map<String, dynamic> actionneur = {};
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchActionneurDetails();
  }

  Future<void> fetchActionneurDetails() async {
    try {
      var data =
          await ApiService.getRequest('actionneurs/${widget.actionneurId}');
      setState(() {
        actionneur = data;
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Erreur de récupération des détails de l\'actionneur : $e');
    }
  }

  Future<void> toggleActionneurStatus(bool newStatus) async {
    try {
      await ApiService.putRequest(
        'actionneurs/${widget.actionneurId}',
        {
          'status': newStatus,
        },
      );
      setState(() {
        actionneur['status'] = newStatus;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la mise à jour.")),
      );
    }
  }

  Future<void> deleteActionneur() async {
    try {
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmer la suppression'),
          content:
              const Text('Es-tu sûr de vouloir supprimer cet actionneur ?'),
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
        await ApiService.deleteRequest('actionneurs/${widget.actionneurId}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Actionneur supprimé avec succès")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la suppression.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails de l\'Actionneur'),
          backgroundColor: Colors.green,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails de l\'Actionneur'),
          backgroundColor: Colors.green,
        ),
        body: const Center(
          child: Text('Erreur lors du chargement des détails.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(actionneur['nom'] ?? 'Actionneur'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: actionneur['image'] != null
                    ? Image.network(
                        '${ApiService.baseUrlImg}${actionneur['image']}',
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
              actionneur['name'] ?? 'Nom inconnu',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Type: ${actionneur['type'] ?? 'Inconnu'}",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              "Valeur : ${actionneur['valeur'] ?? 'N/A'} unités",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              "Statut : ${(actionneur['status']) ? 'Activé' : 'Désactivé'}",
              style: TextStyle(
                fontSize: 18,
                color: (actionneur['status']) ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                toggleActionneurStatus((actionneur['status']) ? false : true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    (actionneur['status']) ? Colors.green : Colors.orange,
              ),
              child: Text(
                (actionneur['status']) ? 'Mettre en pause' : 'Lancer',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: deleteActionneur,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text('Supprimer',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
