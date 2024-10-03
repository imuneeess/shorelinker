import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/Formation/SecondFomration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PlusFormation extends StatefulWidget {

  const PlusFormation({super.key});

  @override
  State<PlusFormation> createState() => _PlusExperience();
}

class _PlusExperience extends State<PlusFormation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SizedBox(
                  height : 50,
                  width: 50,
                  child: Image.asset("assets/formationback.png",height: 100,),
                ),
              ),
            ],),
          Container(
            margin: const EdgeInsets.only(top: 4),
            child: const Text("Plus de formations ?" , style: TextStyle(
              fontFamily: "assets/Roboto-Regular.ttf",
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),),
          ),
          Container(
            padding: const EdgeInsets.only(left: 20),
            //color: Colors.red,
            child: Text("Ajouter votre diplome et votre école pour obtenir 11 fois "
                "plus de vues sur votre profil. Connectez-vous avec vos", style: TextStyle(
              fontFamily: "assets/Roboto-Regular.ttf",
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),),
          ),
          Container(child: Text( "anciens camarades", style: TextStyle(fontFamily: "assets/Roboto-Regular.ttf",
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
              onPressed: () async{
                Navigator.of(context).push(MaterialPageRoute(builder:
                    (context) => SecondFormation(docid: FirebaseAuth.instance.currentUser!.uid)));
              },child: Text("Ajouter une formation" , style: TextStyle(
                color: Colors.blue[800],
                fontFamily: "assets/Roboto-Regular.ttf",
                fontSize: 15,
                fontWeight: FontWeight.bold
            ),),),
          )
        ],
      ),
    ) ;
  }

}