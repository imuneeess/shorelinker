import 'package:flutter/material.dart';

class InitialState extends StatefulWidget{

  const InitialState({super.key});


  @override
  State<InitialState> createState() => _InitialState();
}

class _InitialState extends State<InitialState>{
  @override
  void initState() {
    print("Hy I'm Clicked here");
    super.initState();
  }
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
          child: const Text("Hello woeld!!"),
         ),
    );
  }

}
