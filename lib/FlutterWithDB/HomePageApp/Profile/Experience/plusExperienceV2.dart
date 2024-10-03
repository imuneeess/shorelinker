import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/Experience/thirdExperience.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PlusExperienceV2 extends StatefulWidget {

  const PlusExperienceV2({super.key});

  @override
  State<PlusExperienceV2> createState() => _PlusExperience();
}

class _PlusExperience extends State<PlusExperienceV2> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 180),
                height : 45,
                width: 45,
                child: Image.asset("assets/experience.png"),
              ),
            ],),
          Container(
            margin: const EdgeInsets.only(top : 7),
            child: const Text("Plus d'expérience ?" , style: TextStyle(
              fontFamily: "assets/Roboto-Regular.ttf",
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            padding: const EdgeInsets.only(left: 20),
            //color: Colors.red,
            child: Text("Ajouter vos postes précédents pour trouver de "
                "nouvelles opportunités de cariere ou pour vous ", style: TextStyle(
              fontFamily: "assets/Roboto-Regular.ttf",
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),),
          ),
          Container(child: Text( "connecter a vos anciens "
              "collégues" , style: TextStyle(fontFamily: "assets/Roboto-Regular.ttf",
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500))),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            width: 370,
            child: MaterialButton(
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(
                  color:  Colors.blue,
                ),
              ),
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder:
                    (context) => ThirdExperience(docid: FirebaseAuth.instance.currentUser!.uid)));
              },child: Text("Ajouter une expérience" , style: TextStyle(
                color: Colors.blue[800],
                fontFamily: "assets/Roboto-Regular.ttf",
                fontSize: 15,
                fontWeight: FontWeight.bold
            ),),),
          )
        ],
      ),
    );
  }

}