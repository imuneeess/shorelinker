import 'package:flutter/material.dart';


class TextFormAnnonce extends StatelessWidget{
  final String hintText;
  final TextEditingController controllerAnnonce;
  const TextFormAnnonce({super.key,required this.hintText, required this.controllerAnnonce});
  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: const EdgeInsets.symmetric(horizontal: 22),
        margin: const EdgeInsets.only(left: 15,right: 15),
        child: TextFormField(
          controller: controllerAnnonce,
          maxLines: 2,
          cursorColor: Colors.blue,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderSide: BorderSide.none
            ),
            hintText: hintText,
            hintStyle: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 15
            ),
            contentPadding: const EdgeInsets.only(left: 5,top: 5),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color.fromRGBO(24, 143, 212, 0.25), // Couleur rgba(24, 143, 212, 0.25)
                width: 4,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ));
  }

}