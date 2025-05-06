import 'package:flutter/material.dart';
import 'package:mobile/screens/loading.dart';
import 'package:mobile/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/pages/home.dart';
import 'package:mobile/pages/capteurPage.dart';
import 'package:mobile/pages/actionneurPage.dart';
import 'package:mobile/pages/parametrePage.dart';
import 'package:mobile/pages/userPage.dart';

void main() {
  runApp(const MyApp());
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
      home: const MainPage(),
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
  String selectedSerre = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  final List<Widget> _pages = [
    const HomePage(),
    const CapteurPage(),
    const ActionneurPage(),
    UserPage(),
    const ParametrePage(),
  ];

  final List<String> _pageTitles = [
    'Accueil',
    'Capteur',
    'Actionneur',
    'Utilisateurs',
    'Paramètres',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
      selectedSerre = prefs.getString('serreName') ?? '';
    });
  }

  void _showSerreSelectionDialog() async {
    try {
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
                  final id = serre['_id']?.toString() ?? '';
                  final name = serre['nom']?.toString() ?? '';
                  return ListTile(
                    leading: const Icon(Icons.eco, color: Colors.green),
                    title: Text(name),
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString('serreId', id);
                      await prefs.setString('serreName', name);
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainPage(),
                        ),
                      );
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
    if (token == null) {
      return const LoadingPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_pageTitles[_selectedIndex],
                style: const TextStyle(fontSize: 20)),
            ElevatedButton.icon(
              onPressed: _showSerreSelectionDialog,
              icon: const Icon(Icons.arrow_drop_down),
              label: Text(
                selectedSerre.isNotEmpty ? selectedSerre : "Aucune sélection",
                style: const TextStyle(fontSize: 14),
              ),
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
        backgroundColor: const Color.fromARGB(255, 186, 224, 187),
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
            icon: Icon(Icons.person_add),
            label: 'Utilisateurs',
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
