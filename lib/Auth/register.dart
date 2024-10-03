import 'package:courseflutter/Components/pictureCustom.dart';
import 'package:courseflutter/Components/textFormCustom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../FlutterWithDB/AlertDialog/AlertDialog.dart';
import '../Components/buttomCustom.dart';

class Register extends StatefulWidget{

  const Register({super.key});

  @override
  State<Register> createState() => _RegisterPage();

}

class _RegisterPage extends State<Register> {

  GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerUserName = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? const Center(child: CircularProgressIndicator(color: Colors.blue)) : Container(
        child: ListView(
          children: [
            const PictureCustom(image: "assets/login-removebg-preview.png"),
            const SizedBox(height: 10,),
            Container(
              child: const ListTile(
                title: Text("Register" , style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                ),),
                subtitle: Text("Register to continue using the app" , style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15
                ),),
              ),
            ),
            const SizedBox(height: 20,),
            Form(
              key: globalKey,
              child: Container(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 280),
                      child: const Text("Username", style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                    const SizedBox(height: 15),
                    TextForm(hintedText: "Entrer your username", controller: controllerUserName, validator: (value ) {
                      if(value!.isEmpty) {
                        return 'you must be enter your username';
                      }
                      return null;
                    },),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.only(right: 310),
                      child: const Text("Email", style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                    const SizedBox(height: 15),
                    TextForm(hintedText: "Enter your email", controller: controllerEmail, validator: (value ) {
                        if(value!.isEmpty) {
                        return 'you must be enter your email';
                        }
                        return null;}),
                    Container(
                      margin: const EdgeInsets.only(right: 280, top: 20),
                      child: const Text("Password", style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                    const SizedBox(height: 15),
                    TextForm(hintedText: "Enter your password", controller: controllerPassword, validator: (value) {
                        if(value!.isEmpty) {
                          return 'you must be enter your password';
                        }
                        return null;
                    }),
                    const SizedBox(height: 10),

                  ],
                ),
              ),
            ),
            const SizedBox(height: 5,),
            BouttonCustom(title: "Register", onPressed : () async{
              if(globalKey.currentState!.validate()){
                try {
                  isLoading = true;
                  setState(() {});
                  final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: controllerEmail.text,
                    password: controllerPassword.text,
                  );
                  isLoading = false;
                  setState(() {});
                  FirebaseAuth.instance.currentUser!.sendEmailVerification();
                  Navigator.of(context).pushReplacementNamed("/login");
                } on FirebaseAuthException catch (e) {
                  isLoading = false;
                  setState(() {});
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
              else {
                return;
              }
            }),
            Container(
                margin: const EdgeInsets.only(top: 20, left: 80),
                child: Row(
                  children: [
                    const Text("You have already an account ?"),
                    TextButton(
                        onPressed: () {
                            Navigator.of(context).pushReplacementNamed("/login");
                        },
                        child: const Text("Login",style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15
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