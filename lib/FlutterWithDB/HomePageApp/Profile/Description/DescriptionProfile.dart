import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courseflutter/FlutterWithDB/TextFormCustom/StackBorder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../NavigationBotton/HomeBouttomsSheets.dart';

class DescriptionProfile extends StatefulWidget {
  final String docid;
  const DescriptionProfile({super.key, required this.docid});

  @override
  State<DescriptionProfile> createState() => _FloatAction();

}
class _FloatAction extends State<DescriptionProfile> {
  TextEditingController controllerNomComplet = TextEditingController();
  TextEditingController controllerTitreProfil = TextEditingController();
  TextEditingController controllerFormation = TextEditingController();
  TextEditingController controllerPays = TextEditingController();
  TextEditingController controllerLieuPays = TextEditingController();
  CollectionReference profiles = FirebaseFirestore.instance.collection('profiles');
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  GlobalKey<FormState> globalKey = GlobalKey();
  bool isProfilePageVisible = false ;
  bool isLoading = false;
  bool isGoogleUser = false ;
  String userEmail = '';
  bool isNewUser = false; // Indique si l'utilisateur est nouveau ou existant
  Map<String, dynamic>? userData;


  Future<String?> getEmailUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (user.providerData.any((provider) => provider.providerId == 'google.com')) {
          userEmail = await storage.read(key: 'googleEmail') ?? '';
          setState(() {});
        }
        else {
          userEmail = await storage.read(key: 'Email') ?? '';
          setState(() {});
        }
      }
      return userEmail;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> checkUserType() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (user.providerData.any((provider) => provider.providerId == 'google.com')) {
          setState(() {
            isGoogleUser = true;
          });
        }
        else {
          setState(() {
            isGoogleUser = false;
          });
        }
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<String?> getProfileImageUrl() async {
    if (isGoogleUser) {
      return await storage.read(key: 'userProfileImageUrl');
    } else {
      return await storage.read(key: 'profile_image'); // Image importée depuis la galerie
    }
  }


  Future<void> _checkAndLoadProfileData() async {
    if (!mounted) return; // Vérifiez si le widget est encore monté
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("profiles")
          .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        // Chargement des données pour un utilisateur existant
        controllerNomComplet.text = userData!['NomComplet'] ?? '';
        controllerTitreProfil.text = userData!['TitreProfil'] ?? '';
        controllerFormation.text = userData!['Formation'] ?? '';
        controllerPays.text = userData!['Pays'] ?? '';
        controllerLieuPays.text = userData!['LieuPays'] ?? '';
        isNewUser = false;
        print("Document existe!!!");
      } else {
        isNewUser = true;
        print("L'utilisateur est nouveau!!");
      }
    } catch (error) {
      print("Failed to load profile: $error");
    } finally {
      if (!mounted) return; // Vérifiez si le widget est encore monté
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveProfileData() async {
    if (!mounted) return; // Vérifiez si le widget est encore monté
    setState(() {
      isLoading = true;
    });
    try {
      await Future.delayed(const Duration(seconds: 2)); // Ajoute un délai de 2 secondes

      String? profileImageUrl = await getProfileImageUrl();

      if (isNewUser) {
        await profiles.doc(widget.docid).set({
          "NomComplet": controllerNomComplet.text,
          "TitreProfil": controllerTitreProfil.text,
          "Formation": controllerFormation.text,
          "Pays": controllerPays.text,
          "LieuPays": controllerLieuPays.text,
          "ProfileImage" : profileImageUrl,
          "UserEmail" : await getEmailUser(),
          "id": FirebaseAuth.instance.currentUser!.uid,
        });
        print("Profile added for new user");
      } else {
        await profiles.doc(widget.docid).update({
          "NomComplet": controllerNomComplet.text,
          "TitreProfil": controllerTitreProfil.text,
          "Formation": controllerFormation.text,
          "Pays": controllerPays.text,
          "LieuPays": controllerLieuPays.text,
        });
        print("Profile updated for existing user");
      }
      if (!mounted) return; // Vérifiez si le widget est encore monté
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeBottomSheets(initialPage: 'profile'),
        ),
      );
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          content: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  'Les informations de profil ont été mises à jour avec succès.',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 6,
          margin: const EdgeInsets.all(10),
        ),
      );

    } catch (error) {
      print("Failed to save/update profile: $error");
      if (!mounted) return; // Vérifiez si le widget est encore monté
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la mise à jour du profil. Veuillez réessayer.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }



  @override
  void initState() {
    checkUserType();
    _checkAndLoadProfileData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Modifier l'intro" , style: TextStyle(
          fontSize: 20,
          color: Colors.black,
          fontFamily: "assets/Roboto-Regular.ttf",
        ),),
      ),
      body: Stack(
        children: [
          isLoading ? const Center(child: CircularProgressIndicator(color: Colors.blue)) : Container(
            child: Form(
              key: globalKey,
              child: ListView(
                children: [
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Container(margin: const EdgeInsets.only(bottom: 20 , left: 20),child: Icon(Icons.warning , color: Colors.yellowAccent[700],) ,),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 5 , top: 7),
                          child: const Text("Veuillez remplir le formulaire qui fait référence a votre propre informations !" ,
                          style: TextStyle(
                            fontFamily: "assets/Roboto-Regular.ttf",
                            fontSize: 15,
                            fontWeight: FontWeight.w500
                          )),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                      margin: const EdgeInsets.only(left: 28),
                      child: Text("Nom Complet",style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[750],
                          fontFamily: "assets/Roboto-Regular.ttf"
                      ))
                  ),
                  const SizedBox(height: 5,),
                  TextForm(controller: controllerNomComplet, validator: (value) {
                    if(value!.isEmpty){
                      return "Saisissez votre NomComplet";
                    }
                    return null;
                  }, hintText: 'Entrer votre Nom Complet',),
                  const SizedBox(height: 20) ,
                  Container(
                      margin: const EdgeInsets.only(left: 28),
                      child: Text("Titre du profil",style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[750],
                          fontFamily: "assets/Roboto-Regular.ttf"
                      ))
                  ),
                  const SizedBox(height: 5,),
                  TextForm(controller: controllerTitreProfil, validator: (value) {
                    if(value!.isEmpty){
                      return "Saisissez votre titre de profil";
                    }
                    return null;
                  }, hintText: 'Entrer votre titre de profil',),
                  const SizedBox(height: 20,),
                  Container(
                      margin: const EdgeInsets.only(left: 28),
                      child: Text("Formation",style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[750],
                          fontFamily: "assets/Roboto-Regular.ttf"
                      ))
                  ),
                  const SizedBox(height: 10),
                  TextForm(controller: controllerFormation, validator: (value) {
                    if(value!.isEmpty){
                      return "Saisissez votre formation";
                    }
                    return null;
                  }, hintText: 'Entrer votre formation',),
                  const SizedBox(height: 20) ,
                  Container(
                      margin: const EdgeInsets.only(left: 28),
                      child: Text("Pays",style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[750],
                          fontFamily: "assets/Roboto-Regular.ttf"
                      ))
                  ),
                  const SizedBox(height: 10,),
                  TextForm(controller: controllerPays, validator: (value) {
                    if(value!.isEmpty){
                      return "Saisissez votre Pays";
                    }
                    return null;
                  }, hintText: 'Entrer votre Pays',),
                  const SizedBox(height: 20) ,
                  Container(
                      margin: const EdgeInsets.only(left: 28),
                      child: Text("Lieu",style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[750],
                          fontFamily: "assets/Roboto-Regular.ttf"
                      ))
                  ),
                  const SizedBox(height: 10),
                  TextForm(controller: controllerLieuPays, validator: (value) {
                    if(value!.isEmpty){
                      return "Saisissez votre Lieu";
                    }
                    return null;
                  }, hintText: 'Entrer votre Lieu',),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 50),
                  height: 40,
                  child: MaterialButton(
                    shape: const OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: (){
                      if(globalKey.currentState!.validate()) {
                        _saveProfileData();
                      }
                    },
                    child: const Text("Enregistrer", style: TextStyle(fontSize: 15, fontFamily: "assets/Roboto-Regular.ttf",)) ,
                  ),
                ),
                  const SizedBox(height: 100,)
                ],
              )
            ),
          ),
        ],
      ),

    );
  }

}