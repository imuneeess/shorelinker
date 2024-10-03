import 'package:flutter/material.dart';

class GlobalWidgetFooter extends StatelessWidget {
  final String imageCustom;
  final Widget widget;

  const GlobalWidgetFooter({
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
            height: 270,
            width: double.infinity,
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
