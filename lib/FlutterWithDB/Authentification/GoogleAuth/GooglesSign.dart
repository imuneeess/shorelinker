import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final storage = const FlutterSecureStorage();
  final String backendUrl = 'http://192.168.1.105:3000/users/registerGoogle';
  String? profileImageUrl; // Propriété pour stocker l'URL de l'image de profil

  Future<void> signInWithGoogle(BuildContext context) async {
    String? email; // Pour stocker l'email
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return;
      }
      email = googleUser.email; // Stocke l'email
      profileImageUrl = googleUser.photoUrl; // Récupère et stocke l'URL de l'image de profil

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      //await registerUserInDatabase(context, googleUser.email);
    } on UserAlreadyExistsException catch (_) {
      print("User already exists, continuing...");
    } catch (e) {
      print("Error during Google sign-in: $e");
      rethrow;
    } finally {
      if (email != null) {
        await storeEmail(context, email); // Stocke l'email et l'URL de l'image
        Navigator.of(context).pushNamedAndRemoveUntil("/homepage", (route) => false);
      }
      else{
        Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
      }

    }
  }

  Future<void> storeEmail(BuildContext context, String email) async {
    await storage.write(key: 'googleEmail', value: email);
    if (profileImageUrl != null) {
      await storage.write(key: 'userProfileImageUrl', value: profileImageUrl!);
    }
    print("Email stored: $email");
    if (profileImageUrl != null) {
      print("Profile image URL stored: $profileImageUrl");
    }
  }

  Future<void> registerUserInDatabase(BuildContext context, String email) async {
    final response = await http.post(
      Uri.parse(backendUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'Email': email}),
    );
    if (response.statusCode == 200) {
      print("Success: ${response.body}");
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      print("Error: ${response.body}");
      throw UserAlreadyExistsException();
    } else {
      print("Error: ${response.body}");
      throw Exception('Failed to login');
    }
  }
}

class UserAlreadyExistsException implements Exception {}
