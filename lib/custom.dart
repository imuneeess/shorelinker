import 'package:flutter/material.dart';

class CustomWidget extends StatelessWidget{
  final String name;
  final String gmail;
  final String date;
  final String image;
  const CustomWidget({super.key , required this.name , required this.gmail,
    required this.date, required this.image});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
              SizedBox(
                height: 40,
                width: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(image , fit: BoxFit.cover,),
                )
              ),
              Expanded(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text(gmail),
                    trailing: Text(date , style: const TextStyle(
                        fontSize: 14
                    ),),
                  ),
              )

        ]),
      );
  }

}