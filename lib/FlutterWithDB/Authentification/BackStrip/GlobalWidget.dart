
import 'package:flutter/material.dart';

class GlobalWidget extends StatelessWidget {
  final String ImageCustom ;
  final Widget widget;
  const GlobalWidget({super.key, required this.ImageCustom, required this.widget});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            alignment: Alignment.topCenter,
            image: AssetImage(ImageCustom),
          ),
        ),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget,
          ],
        ) ,
      ),
    );
  }
}