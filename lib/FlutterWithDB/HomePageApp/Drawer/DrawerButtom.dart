import 'package:flutter/material.dart';

class DrawerCustom extends StatelessWidget {
  final IconData iconData;
  final String TypeBouton;
  final String? fontFamily;
  final Color color;
  final VoidCallback onPressed;

  const DrawerCustom({
    super.key,
    required this.iconData,
    required this.TypeBouton,
    required this.fontFamily,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 40),
          child: Icon(iconData, color: color),
        ),
        Container(
          margin: const EdgeInsets.only(left: 20),
          child: TextButton(
            onPressed: onPressed,
            child: Text(
              TypeBouton,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: color,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
