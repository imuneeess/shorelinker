import 'package:flutter/material.dart';

class AuthSocial extends StatelessWidget{
  final String image ;
  final void Function()? onPressed;
  const AuthSocial({super.key, required this.image, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      height: 45,
      child: MaterialButton(
        padding: const EdgeInsets.all(10),
        shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide.none
        ),
        onPressed: onPressed,
        child: Image.asset(image),
      ),
    );
  }

}