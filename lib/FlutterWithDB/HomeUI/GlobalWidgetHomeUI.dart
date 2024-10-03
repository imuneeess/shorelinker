import 'package:flutter/material.dart';

class GlobalWidgetHomeUI extends StatelessWidget {
  final String imageCustom;
  final Widget widget;

  const GlobalWidgetHomeUI({
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
            height: 280,
            decoration: BoxDecoration(
              image: DecorationImage(
                alignment: Alignment.topCenter,
                image: AssetImage(imageCustom),
                fit: BoxFit.cover,
                // Assure que l'image couvre l'espace défini
              ),
            ),
          ),
          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.75),
                  const Color.fromRGBO(12, 11, 11, 0.7019607843137254) // Gris neutre et élégant avec une opacité de 70%
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 0.60], // Adjusts the position of the gradient colors
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
