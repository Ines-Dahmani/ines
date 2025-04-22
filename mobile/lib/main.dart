import 'package:flutter/material.dart';
import 'package:mobile/screens/loading.dart';
import 'package:mobile/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/pages/home.dart';
import 'package:mobile/pages/capteurPage.dart';
import 'package:mobile/pages/actionneurPage.dart';
import 'package:mobile/pages/parametrePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Application de Serre Agricole',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? token;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Liste des pages principales
  final List<Widget> _pages = [
    const HomePage(),
    const CapteurPage(),
    const ActionneurPage(),
    const ParametrePage(),
  ];

  // Titres correspondants à chaque page
  final List<String> _pageTitles = [
    'Accueil',
    'Capteur',
    'Actionneur',
    'Paramètres',
  ];

  // Changement d’onglet
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Vérifie le token dans SharedPreferences
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
  }

  var selectedSerre = '';
  void _showSerreSelectionDialog() async {
    try {
      // Appelle l'API pour récupérer les serres
      final serres = await ApiService.getRequest('serres');
      if (serres != null && serres is List) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Choisir une serre"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: serres.map<Widget>((serre) {
                  final id = serre['_id']; // ou serre['id'] selon ta structure
                  final name = serre['nom']; // à adapter selon ton modèle

                  return ListTile(
                    title: Text(name ?? id),
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString('serreId', id);

                      setState(() {
                        selectedSerre = name ?? id;
                      });

                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MainPage()),
                      );
                      // Optionnel : recharger les capteurs pour cette serre
                      // await _fetchCapteursBySerreId(id);
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      } else {
        _showError("Aucune serre trouvée.");
      }
    } catch (e) {
      _showError("Erreur lors du chargement des serres.");
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Erreur"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Si l’utilisateur n’est pas connecté
    if (token == null) {
      return const LoadingPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_pageTitles[_selectedIndex], style: TextStyle(fontSize: 20)),
            ElevatedButton.icon(
              onPressed: () {
                _showSerreSelectionDialog();
              },
              icon: const Icon(Icons.arrow_drop_down),
              label: Text(selectedSerre, style: const TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                backgroundColor: Colors.green.shade100,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.device_hub),
            label: 'Capteur',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_input_antenna),
            label: 'Actionneur',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
