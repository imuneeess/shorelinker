import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/Apropos/TextFormApropos.dart';
import 'package:courseflutter/FlutterWithDB/TextFormCustom/StackBorder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../NavigationBotton/HomeBouttomsSheets.dart';

class SecondExperience extends StatefulWidget {
  final String docid;
  const SecondExperience({super.key, required this.docid});

  @override
  State<SecondExperience> createState() => _FloatAction();

}
class _FloatAction extends State<SecondExperience> {
  TextEditingController controllerEntreprise = TextEditingController();
  TextEditingController controllerTitre = TextEditingController();
  TextEditingController controllerAnnee = TextEditingController();
  TextEditingController controllerMois = TextEditingController();
  TextEditingController controllerLieu = TextEditingController();
  TextEditingController controllerDesc = TextEditingController();
  CollectionReference profiles = FirebaseFirestore.instance.collection('profiles');
  GlobalKey<FormState> globalKey = GlobalKey();
  bool isLoading = false;
  bool isNewUser = false;
  Map<String, dynamic>? userData;

  Future<void> _checkAndLoadProfileData() async {
    if (!mounted) return; // Vérifiez si le widget est encore monté
    setState(() {
      isLoading = true;
    });
    try {
      await Future.delayed(const Duration(seconds: 2));
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("profiles")
          .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        if(userData!['SecondEntreprise'] == null){
          print('Pret pour ajouter les nouvelle champs de user Auth!!');
        }
        else{
          controllerEntreprise.text = userData!['SecondEntreprise'];
          controllerTitre.text = userData!['SecondTitre'];
          controllerAnnee.text = userData!['SecondAnnee'];
          controllerMois.text = userData!['SecondMois'];
          controllerLieu.text = userData!['SecondLieu'];
          controllerDesc.text = userData!['SecondDesc'];
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
        'SecondEntreprise' : controllerEntreprise.text,
        'SecondTitre' : controllerTitre.text,
        'SecondAnnee' : controllerAnnee.text,
        'SecondMois' : controllerMois.text,
        'SecondLieu' : controllerLieu.text,
        'SecondDesc' : controllerDesc.text,
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
        title: const Text("Ajouter une expérience" , style: TextStyle(
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
                    const SizedBox(height: 5,),
                    TextForm(controller: controllerEntreprise, validator: (value) {
                      if(value!.isEmpty){
                        return "Saisissez votre Entreprise";
                      }
                      return null;
                    }, hintText: 'Entreprise',),
                    const SizedBox(height: 20) ,
                    Container(
                        margin: const EdgeInsets.only(left: 28),
                        child: Text("Titre",style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[750],
                            fontFamily: "assets/Roboto-Regular.ttf"
                        ))
                    ),
                    const SizedBox(height: 5,),
                    TextForm(controller: controllerTitre, validator: (value) {
                      if(value!.isEmpty){
                        return "Saisissez votre titre de projet";
                      }
                      return null;
                    }, hintText: 'Titre (Entrer trois mot ou 20 caractéres au maximum)',),
                    const SizedBox(height: 20,),
                    Container(
                        margin: const EdgeInsets.only(left: 28),
                        child: Text("De",style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                            fontFamily: "assets/Roboto-Regular.ttf"
                        ))
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextForm(controller: controllerAnnee, validator: (value) {
                            if(value!.isEmpty){
                              return "Saisissez votre année";
                            }
                            return null;
                          }, hintText: 'Année',),
                        ),
                        Expanded(
                          child: TextForm(controller: controllerMois, validator: (value) {
                            if(value!.isEmpty){
                              return "Saisissez votre mois";
                            }
                            return null;
                          }, hintText: 'Mois',),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20) ,
                    Container(
                        margin: const EdgeInsets.only(left: 28),
                        child: Text("A",style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                            fontFamily: "assets/Roboto-Regular.ttf"
                        ))
                    ),
                    TextForm(controller: controllerLieu, validator: (value) {
                      if(value!.isEmpty){
                        return "Saisissez votre Lieu";
                      }
                      return null;
                    }, hintText: 'Lieu (Entrer trois mot ou 20 caractéres au maximum)',),
                    const SizedBox(height: 15),
                    TextFormApropos(controller: controllerDesc , validator: (value) {
                      if(value!.isEmpty){
                        return "Saisissez votre Desciption";
                      }
                      return null;
                    } ,hintText: 'Description (facultatif)'),
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