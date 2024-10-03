import 'package:flutter/material.dart';


class TextForm extends StatelessWidget{
  final String hintedText;
  final TextEditingController controller ;
  final String? Function(String?)? validator;
  const TextForm({super.key, required this.hintedText, required this.controller, required this.validator});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        controller: controller,//controller l'accés au text du textFromField
        validator: validator,
        cursorColor: Colors.blue,
        decoration: InputDecoration(
          hintText: hintedText ,
          contentPadding: const EdgeInsets.only(left: 12),
          hintStyle: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w400,
              fontFamily: "assets/Roboto-Regular.ttf"
          ),
          border: const OutlineInputBorder(
              borderSide: BorderSide.none
          ),
          fillColor: Colors.blueGrey[50],
          filled: true,
        ),
      ),
    );
  }

}