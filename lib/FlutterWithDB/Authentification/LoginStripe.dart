import 'package:courseflutter/FlutterWithDB/Authentification/FacebookAuth/FacebookSign.dart';
import 'package:courseflutter/FlutterWithDB/Authentification/GoogleAuth/GooglesSign.dart';
import 'package:courseflutter/FlutterWithDB/Authentification/PopupLogin/LoginWithPopup.dart';
import 'package:courseflutter/FlutterWithDB/TextFormPass/passwordCustom.dart';
import 'package:courseflutter/FlutterWithDB/TextFormPopUP/TextFormPopUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../AlertDialog/AlertDialog.dart';
import '../Google/AuthSocial.dart';
import 'BackStrip/GlobalWidget.dart';

class LoginStripe extends StatefulWidget {

  const LoginStripe({super.key});

  @override
  State<LoginStripe> createState() => _LoginStripe();
}

class _LoginStripe extends State<LoginStripe> {

  GoogleAuth googleAuth = GoogleAuth();
  FacebookService facebooService = FacebookService();
  bool isLoading = false;
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  final LoginWithPopup loginWithPopup = LoginWithPopup();  // Créez une instance de la classe
  /*
  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('Email');
    String? savedPassword = prefs.getString('Password');

    if (savedEmail != null) {
      controllerEmail.text = savedEmail;
    }
    if (savedPassword != null) {
      controllerPassword.text = savedPassword;
    }
  }

  */

