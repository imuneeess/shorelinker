import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegisterWithPopUp {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<bool?> showSaveCredentialsDialog(BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Enregistrer les informations !",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text("Voulez-vous enregistrer vos informations de connexion ?",
                    style: TextStyle(fontSize: 15)),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email : ", style: TextStyle(fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[400])),
                    Expanded(
                      child: Text(emailController.text,
                          style: TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                              overflow: TextOverflow.ellipsis), maxLines: 2),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text("Password : ", style: TextStyle(fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[400])),
                    Text('*' * passwordController.text.length, style: TextStyle(
                        fontSize: 14, color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false) ;
              },
              child: const Text("Non"),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(context).pop(true); // Fermer la boîte de dialogue
              },
              child: const Text("Oui", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // Affichez le CircularProgressIndicator après la fermeture de la boîte de dialogue
      await _showLoadingDialog(context, emailController, passwordController);
    }
    else{
      await _showLoadingDialogForNo(context);
    }
    return result;
  }

  /*Future<void> storeEmail(String email) async {
    await storage.write(key: 'userEmail', value: email);
  }*/

  Future<void> _showLoadingDialog(BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.blue),
                  const SizedBox(width: 35),
                  Expanded( // Ajoute Expanded ici
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Enregistrement...",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 5),
                        Text("Veuillez patienter pendant l'enregistrement.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );


    // Enregistrer les informations
    await storage.write(key: 'Email', value: emailController.text);
    await storage.write(key: 'Password', value: passwordController.text);
    // Ajouter un délai de 3 secondes
    await Future.delayed(const Duration(seconds: 3));

    // Fermer le CircularProgressIndicator
    Navigator.of(context).pop(); // Ferme le dialog du CircularProgressIndicator
  }
}

Future<void> _showLoadingDialogForNo(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircularProgressIndicator(color: Colors.blue),
              const SizedBox(width: 20,),
              Text("Veuillez patientez...",style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              )),
            ],
          ),
        ),
      );
    },
  );

  // Ajouter un délai de 3 secondes
  await Future.delayed(const Duration(seconds: 3));

  // Fermer le CircularProgressIndicator
  Navigator.of(context).pop(); // Ferme le dialog du CircularProgressIndicator
}
