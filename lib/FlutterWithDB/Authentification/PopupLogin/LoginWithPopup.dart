import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginWithPopup {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<bool?> showStoredInfoDialog(BuildContext context, TextEditingController emailController, TextEditingController passwordController) async {
    String? storedEmail = await storage.read(key: 'Email');
    String? storedPassword = await storage.read(key: 'Password');

    if (storedEmail != null && storedPassword != null) {
      bool? result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: Container(
              margin: const EdgeInsets.only(top: 10),
              child: const Row(
                children: [
                  Center(child: Icon(Icons.info_outline, color: Colors.blue)),
                  SizedBox(width: 10),
                  Text("Informations enregistrées" , style: TextStyle(fontFamily: "assets/Roboto-Regular.ttf" , fontSize: 20,
                      fontWeight: FontWeight.normal , color: Colors.black87),),
                ],
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.blue),
                  title:  Text("Email" , style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[750],
                      fontFamily: "assets/Roboto-Regular.ttf"
                  )),
                  subtitle: Text(storedEmail , style: TextStyle(color: Colors.grey[700]),),
                ),
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.blue),
                  title: Text("Mot de passe" , style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[750],
                      fontFamily: "assets/Roboto-Regular.ttf"
                  )),
                  subtitle: Text('*' * storedPassword.length , style: TextStyle(color: Colors.grey[700]), ), // Masque le mot de passe
                ),
              ],
            ),
            actions: [
              Container(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text("Annuler" , style: TextStyle( fontWeight: FontWeight.w400,
                          color: Colors.grey[700],
                          fontFamily: "assets/Roboto-Regular.ttf"), ),
                    ),
                    const SizedBox(width: 40,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text("Utiliser" , style: TextStyle(
                          color: Colors.white
                      ),),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      );

      if (result == true) {
        emailController.text = storedEmail;
        passwordController.text = storedPassword;
      }
      return result;
    }
    return null;
  }
}
