import 'package:flutter/material.dart';


class TextFormApp extends StatelessWidget{
  final String hintedText;
  final String? Function(String?)? validator;
  final void Function()? onTap;
  const TextFormApp({super.key, required this.hintedText,required this.validator, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        onTap: onTap,
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