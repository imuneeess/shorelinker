import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/Apropos/TextFormApropos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../NavigationBotton/HomeBouttomsSheets.dart';

class Apropos extends StatefulWidget {
  final String docid;
  const Apropos({super.key, required this.docid});

  @override
  State<Apropos> createState() => _FloatAction();

}
class _FloatAction extends State<Apropos> {
  TextEditingController controllerResumer = TextEditingController();
  CollectionReference profiles = FirebaseFirestore.instance.collection('profiles');
  GlobalKey<FormState> globalKey = GlobalKey();
  bool isLoading = false;
  bool user = false; // Indique si l'utilisateur est nouveau ou existant
  Map<String, dynamic>? userData;

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
        if(userData!['Résumé'] == null){
          print('Pret pour ajouter le nouveau champs de user Auth!!');
        }
        else{
          controllerResumer.text = userData!['Résumé'];
        }
      } else {
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
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      await Future.delayed(const Duration(seconds: 2)); // Optionnel : délai pour simulation de chargement
      await profiles.doc(widget.docid).update({
        "Résumé": controllerResumer.text,
      });
      print("Résumé updated for existing user");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeBottomSheets(initialPage: 'profile'),
        ),
      );
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
      print("Failed to save/update résumé: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la mise à jour du résumé. Veuillez réessayer.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  void initState() {
    _checkAndLoadProfileData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Modifier la section ..." , style: TextStyle(
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
                            child: const Text("Veuillez remplir le formulaire qui fait référence a propos de vous!" ,
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
                    TextFormApropos(controller: controllerResumer, validator: (value) {
                      if(value!.isEmpty){
                        return "Saisissez votre résumé";
                      }
                      return null;
                    }, hintText: 'Résumé',),
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