  void _checkAndShowStoredInfo(BuildContext context, TextEditingController emailController, TextEditingController passwordController) async {
    String? storedEmail = await storage.read(key: 'Email');
    String? storedPassword = await storage.read(key: 'Password');

    if (storedEmail != null && storedPassword != null) {
      bool? result = await loginWithPopup.showStoredInfoDialog(context, emailController, passwordController);
      if (result == false) {
        // Efface les données de stockage sécurisé
        await storage.delete(key: 'Password');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading ? const Center(
          child: CircularProgressIndicator(color: Colors.blue,))
          : GlobalWidget(ImageCustom: "assets/images3.jfif", widget: Expanded(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 45 , top: 30),
                  child: const Text("Fes Shore", style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),),),
                const SizedBox(height: 20),
                Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: 370,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.5),
                                offset: const Offset(1, 2),
                                spreadRadius: 1.5,
                                blurRadius: 25
                            )
                          ]
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 22),
                      child: Form(
                        key: globalKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30),
                              alignment: Alignment.topCenter,
                              child: Text(
                                  "Connectez-vous à votre compte", style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[850],
                                  fontFamily: "assets/Roboto-Regular.ttf"
                              )),
                            ),
                            Container(
                                margin: const EdgeInsets.only(right: 271),
                                child: Text("E-mail", style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[750],
                                    fontFamily: "assets/Roboto-Regular.ttf"
                                )
                                )
                            ),
                            const SizedBox(height: 10),
                            TextFormPopUp(controller: controllerEmail, validator: (value) {
                              if(value!.isEmpty){
                                return "Saisissez votre adresse e-mail";
                              }
                              return null;
                            }, hintText: 'Entrer votre e-mail', onTap: () async {
                              _checkAndShowStoredInfo(context, controllerEmail, controllerPassword);
                            }),
                            const SizedBox(height: 25),
                            Container(
                                margin: const EdgeInsets.only(right: 215),
                                child: Text("Mot de passe",style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[750],
                                    fontFamily: "assets/Roboto-Regular.ttf"
                                ))
                            ),
                            const SizedBox(height: 10),
                            PasswordCustom(controller: controllerPassword, validator: (value) {
                              if(value!.isEmpty){
                                return "Saisissez votre mot de passe";
                              }
                              return null;
                            }, textPass: 'Entrer votre mot de passe', onTap: () async {
                              _checkAndShowStoredInfo(context, controllerEmail, controllerPassword);
                            }),
                            const SizedBox(height: 5),
                            Container(
                                alignment: Alignment.topRight,
                                margin: const EdgeInsets.only(right: 10),
                                child: TextButton(
                                  onPressed: () async {
                                    if (controllerEmail.text == '') {
                                      AlertdialogCustom.showErrorDialog(
                                          context,
                                          AlertType.error,
                                          "Erreur",
                                          "Aucun email a été saisie.Veuillez réessayez !",
                                          Colors.red,
                                          "OK", () => Navigator.of(context).pop());
                                    } else {
                                      try {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        //il cherche si l'email déja existe ou pas on firebase
                                        await FirebaseAuth.instance.sendPasswordResetEmail(email: controllerEmail.text);
                                        setState(() {
                                          isLoading = false;
                                        });
                                        AlertdialogCustom.showErrorDialog(
                                            context,
                                            AlertType.success,
                                            "Email envoyé",
                                            "Un email de réinitialisation de mot de passe a été envoyé a l'email ${controllerEmail.text}",
                                            Colors.green,
                                            "OK", () => Navigator.of(context).pop());
                                      } on FirebaseAuthException catch (e) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        if (e.code == 'user-not-found') {
                                           AlertdialogCustom.showErrorDialog(context,AlertType.error, "Erreur", "Aucun utilisateur avec cet email ${controllerEmail.text}.Veuillez réessayer!",
                                           Colors.red, "OK",  () => Navigator.of(context).pop());
                                        }}
                                    }
                                  }, child: const Text("Mot de passe oublié ?",
                                    style: TextStyle(fontSize: 14,
                                        color: Color(0xff635bff),
                                        fontFamily: "assets/Roboto-Regular.ttf")),
                                )
                            ),
                            const SizedBox(height: 5),
                            Container(
                                width: 350,
                                margin: const EdgeInsets.only(left: 25, right: 15),
                                height: 46,
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
                                          //await Provider.of<custom.AuthProvider>(context, listen: false).login(controllerEmail.text, controllerPassword.text);
                                          Navigator.of(context).pushNamedAndRemoveUntil("/homepage" , (route) => false);
                                        }
                                        else{
                                          AlertdialogCustom.showErrorDialog(context,AlertType.warning, "Email Vérification",
                                              "Nous avons envoyé un lien de vérification du compte a votre e-mail. Veuillez le consulter !",
                                              Colors.orange, "OK", () => Navigator.of(context).pop());
                                        }

                                      }on FirebaseAuthException catch (e) {
                                        isLoading = false;
                                        setState(() {});
                                        if (e.code == 'user-not-found') {
                                          AlertdialogCustom.showErrorDialog(context,AlertType.error, "Email Invalide",
                                              "L'email que vous avez saisie est incorrecte.Veuillez réessayez !",
                                              Colors.red, "OK", () => Navigator.of(context).pop());
                                        } else if (e.code == 'wrong-password') {
                                          AlertdialogCustom.showErrorDialog(context, AlertType.error,"Password Invalide",
                                              "Le mot de passe que vous avez saisie semble incorrecte.Veuillez réessayez !",
                                              Colors.red, "OK", () => Navigator.of(context).pop());
                                        }
                                      }catch(e) {
                                        setState(() {isLoading = false;});
                                        AlertdialogCustom.showErrorDialog(context,AlertType.error, "Erreur",
                                            "l'utilisateur n'existe pas.Veuillez changer de compte !",
                                            Colors.red, "OK" , () => Navigator.of(context).pop());
                                        if (FirebaseAuth.instance.currentUser != null) {
                                          await FirebaseAuth.instance.currentUser!.delete();
                                        }
                                      }
                                    }
                                  },
                                  child: const Text("Connexion", style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: "assets/Roboto-Regular.ttf")),
                                )),
                            Container(margin: const EdgeInsets.only(top: 15, left: 20),
                                child: const Text(
                                  "Ou connectez-vous avec", style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "assets/Roboto-Regular.ttf"),)),
                            /*Container(
                              height: 33,
                              margin: EdgeInsets.only(top: 15 , left: 25 , right: 20),
                              child: Text("Hello"),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: Colors.grey)
                              ),
                            ),*/
                            Container(
                              height: 38,
                              margin: const EdgeInsets.only(left: 45, right: 40 , top: 15),
                              child: MaterialButton(
                                shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: const BorderSide(color: Colors.grey)
                                ),
                                onPressed: () async {
                                try{
                                  setState(() {isLoading = true;});
                                  await googleAuth.signInWithGoogle(context);
                                  setState(() {isLoading = false;});
                                }catch(e) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  AlertdialogCustom.showErrorDialog(context,AlertType.error, "Erreur s'est produite",
                                      "Error lors de la connexion.Veuillez réessayez ! ",
                                      Colors.red, "OK", () => Navigator.of(context).pop());
                                }
                              },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 22),
                                      child: Stack(
                                        children: [
                                          AuthSocial(
                                            image: "assets/iconGoogle-removebg-preview.png",
                                            onPressed: () async {
                                            }),
                                          Container(
                                            margin: const EdgeInsets.only(left: 43, top: 8.5),
                                            child: const Text("Continuer avec Google", style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: "assets/Roboto-Regular.ttf",
                                            )),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.only(left: 25),
                              margin: const EdgeInsets.only(bottom: 4 , left: 4 , right: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(5)
                              ),
                              height: 60,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Vous découvrez Fes Shore ?", style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "assets/Roboto-Regular.ttf",
                                  ),),
                                  TextButton(
                                      onPressed: () async {
                                          setState(() {isLoading = true;});
                                          await Future.delayed(const Duration(seconds: 2));
                                          Navigator.of(context).pushReplacementNamed("/register");
                                          setState(() {isLoading = false;});
                                      },
                                      child: const Text("Register", style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xff635bff),
                                      ),)
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                    ),
                  ),
                ),
                const SizedBox(height: 30,),
                Center(
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(color: Colors.grey.withOpacity(0.3),
                                  offset: const Offset(1, 2),
                                  spreadRadius: 1.5,
                                  blurRadius: 10
                              )
                            ]
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 22),
                        height: 120,
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 70, left: 20),
                              child: const Icon(Icons.lock_outline, size: 17),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                margin: const EdgeInsets.only(bottom: 10),
                                child: const Text(
                                  "Installez uniquement les extensions de navigateur "
                                      "de confiance. Certaines extensions malveillantes"
                                      " peuvent consulter vos mots de passe et compromettre "
                                      "votre sécurité.",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 5,
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        )
                    )
                ),
                const SizedBox(height: 70)
              ],
            ),
          ),),
    );
  }
}