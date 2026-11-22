import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/etudiant.dart';

class EtudiantService {
  static const String baseUrl = 'http://localhost/api-test/public';

  Future<List<Etudiant>> getEtudiants() async {
    final response = await http.get(Uri.parse('$baseUrl/etudiants'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List data = decoded is List ? decoded : (decoded['data'] ?? []);
      return data.map((item) => Etudiant.fromJson(item)).toList();
    } else {
      throw Exception('Erreur chargement étudiants (${response.statusCode})');
    }
  }

  Future<void> createEtudiant({
    required String nom,
    required String postnom,
    required String prenom,
    required String adresse,
    required String telephone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/etudiants'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nom': nom,
        'postnom': postnom,
        'prenom': prenom,
        'adresse': adresse,
        'telephone': telephone,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Erreur ajout étudiant (${response.statusCode}) : ${response.body}',
      );
    }
  }

  Future<void> updateEtudiant({
    required int id,
    required String nom,
    required String postnom,
    required String prenom,
    required String adresse,
    required String telephone,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/etudiants/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nom': nom,
        'postnom': postnom,
        'prenom': prenom,
        'adresse': adresse,
        'telephone': telephone,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Erreur modification étudiant (${response.statusCode}) : ${response.body}',
      );
    }
  }

  Future<void> deleteEtudiant(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/etudiants/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Erreur suppression étudiant (${response.statusCode}) : ${response.body}',
      );
    }
  }

  Future login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    final data = decoded is Map ? decoded : {};

    final isSuccess =
        (response.statusCode == 200 || response.statusCode == 201) &&
            (data['success'] == null || data['success'] == true);

    if (isSuccess) {
      return {
        'success': true,
        'message': data['message']?.toString() ?? 'Connexion réussie',
        'data': data,
      };
    }

    return {
      'success': false,
      'message': data['message']?.toString() ??
          'Échec de la connexion (${response.statusCode})',
    };
  }
}