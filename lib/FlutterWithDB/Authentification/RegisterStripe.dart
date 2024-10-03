import 'package:courseflutter/FlutterWithDB/Authentification/PopupRegister/RegisterWithPopup.dart';
import 'package:courseflutter/FlutterWithDB/Authentification/SelectionRegisterImage/SelectionImage.dart';
import 'package:courseflutter/FlutterWithDB/TextFormPass/passwordCustom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:courseflutter/FlutterWithDB/TextFormCustom/StackBorder.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../AlertDialog/AlertDialog.dart';
import 'BackStrip/GlobalWidget.dart';


class RegisterStripe extends StatefulWidget{

  const RegisterStripe({super.key});

  @override
  State<RegisterStripe> createState() => _LoginStripe();
}

class _LoginStripe extends State<RegisterStripe> {

  bool isLoading = false;
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerUserName = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerPays = TextEditingController();
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  RegisterWithPopUp registerWithPopUp = RegisterWithPopUp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading ? const Center(child: CircularProgressIndicator(color: Colors.blue,))
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
                child: Container(width: 370,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), offset: const Offset(1, 2),
                          spreadRadius: 1.5,
                          blurRadius: 25
                      )]
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 22),
                  child: Form(
                    key: globalKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 20 , top: 33),
                          alignment: Alignment.topCenter,
                          child: Text(
                              "Créer votre compte Fes Shore", style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[850],
                              fontFamily: "assets/Roboto-Regular.ttf"
                          )),
                        ),
                        const SizedBox(height: 30),
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
                        TextForm(controller: controllerEmail, validator: (value) {
                          if(value!.isEmpty){
                            return "Saisissez votre adresse e-mail";
                          }
                          return null;
                        }, hintText: 'Entrer votre e-mail',),
                        const SizedBox(height: 25),
                        Container(
                            margin: const EdgeInsets.only(right: 218),
                            child: Text("Nom complet",style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[750],
                                fontFamily: "assets/Roboto-Regular.ttf"
                            ))
                        ),
                        const SizedBox(height: 10),
                        TextForm(controller: controllerUserName, validator: (value) {
                          if(value!.isEmpty){
                            return "Saisissez votre nom complet";
                          }
                          return null;
                        }, hintText: 'Entrer votre nom',),
                        const SizedBox(height: 25),
                        Container(
                            margin: const EdgeInsets.only(right: 277),
                            child: Text("Pays",style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[750],
                                fontFamily: "assets/Roboto-Regular.ttf"
                            ))
                        ),
                        const SizedBox(height: 10),
                        TextForm(controller: controllerPays, validator: (value) {
                          if(value!.isEmpty){
                            return "Saisissez votre pays";
                          }
                          return null;
                        }, hintText: 'Entrer votre pays',),
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
                        }, textPass: 'Entrer votre mot de passe', onTap: () {},),
                        const SizedBox(height: 30,),
                        Container(
                            width: 350,
                            margin: const EdgeInsets.only(left: 28,right: 15),
                            height: 46,
                            child: MaterialButton(
                              shape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide.none,
                              ),
                              color: const Color(0xff635bff),
                              textColor: Colors.white,
                              onPressed: () async {
                                if (globalKey.currentState!.validate()) {
                                  try{
                                    setState(() {isLoading = true;});
                                    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                      email: controllerEmail.text,
                                      password: controllerPassword.text,
                                    );
                                    //await Provider.of<custom.AuthProvider>(context, listen: false).register(controllerEmail.text, controllerPassword.text);
                                    FirebaseAuth.instance.currentUser!.sendEmailVerification();
                                    setState(() {isLoading = false;});
                                    bool? shouldStore = await registerWithPopUp.showSaveCredentialsDialog(context, controllerEmail, controllerPassword);
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (context) => const SelectProfileImagePage()),
                                    );
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
                                          "the account already exists for that email.Try again !",
                                          Colors.orange, "OK", () => Navigator.of(context).pop());
                                    }
                                    else if(e.code == 'invalid-email'){
                                      AlertdialogCustom.showErrorDialog(context,AlertType.error, "Error",
                                          "Bad Format for this email.Try again !",
                                          Colors.red, "OK", () => Navigator.of(context).pop());
                                    }
                                  }
                                  catch(e) {
                                    setState(() {isLoading = false;});
                                    AlertdialogCustom.showErrorDialog(context,AlertType.error, "Erreur",
                                        "l'utilisateur est déja existe.Veuillez changer de compte !",
                                        Colors.red, "OK" , () => Navigator.of(context).pop());
                                    if (FirebaseAuth.instance.currentUser != null) {
                                      await FirebaseAuth.instance.currentUser!.delete();
                                    }
                                  }
                                }
                              },
                              child: const Text("Créer un compte", style: TextStyle(fontSize: 14 , fontFamily: "assets/Roboto-Regular.ttf")),
                            )),
                        const SizedBox(height: 25),
                        Container(
                          margin: const EdgeInsets.only(top: 10,left: 3,right: 3,bottom: 4),
                          padding: const EdgeInsets.only(left: 20),
                          color: Colors.grey[100],
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Vous avez un compte ?", style: TextStyle(
                                fontSize: 14,
                                  fontFamily: "assets/Roboto-Regular.ttf"
                              ),),
                              TextButton(
                                  onPressed: () async {
                                    setState(() {isLoading = true;});
                                    await Future.delayed(const Duration(seconds: 2));
                                    Navigator.of(context).pushReplacementNamed("/login");
                                    setState(() {isLoading = false;});
                                  },
                                  child: const Text("Connectez-vous" , style: TextStyle(
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
            const SizedBox(height: 20),
            Container(child: Row(
              children: [
                Container(
                    margin: const EdgeInsets.only(left: 25),
                    child: Icon(Icons.flag_circle_outlined , color: Colors.grey[400]),
                ),
                const SizedBox(width: 10,),
                Container(
                  child: Text("Fes Shore" , style: TextStyle(fontSize: 13 , color: Colors.grey[500]),),
                )
              ],
            )),
            const SizedBox(height: 30),
          ],
        ),
      ),),
    );
  }
}