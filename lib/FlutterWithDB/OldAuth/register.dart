import 'package:courseflutter/FlutterWithDB/TextFormCustom/StackBorder.dart';
import 'package:courseflutter/FlutterWithDB/TextFormPass/passwordCustom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../AlertDialog/AlertDialog.dart';
import 'package:courseflutter/FlutterWithDB/Provider/AuthProvider.dart' as custom;

class RegisterPage extends StatefulWidget{

  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  bool isLoading = false;
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerUsername = TextEditingController();
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? const Center(child: CircularProgressIndicator(color: Colors.blue,)) : Container(
        margin: const EdgeInsets.only(top: 50),
        child: ListView(
          children: [
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 20),
              child: const Text("Connectez-vous a votre compte", style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xff514f4f),
              ),),
            ),
            const SizedBox(height: 30,),
            Form(
              key: globalKey,
              child: Column(
                children: [
                  Container(
                      margin: const EdgeInsets.only(right: 300),
                      child: const Text("Username",style: TextStyle(fontSize: 16,
                          color: Colors.black87)
                      )
                  ),
                  const SizedBox(height: 10),
                  TextForm(controller: controllerUsername, validator: (value) {
                    if(value!.isEmpty){
                      return "Saisissez votre username";
                    }
                    return null;
                  }, hintText: '',),
                  const SizedBox(height: 25),
                  Container(
                      margin: const EdgeInsets.only(right: 325),
                      child: const Text("E-mail",style: TextStyle(fontSize: 16,
                          color: Colors.black87)
                      )
                  ),
                  const SizedBox(height: 10),
                  TextForm(controller: controllerEmail, validator: (value) {
                    if(value!.isEmpty){
                      return "Saisissez votre adresse e-mail";
                    }
                    return null;
                  }, hintText: '',),
                  const SizedBox(height: 25),
                  Container(
                      margin: const EdgeInsets.only(right: 270),
                      child: const Text("Mot de passe",style: TextStyle(fontSize: 16,
                          color: Colors.black87))
                  ),
                  const SizedBox(height: 10),
                  PasswordCustom(controller: controllerPassword, validator: (value) {
                    if(value!.isEmpty){
                      return "Saisissez votre mot de passe";
                    }
                    return null;
                  }, textPass: '', onTap: () {  },),
                ],
              ),
            ),
            const SizedBox(height: 40,),
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: MaterialButton(
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
                color: const Color(0xff635bff),
                textColor: Colors.white,
                onPressed: () async {
                  if (globalKey.currentState!.validate()) {
                    try {
                      setState(() {
                        isLoading = true;
                      });
                      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: controllerEmail.text,
                        password: controllerPassword.text,
                      );
                      await Provider.of<custom.AuthProvider>(context, listen: false).register(controllerEmail.text, controllerPassword.text);
                      setState(() {
                        isLoading = false;
                      });
                      FirebaseAuth.instance.currentUser!.sendEmailVerification();
                      Navigator.of(context).pushReplacementNamed("/login");
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      if (e.code == 'weak-password') {
                        AlertdialogCustom.showErrorDialog(context,AlertType.warning, "Warning",
                            "The password provided is too weak!",
                            Colors.orange, "OK" , () => Navigator.of(context).pop());
                      } else if (e.code == 'email-already-in-use') {
                        AlertdialogCustom.showErrorDialog(context,AlertType.warning, "Warning",
                            "the account already exists for that email.Try Again!",
                            Colors.orange, "OK", () => Navigator.of(context).pop());
                      }
                      else if(e.code == 'invalid-email'){
                        AlertdialogCustom.showErrorDialog(context,AlertType.error, "Error",
                            "Bad Format for this email.Try again!",
                            Colors.red, "OK", () => Navigator.of(context).pop());
                      }
                    }
                  }
                },
                child: const Text(
                  "Créer un compte",
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              color: Colors.grey[100],
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Vous avez déja un compte", style: TextStyle(
                    fontSize: 16,
                    color : Color(0xff514f4f),
                  ),),
                  TextButton(
                      onPressed: () async {
                        GoogleSignIn signin = GoogleSignIn();
                        signin.disconnect();
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushReplacementNamed("/login");
                      },
                      child: const Text("Connectez-vous" , style: TextStyle(
                        fontSize: 16,
                        color: Color(0xff635bff),
                      ),)
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}