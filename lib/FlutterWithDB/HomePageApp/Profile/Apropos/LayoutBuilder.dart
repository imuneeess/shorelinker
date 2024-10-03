import 'package:flutter/material.dart';

class UserResumeLayout extends StatelessWidget {
  final String resumeText;
  final bool isExpanded;
  final int maxLines;
  final VoidCallback onToggle;

  const UserResumeLayout({super.key, 
    required this.resumeText,
    required this.isExpanded,
    required this.maxLines,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: resumeText,
            style: const TextStyle(
              fontFamily: "assets/Roboto-Regular.ttf",
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflow = textPainter.didExceedMaxLines;

        return Container(
          margin: const EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: Text(
                  resumeText,
                  maxLines: isExpanded ? null : maxLines,
                  overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "assets/Roboto-Regular.ttf",
                    fontSize: 13.5,
                    color: Colors.grey[900],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (isOverflow || isExpanded)
                InkWell(
                  onTap: onToggle,
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: Text(
                      isExpanded ? "Voir moins" : "Voir plus",
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 12
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
