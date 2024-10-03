import 'package:courseflutter/FlutterWithDB/AlertDialog/AlertDialog.dart';
import 'package:courseflutter/Components/buttomCustom.dart';
import 'package:courseflutter/Components/pictureCustom.dart';
import 'package:courseflutter/Components/textFormCustom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Login extends StatefulWidget{
  const Login({super.key});
  @override
  State<Login> createState() => _LoginPage();

}

class _LoginPage extends State<Login> {

  Future signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if(googleUser == null) {
      return;
    }
    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
    Navigator.of(context).pushNamedAndRemoveUntil("/homepage", (route) => false);
  }
  bool isLoading = false;
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading ? const Center(child: CircularProgressIndicator(color: Colors.blue))  :
        Container(
          child: ListView(
              children: [
                const PictureCustom(image: "assets/login-removebg-preview.png"),
                const SizedBox(height: 10,),
                Container(
                  child: const ListTile(
                    title: Text("Login" , style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                    ),),
                    subtitle: Text("Login to continue using the app" , style: TextStyle(
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
                            margin: const EdgeInsets.only(right: 300),
                            child: const Text("Email", style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),),
                          ),
                          const SizedBox(height: 15),
                        TextForm(hintedText: "Enter your email", controller: controllerEmail , validator: (value ) {
                          if(value!.isEmpty) {
                          return 'Veuillez saisir un email valide';
                          }
                          return null;}),
                        Container(
                          margin: const EdgeInsets.only(right: 260, top: 20),
                          child: const Text("Password", style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),),
                        ),
                        const SizedBox(height: 15),
                        TextForm(hintedText: "Enter your password", controller: controllerPassword, validator: (value ) {
                          if(value!.isEmpty) {
                          return 'Veuillez saisir un password valide';
                          }
                          return null;}),
                        const SizedBox(height: 10),
                        Container(
                          margin: const EdgeInsets.only(left: 260),
                          child: MaterialButton(
                              onPressed: () async {
                                if (controllerEmail.text == '') {
                                  AlertdialogCustom.showErrorDialog(context,AlertType.error, "Erreur", "Aucun email a été saisie.Veuillez réessayez!",
                                      Colors.red, "OK", () => Navigator.of(context).pop());
                                }
                                else{
                                  try{
                                    isLoading = true;
                                    setState(() {});
                                    await FirebaseAuth.instance.sendPasswordResetEmail(email: controllerEmail.text);
                                    isLoading = false;
                                    setState(() {});
                                    AlertdialogCustom.showErrorDialog(context,AlertType.success, "Email envoyé",
                                        "Un email de réinitialisation de mot de passe a été envoyé a l'email ${controllerEmail.text}",
                                        Colors.green, "OK", () => Navigator.of(context).pop());

                                  }on FirebaseAuthException catch (e){
                                    isLoading = false;
                                    setState(() {});
                                    if (e.code == 'user-not-found') {
                                      AlertdialogCustom.showErrorDialog(context,AlertType.error, "Erreur", "Aucun utilisateur avec cet email ${controllerEmail.text}.Veuillez réessayer!",
                                          Colors.red, "OK",  () => Navigator.of(context).pop());
                                    }
                                  }
                                }
                              },
                              child: const Text("Forgot Password?"),
                          )
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                BouttonCustom(
                  title: "Login",
                  onPressed: () async {
                    if (globalKey.currentState!.validate()) {
                      try {
                        isLoading = true;
                        setState(() {});
                        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: controllerEmail.text,
                          password: controllerPassword.text,
                        );
                        isLoading = false;
                        setState(() {});
                        if(credential.user!.emailVerified){
                          Navigator.of(context).pushNamed("/homepage");
                        }
                        else{
                          AlertdialogCustom.showErrorDialog(context,AlertType.warning, "Email Vérification",
                              "Nous avons envoyé un lien dans votre compte Gmail pour vérifier votre email. Veuillez consulter le lien",
                              Colors.orange, "OK", () => Navigator.of(context).pop());
                        }

                      } on FirebaseAuthException catch (e) {
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
                      }
                    }
                  },
                ),
                Container(
                  child: Column(
                    children: [
                      const SizedBox(height: 20,),
                      const Text("Or Login with" , style: TextStyle(
                        fontSize: 15
                      )),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.only(top: 15),
                        child: MaterialButton(
                            shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(70),
                              borderSide: BorderSide.none
                            ),
                            onPressed: () {
                              signInWithGoogle();
                            },
                            child: Image.asset("assets/iconGoogle-removebg-preview.png"),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 80),
                  child: Row(
                    children: [
                      const Text("Don't have an account ?"),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed("/register");
                          },
                          child: const Text("Register",style: TextStyle(
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
/*
 title: '
 */