import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _searchController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serreIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<dynamic> allUsers = [];
  List<dynamic> filteredUsers = [];
  List<String> _serres = [];
  List<String> _allSerres = [];
  List<String> _selectedSerres = [];

  String _selectedRole = 'user';
  final List<String> _roles = ['admin', 'user'];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<List<dynamic>> fetchAllSerres() async {
    try {
      final response = await ApiService.getRequest('serres');
      return List<dynamic>.from(
          response); // supposer que chaque serre a un champ "nom"
    } catch (e) {
      print("Erreur de récupération des serres : $e");
      return [];
    }
  }

  Future<void> fetchUsers() async {
    try {
      final response = await ApiService.getRequest('auth/users');
      setState(() {
        allUsers = response;
        filteredUsers = List.from(allUsers);
      });
    } catch (e) {
      print("Erreur de récupération des Users : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Erreur de récupération des utilisateurs.")),
      );
    }
  }

  void filterUsers(String query) {
    setState(() {
      filteredUsers = allUsers
          .where((user) => (user['username']?.toLowerCase() ?? '')
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showAddUserSheet({Map<String, dynamic>? user}) {
    if (user != null) {
      _usernameController.text = user["username"] ?? '';
      _selectedRole = user["role"] ?? 'user';
      _emailController.text = user["email"] ?? '';
    } else {
      _usernameController.clear();
      _passwordController.clear();
      _emailController.clear();
      _serreIdController.clear();
      _selectedRole = 'user';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    user != null
                        ? 'Modifier utilisateur'
                        : 'Ajouter un utilisateur',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: "Nom d'utilisateur"),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Veuillez entrer un nom'
                        : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un email';
                      }
                      final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) return 'Email invalide';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Mot de passe'),
                    validator: (value) {
                      if (user == null) {
                        if (value == null || value.isEmpty)
                          return 'Mot de passe requis';
                        if (value.length < 6) return 'Min 6 caractères';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: InputDecoration(labelText: 'Rôle'),
                    items: _roles
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedRole = value ?? 'user'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Sélectionnez un rôle'
                        : null,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final username = _usernameController.text.trim();
                        final password = _passwordController.text.trim();
                        final email = _emailController.text.trim();

                        if (user != null) {
                          var formData = {
                            "_id": user["_id"],
                            "username": username,
                            "password": password,
                            "role": _selectedRole,
                            "email": email,
                          };
                          await ApiService.putRequest("auth/update", formData);
                        } else {
                          var formData = {
                            "username": username,
                            "password": password,
                            "type": _selectedRole,
                            "email": email,
                          };
                          await ApiService.postRequest(
                              "auth/register", formData);
                        }

                        Navigator.pop(context);
                        await fetchUsers();
                      }
                    },
                    child: Text(
                        user != null ? "Modifier" : "Ajouter l'utilisateur"),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteUser(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer'),
        content: Text('Voulez-vous vraiment supprimer cet utilisateur ?'),
        actions: [
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Supprimer'),
            onPressed: () async {
              Navigator.pop(context);
              // Suppression via ApiService.deleteRequest(...)
              await ApiService.deleteRequest("auth/delete/$userId");
              await fetchUsers();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _serreIdController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showSerreSelectionDialog(Map<String, dynamic> user) async {
    List<dynamic> allSerres = await fetchAllSerres();
    List<Map<String, dynamic>> selectedSerres =
        List<Map<String, dynamic>>.from(user["serres"] ?? []);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Ajouter des serres à ${user['username']}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setStateBottomSheet) {
                              return ListView(
                                shrinkWrap: true,
                                children: allSerres.map((serre) {
                                  return CheckboxListTile(
                                    title: Text(serre['nom']),
                                    value: selectedSerres
                                        .any((s) => s['_id'] == serre['_id']),
                                    onChanged: (bool? selected) {
                                      setStateBottomSheet(() {
                                        if (selected == true) {
                                          selectedSerres.add({
                                            '_id': serre['_id'],
                                            'nom': serre['nom']
                                          });
                                        } else {
                                          selectedSerres.removeWhere(
                                              (s) => s['_id'] == serre['_id']);
                                        }
                                      });
                                      setStateDialog(() {});
                                    },
                                  );
                                }).toList(),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedSerres.isEmpty
                                  ? "Sélectionner les serres"
                                  : selectedSerres
                                      .map((s) => s['nom'])
                                      .join(', '),
                              style: const TextStyle(color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Enregistrer"),
                  onPressed: () async {
                    var formData = {
                      "_id": user["_id"],
                      "serres": selectedSerres.map((s) => s['_id']).toList(),
                    };
                    await ApiService.putRequest("auth/update/serre", formData);
                    Navigator.pop(context);
                    await fetchUsers();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: filterUsers,
              decoration: InputDecoration(
                labelText: "Rechercher un utilisateur",
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return Slidable(
                    key: ValueKey(user["username"]),
                    startActionPane: user["role"] != 'admin'
                        ? ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) =>
                                    _showAddUserSheet(user: user),
                                backgroundColor: Colors.blue,
                                icon: Icons.edit,
                                label: 'Modifier',
                              ),
                            ],
                          )
                        : null,
                    endActionPane: user["role"] != 'admin'
                        ? ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) =>
                                    _deleteUser(user['_id']),
                                backgroundColor: Colors.red,
                                icon: Icons.delete,
                                label: 'Supprimer',
                              ),
                            ],
                          )
                        : null,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ListTile(
                              leading: Icon(Icons.person),
                              title: Text(user["username"]),
                              subtitle: Text(
                                  "Rôle: ${user["role"]} - Email: ${user["email"]}\n"
                                  "Serres: ${user["role"] != "admin" ? (user["serres"] != null && user["serres"].isNotEmpty ? user["serres"].map((s) => s["nom"]).join(', ') : 'Aucune') : 'Tous'}"),
                            ),
                            (user["role"] != "admin")
                                ? TextButton.icon(
                                    onPressed: () =>
                                        _showSerreSelectionDialog(user),
                                    icon: const Icon(Icons.add),
                                    label: const Text("Ajouter des serres"),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserSheet(),
        child: Icon(Icons.person_add),
      ),
    );
  }
}
