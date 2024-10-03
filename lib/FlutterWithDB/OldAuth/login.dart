import 'package:courseflutter/FlutterWithDB/Google/AuthSocial.dart';
import 'package:courseflutter/FlutterWithDB/TextFormCustom/StackBorder.dart';
import 'package:courseflutter/FlutterWithDB/TextFormPass/passwordCustom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:courseflutter/FlutterWithDB/Provider/AuthProvider.dart' as custom;

import '../AlertDialog/AlertDialog.dart';

class LoginPage extends StatefulWidget{

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if(googleUser == null) {
      return;
    }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    Navigator.of(context).pushNamedAndRemoveUntil("/register", (route) => false);
  }

  Future signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
    await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    Navigator.of(context).pushNamedAndRemoveUntil("/register", (route) => false);
  }


  bool isLoading = false;
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? const Center(child: CircularProgressIndicator(color: Colors.blue,)) :  Container(
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
              const SizedBox(height: 20,),
              Form(
                key: globalKey,
                child: Column(
                  children: [
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
                    const SizedBox(height: 30),
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
                    const SizedBox(height: 10),
                    Container(
                      alignment: Alignment.topRight,
                        margin: const EdgeInsets.only(right: 10),
                        child: TextButton(
                          onPressed: () async {
                              if(controllerEmail.text == '') {
                                AlertdialogCustom.showErrorDialog(context,AlertType.error, "Erreur", "Aucun email a été saisie.Veuillez réessayez!",
                                    Colors.red, "OK", () => Navigator.of(context).pop());
                              }
                              else{
                                try{
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await FirebaseAuth.instance.sendPasswordResetEmail(email: controllerEmail.text);
                                  setState(() {
                                    isLoading = false;
                                  });
                                  AlertdialogCustom.showErrorDialog(context,AlertType.success, "Email envoyé",
                                      "Un email de réinitialisation de mot de passe a été envoyé a l'email ${controllerEmail.text}",
                                      Colors.green, "OK", () => Navigator.of(context).pop());

                                }on FirebaseAuthException catch (e){
                                  setState(() {
                                    isLoading = false;
                                  });
                                  if (e.code == 'user-not-found') {
                                    AlertdialogCustom.showErrorDialog(context,AlertType.error, "Erreur", "Aucun utilisateur avec cet email ${controllerEmail.text}.Veuillez réessayer!",
                                        Colors.red, "OK",  () => Navigator.of(context).pop());
                                  }
                                }
                              }
                          },
                          child: const Text("Mot de passe oublié ?",style: TextStyle(fontSize: 16,
                              color: Color(0xff635bff))),
                        )
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
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
                    if (globalKey.currentState!.validate()){
                      try {
                        setState(() {
                          isLoading = true;
                        });
                        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: controllerEmail.text,
                          password: controllerPassword.text,
                        );
                        setState(() {
                          isLoading = false;
                        });
                        if(credential.user!.emailVerified){
                          await Provider.of<custom.AuthProvider>(context, listen: false).login(controllerEmail.text, controllerPassword.text);
                          Navigator.of(context).pushNamed("/register");
                        }
                        else{
                          AlertdialogCustom.showErrorDialog(context,AlertType.warning, "Email Vérification",
                              "Nous avons envoyé un lien dans votre compte Gmail pour vérifier votre email. Veuillez consulter le lien",
                              Colors.orange, "OK", () => Navigator.of(context).pop());
                        }

                      }on FirebaseAuthException catch (e) {
                        isLoading = false;
                        setState(() {});
                        if (e.code == 'user-not-found') {
                          AlertdialogCustom.showErrorDialog(context,AlertType.error, "Email Invalide",
                              "L'email que vous avez saisie semble incorrecte.Veuillez réessayez!",
                              Colors.red, "OK", () => Navigator.of(context).pop());
                        } else if (e.code == 'wrong-password') {
                          AlertdialogCustom.showErrorDialog(context, AlertType.error,"Password Invalide",
                              "Le mot de passe que vous avez saisie semble incorrecte.Veuillez réessayez!!",
                              Colors.red, "OK", () => Navigator.of(context).pop());
                        }
                      }}
                    },
                  child: const Text("Connexion", style: TextStyle(fontSize: 17),
                  ) ,
                ),
              ),
            Container(
              child: Column(
                children: [
                  const SizedBox(height: 25,),
                  const Text("Or Login with" , style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff514f4f),
                  )),
                  const SizedBox(height: 15),
                  Container(
                    margin: const EdgeInsets.only(left: 100),
                    child: Row(
                      children: [
                          AuthSocial(
                              image: "assets/iconGoogle-removebg-preview.png",
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                await signInWithGoogle();
                                setState(() {
                                  isLoading = false;
                                });
                              },
                          ),
                          const SizedBox(width: 20,),
                          AuthSocial(image: "assets/face.png", onPressed: () {
                            setState(() {
                              isLoading = true;
                            });
                            signInWithFacebook();
                            setState(() {
                              isLoading = false;
                            });

                          },),
                          const SizedBox(width: 20,),
                          AuthSocial(image: "assets/twiter.png", onPressed: () {  },),
                      ],
                    ),
                  )
                ],
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
                    const Text("Don't have an account ?", style: TextStyle(
                        fontSize: 16,
                        color : Color(0xff514f4f),
                      ),),
                    TextButton(
                        onPressed: () {
                            Navigator.of(context).pushReplacementNamed("/register");
                        },
                        child: const Text("Register" , style: TextStyle(
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