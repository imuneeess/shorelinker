import 'package:flutter/material.dart';

class BouttonCustom extends StatelessWidget{
  final String title;
  final void Function()? onPressed;
  const BouttonCustom({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: MaterialButton(
        shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none
        ),
        color: Colors.blue,
        textColor: Colors.white,
        onPressed: onPressed,
        child: Text(title, style: const TextStyle(fontSize: 17),
        ) ,
      ),
    );
  }

}