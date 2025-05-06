import 'package:flutter/material.dart';
import 'package:mobile/screens/ConnexionPage.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ParametrePage extends StatefulWidget {
  const ParametrePage({Key? key}) : super(key: key);

  @override
  State<ParametrePage> createState() => _ParametrePageState();
}

class _ParametrePageState extends State<ParametrePage> {
  bool _notificationsEnabled = true;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _loadPreferences();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(
          'https://www.youtube.com/embed/KVH3Jdc4Gls?autoplay=1&mute=1'));
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _updateNotificationPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Activer ou désactiver les notifications'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: _updateNotificationPreference,
              ),
            ),
            const Divider(),
            Card(
              elevation: 5,
              child: SizedBox(
                height: 300, // hauteur fixe
                child: WebViewWidget(controller: _controller),
              ),
            ),
            ListTile(
              title: const Text('Déconnexion'),
              subtitle: const Text('Se déconnecter de l\'application'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Déconnexion'),
                      content: const Text(
                          'Êtes-vous sûr de vouloir vous déconnecter ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.clear();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ConnexionPage()),
                            );
                          },
                          child: const Text('Déconnexion'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
