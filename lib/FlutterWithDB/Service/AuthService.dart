import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl;

  AuthService({required this.baseUrl});
  Future<Map<String, dynamic>> register(String email, String password) async {
    final url = Uri.parse('$baseUrl/users/register');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'Email': email,
        'Password': password,
      }),
    );

    if (response.statusCode == 200) {
      print("Succes : ${response.body}");
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      print("Error: ${response.body}");
      throw Exception('User already exists');
    } else {
      print("Error: ${response.body}");
      throw Exception('Failed to register user');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/users/login');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'Email': email,
        'Password': password,
      }),
    );

    if (response.statusCode == 200) {
      print("Succes : ${response.body}");
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      print("Error: ${response.body}");
      throw Exception('Email Invalide!');
    } else if (response.statusCode == 401) {
      print("Error: ${response.body}");
      throw Exception('Password invalid!');
    } else {
      print("Error: ${response.body}");
      throw Exception('Failed to login ');
    }
  }
}