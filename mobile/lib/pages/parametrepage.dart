import 'package:flutter/material.dart';
import 'package:mobile/screens/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParametrePage extends StatefulWidget {
  const ParametrePage({Key? key}) : super(key: key);

  @override
  State<ParametrePage> createState() => _ParametrePageState();
}

class _ParametrePageState extends State<ParametrePage> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
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
      appBar: AppBar(
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Notifications
            ListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Activer ou désactiver les notifications'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: _updateNotificationPreference,
              ),
            ),
            const Divider(),

            ListTile(
              title: const Text('Configuration MQTT'),
              subtitle: const Text('Gérer votre configuration'),
              onTap: () {
                // À implémenter
              },
            ),
            const Divider(),

            ListTile(
              title: const Text('Compte'),
              subtitle: const Text('Gérer votre compte et vos informations'),
              onTap: () {
                // À implémenter
              },
            ),
            const Divider(),

            ListTile(
              title: const Text('Sécurité et autorisation'),
              subtitle: const Text(
                  'Gérer les autorisations et la sécurité de votre compte'),
              onTap: () {
                // À implémenter
              },
            ),
            const Divider(),

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
                                  builder: (context) => const Signin()),
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
