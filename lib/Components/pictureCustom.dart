import 'package:flutter/material.dart';

class PictureCustom extends StatelessWidget {

  final String image;
  const PictureCustom({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 70 , left: 160, right: 160),
      padding: const EdgeInsets.all(10),
      height: 90,
      decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(120)
      ),
      child: Image.asset(image),
    );
  }

}