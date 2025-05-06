import 'dart:convert'; // Bibliothèque pour convertir des objets Dart en JSON.
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Package officiel de Flutter pour envoyer des requêtes HTTP.
import 'package:dio/dio.dart';
// Base URL de ton backend (à remplacer par l'URL réelle de ton serveur).

class ApiService {
  static const String baseUrl = 'http://192.168.1.52:3000/api';
  static const String baseUrlImg = 'http://192.168.1.52:3000/';

  // Fonction pour récupérer le token (à implémenter selon ton stockage)
  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
    // Exemple : récupération depuis SharedPreferences ou SecureStorage
  }

  // Méthode générique pour gérer les requêtes GET.
  static Future<dynamic> getRequest(String endpoint) async {
    try {
      String? token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur GET ($endpoint) : ${response.statusCode}');
      }
    } catch (e) {
      print("Exception GET : $e");
      rethrow;
    }
  }

  // Méthode générique pour gérer les requêtes POST.
  static Future<dynamic> postRequest(String endpoint, data) async {
    try {
      String? token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur POST ($endpoint) : ${response.statusCode}');
      }
    } catch (e) {
      print("Exception POST : $e");
      rethrow;
    }
  }

  static Future<dynamic> postRequestImage(
      String endpoint, FormData data) async {
    try {
      String? token = await _getToken();

      Dio dio = Dio();
      final response = await dio.post(
        '$baseUrl/$endpoint',
        data: data,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.data;
    } catch (e) {
      print("❌ Exception POST avec Dio : $e");
      rethrow;
    }
  }

  // Méthode générique pour gérer les requêtes PUT.
  static Future<dynamic> putRequest(String endpoint, data) async {
    try {
      String? token = await _getToken();

      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur PUT ($endpoint) : ${response.statusCode}');
      }
    } catch (e) {
      print("Exception PUT : $e");
      rethrow;
    }
  }

//
  // Méthode générique pour gérer les requêtes DELETE.
  static Future<dynamic> deleteRequest(String endpoint) async {
    try {
      String? token = await _getToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur DELETE ($endpoint) : ${response.statusCode}');
      }
    } catch (e) {
      print("Exception DELETE : $e");
      rethrow;
    }
  }
}
