import 'package:flutter/material.dart';

class ListGenerate extends StatefulWidget{

  const ListGenerate({super.key});

  @override
  State<ListGenerate> createState() => _ListGenerate();
}

class _ListGenerate extends State<ListGenerate>{

  List<Map> username =
  [
    {
      "name" : "Hamza",
      "age": 23,
    },
    {
      "name" : "Mohammed",
      "age": 20,
    },
    {
      "name" : "Chadi",
      "age": 15,
    }

  ];

  @override
  Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("ListGenerate" , style: TextStyle(
              color: Colors.white
            )),
            backgroundColor: Colors.blue,
          ),
          body: Container(
            child: ListView(
              children: [
                  ...List.generate(username.length, (index) {
                      return Card(
                          child: ListTile(
                            title: Text(username[index]["name"]),
                          ),
                      );
                  })
              ],
            )

            ),
          );
  }

}
