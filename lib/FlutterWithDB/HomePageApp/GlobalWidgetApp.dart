import 'package:flutter/material.dart';

class GlobalWidgetApp extends StatelessWidget {
  final String imageCustom;
  final Widget widget;

  const GlobalWidgetApp({
    super.key,
    required this.imageCustom,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                alignment: Alignment.topCenter,
                image: AssetImage(imageCustom),
                fit: BoxFit.fill,
                // Assure que l'image couvre l'espace défini
              ),
            ),
          ),
          Container(
            child: widget,
          ),
        ],
      ),
    );
  }
}
