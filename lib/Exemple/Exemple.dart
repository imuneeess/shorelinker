import 'package:flutter/material.dart';

void main() {
  runApp(Exemple());
}
class Exemple extends StatelessWidget  {
  List joueurs = [
    {"name" : "Hamza", "lastName" : "Es-sahly" , "age" : 20 , "pays" : "fes"},
    {"name" : "Issam", "lastName" : "Es-sahly" , "age" : 25 , "pays" : "fes"},
    {"name" : "Douae", "lastName" : "Es-sahly" , "age" : 11 , "pays" : "fes"},
    {"name" : "Amina", "lastName" : "Es-sahly" , "age" : 11 , "pays" : "fes"},
    {"name" : "Halim", "lastName" : "Es-sahly" , "age" : 11 , "pays" : "fes"},
    {"name" : "Youssef", "lastName" : "Es-sahly" , "age" : 11 , "pays" : "fes"}
  ];

  Exemple({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text("Title" , style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22
            )) , backgroundColor: Colors.blue),
            body: Container(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 200
                ),
                itemCount: joueurs.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.green,
                    alignment: Alignment.topCenter,
                    child: Text(joueurs[index]["name"] , style: const TextStyle(color: Colors.white
                    )),
                  );
                },
              ),
            )
        ));
  }
}
