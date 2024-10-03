import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? country;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text("Buttom" , style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22
            )) , backgroundColor: Colors.blue),
            body: Container(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                  ),
                  const Text("Choose your country" ,
                    style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  RadioListTile(
                    title: const Text("Morocco"),
                    activeColor: Colors.blue,
                    value: "Morocco",
                    groupValue: country,
                    onChanged: (value) {
                      setState(() {
                        country = value;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text("France"),
                    activeColor: Colors.blue,
                    value: "France",
                    groupValue: country,
                    onChanged: (value) {
                      setState(() {
                        country = value;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text("Italie"),
                    activeColor: Colors.blue,
                    value: "Italie",
                    groupValue: country,
                    onChanged: (value) {
                      setState(() {
                        country = value;
                      });
                    },
                  ),
                  Container(
                    child: Text("Your country is $country",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                  ),
                  const Text("Choose your country" ,
                    style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  RadioListTile(
                    title: const Text("Morocco"),
                    activeColor: Colors.blue,
                    value: "Morocco",
                    groupValue: country,
                    onChanged: (value) {
                      setState(() {
                        country = value;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text("France"),
                    activeColor: Colors.blue,
                    value: "France",
                    groupValue: country,
                    onChanged: (value) {
                      setState(() {
                        country = value;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text("Italie"),
                    activeColor: Colors.blue,
                    value: "Italie",
                    groupValue: country,
                    onChanged: (value) {
                      setState(() {
                        country = value;
                      });
                    },
                  ),
                  Container(
                    child: Text("Your country is $country",
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                ],
              ),
            )
        ));
  }

}






/*
class MyApp extends StatelessWidget  {
  MyApp({super.key});
  int i = 1 ;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Buttom" , style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22
        )) , backgroundColor: Colors.blue),
        body: Container(
          padding: EdgeInsets.all(50),
          margin: EdgeInsets.symmetric(horizontal: 120 , vertical: 100),
          child: Column(
            children: [
              IconButton(onPressed: () {
                i++;
                print(i);
              }, icon: Icon(Icons.add)),
              Text("Counter $i"),
              IconButton(onPressed: () {
                i--;
                print(i);
              }, icon: Icon(Icons.remove))
            ],
          ),
        )
      ));
  }
}
*/