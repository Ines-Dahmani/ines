import 'package:flutter/material.dart';
import 'package:mobile/screens/ConnexionPage.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image de fond
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/gris.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Contenu par-dessus
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 35),

                // Logo circulaire
                Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Bouton Sign In
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: const Color.fromARGB(
                        255, 167, 228, 186), // ✅ correction ici
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ConnexionPage()),
                    );
                  },
                  child: const Text(
                    'Se connecte',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 10),

                // Lien Create Account
                // TextButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (_) => Signup()),
                //     );
                //   },
                //   child: const Text(
                //     'Create an Account',
                //     style: TextStyle(
                //       color: Color.fromARGB(255, 33, 36, 34),
                //       fontSize: 18,
                //       decoration: TextDecoration.underline,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
