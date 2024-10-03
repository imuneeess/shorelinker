import 'package:flutter/material.dart';

class PasswordCustom extends StatefulWidget {
  final String textPass;
  final TextEditingController controller;
  final void Function()? onTap;
  final String? Function(String?)? validator;

  const PasswordCustom({super.key, required this.controller, this.validator, required this.textPass, required this.onTap}) ;

  @override
  State<PasswordCustom> createState() => _PasswordCustomState();
}

class _PasswordCustomState extends State<PasswordCustom> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 15),
      child: TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        onTap: widget.onTap,
        cursorColor: Colors.blue,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: widget.textPass,
          hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 12
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.grey[400],
            ),
            onPressed: () {
              setState(() {
                obscureText = !obscureText;
              });
            },
          ),
          contentPadding: const EdgeInsets.only(left: 17),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromRGBO(24, 143, 212, 0.25),
              width: 4,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color.fromRGBO(24, 143, 212, 0.25),
              width: 4,
            ),
          ),
        ),
      ),
    );
  }
}
