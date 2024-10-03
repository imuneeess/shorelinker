import 'package:flutter/material.dart';


class SearchTextForm extends StatelessWidget{
  final String hintText;
  final void Function()? onTap ;
  const SearchTextForm({super.key, required this.hintText, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      //margin: const EdgeInsets.symmetric(horizontal: 22),
        margin: const EdgeInsets.only(left: 70),
        child: TextFormField(
          onTap: onTap ,
          cursorColor: Colors.blue,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
                color: Colors.blue,
                fontSize: 16
            ),
            contentPadding: const EdgeInsets.only(left: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.blue, // Couleur de la bordure initiale
                width: 1.5, // Épaisseur de la bordure initiale
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey[300]!, // Couleur de la bordure initiale
                width: 1, // Épaisseur de la bordure initiale
              ),
            ),
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