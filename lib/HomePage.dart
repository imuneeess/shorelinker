import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courseflutter/Components/Card.dart';
import 'package:courseflutter/Components/FloatingButtom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'FlutterWithDB/AlertDialog/AlertDialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<QueryDocumentSnapshot> categories = [];
  bool isLoading = true;

  getData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("categories").where("id" , isEqualTo: FirebaseAuth.instance.currentUser!.uid ).get();
    Future.delayed( const Duration(seconds: 1));
    categories.addAll(querySnapshot.docs);
    isLoading = false;
    setState(() {});
  }
  @override
  void initState() {
    getData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FloatAction() ));
        },
        backgroundColor: Colors.blue,
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none
        ),
        child: const Icon(Icons.add , color: Colors.white),
      ),
      appBar: AppBar(
        title: const Text("Firebase Install", style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        )),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 25),
            child: IconButton(
                color: Colors.white,
                onPressed: () async {
                  GoogleSignIn signin = GoogleSignIn();
                  signin.disconnect();
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
                },
                icon: const Icon(Icons.exit_to_app),
            ),
          )
        ],
      ),
      body: Container(
        child: isLoading == true ? const Center(child: CircularProgressIndicator(color: Colors.blue),) :  GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 180,
            crossAxisSpacing: 5
          ),
          itemCount: categories.length,
          itemBuilder: (BuildContext context, int index) {
              return InkWell(
                  onLongPress: (){
                    AlertdialogCustom.showErrorDialog(context, AlertType.warning,
                        "Delete", "Avez-vous sure de supprimer ce document",
                        Colors.orange, "OK" , () async{
                          await FirebaseFirestore.instance.collection("categories").doc(categories[index].id).delete();
                          Navigator.of(context).pushNamedAndRemoveUntil("/homepage" , (route) => false);
                        });
                    //Navigator.of(context).pushReplacementNamed("/homepage");
                  },
                  child: CardCustom("assets/folder.png",
                      title: "${categories[index]['name']}")
              );
          },
        ),
      )
    );
  }

}

/*
double latitude1 = 34.009056;
  double longitude1 = -4.852347;

  double latitude2 = 33.840408;
  double longitude2 = -5.511967;

  getCurrentLocationApp() async{
    bool serviceEnabled;
    LocationPermission permission;
    //si l'application est déja active la localisation
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        print("denied");
      }
    }
    if(permission == LocationPermission.whileInUse) {
      double distanceInMeters = Geolocator.distanceBetween(latitude1, longitude1, latitude2, longitude2);
      print("la distance entre la ville Fes et Meknes est : ");
      print(distanceInMeters / 1000);
    }
  }

  @override
  void initState() {
    getCurrentLocationApp();
    super.initState();
  }
 */