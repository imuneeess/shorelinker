import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookService {

  Future signInWithFacebook(BuildContext context) async {
    // Trigger the sign-in flow
    try{
      final LoginResult loginResult = await FacebookAuth.instance.login();
      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential = FacebookAuthProvider
          .credential(loginResult.accessToken!.tokenString);

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
      print("Connexion réussie avec Facebook !");
      Navigator.of(context).pushNamedAndRemoveUntil("/register", (route) => false);
    }catch(e){
      print("Error during facebook sign-in: $e");
      rethrow;
    }
  }
}
