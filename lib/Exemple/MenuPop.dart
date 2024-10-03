import 'package:flutter/material.dart';

class MenuPop extends StatefulWidget{
  const MenuPop({super.key});
  @override
  State<MenuPop> createState() => _PopupMenu();
}

class _PopupMenu extends State<MenuPop> {
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("PopupMenuBottom", style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),),
          backgroundColor: Colors.blue,
          actions: [
            PopupMenuButton(
                onSelected: (value) {
                  if (value == "ValueOne"){
                    Navigator.of(context).pushNamed("/one");
                  }
                  else{
                    Navigator.of(context).pushNamed("/two");
                  }
                },
                iconColor: Colors.white,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: "ValueOne", child: Text("One")),
                  const PopupMenuItem(value: "ValueTwo", child: Text("Two"))
                ],
            )
          ],
        ),
      );
  }

}