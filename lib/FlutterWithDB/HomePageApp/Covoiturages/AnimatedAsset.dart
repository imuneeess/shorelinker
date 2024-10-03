import 'package:flutter/material.dart';

class FlipImage extends StatefulWidget {
  final String imagePath;
  final double size;

  const FlipImage({super.key, required this.imagePath, this.size = 120});

  @override
  _FlipCarImageState createState() => _FlipCarImageState();
}

class _FlipCarImageState extends State<FlipImage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true); // Répète l'animation en alternant entre les états 0 et 1
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Ajuste la perspective
            ..rotateY(_animation.value * 3.14159), // Rotation sur l'axe Y
          alignment: Alignment.center,
          child: Image.asset(
            widget.imagePath,
            height: widget.size,
            width: widget.size,
          ),
        );
      },
    );
  }
}