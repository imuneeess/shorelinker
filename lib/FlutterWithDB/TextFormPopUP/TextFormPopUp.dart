import 'package:flutter/material.dart';


class TextFormPopUp extends StatelessWidget{
  final TextEditingController controller ;
  final String hintText;
  final void Function()? onTap;
  final String? Function(String?)? validator;
  const TextFormPopUp({super.key, required this.controller, required this.validator, required this.hintText, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: const EdgeInsets.symmetric(horizontal: 22),
        margin: const EdgeInsets.only(left: 25,right: 15),
        child: TextFormField(
          controller: controller,//controller l'accés au text du textFromField
          validator: validator,
          onTap: onTap,
          cursorColor: Colors.blue,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 12
            ),
            contentPadding: const EdgeInsets.only(left: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                color: Colors.grey[300]!, // Couleur de la bordure initiale
                width: 1.5, // Épaisseur de la bordure initiale
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                color: Colors.grey[300]!, // Couleur de la bordure en cas d'erreur
                width: 1, // Épaisseur de la bordure en cas d'erreur
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(
                color: Color.fromRGBO(24, 143, 212, 0.25), // Couleur rgba(24, 143, 212, 0.25)
                width: 4, // Épaisseur de la bordure focalisée en cas d'erreur
              ),
            ),
          ),
        ));
  }

}