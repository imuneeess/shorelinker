import 'package:flutter/material.dart';

class DetailsClick extends StatefulWidget{
  final dataitems;
  const DetailsClick({super.key, this.dataitems});
  @override
  State<DetailsClick> createState() => _DetailsClick();
}

class _DetailsClick extends State<DetailsClick>{

  String? color;
  List<Map> images = [
    {
      "image" : "assets/spadrille-removebg-preview.png"
    },
    {
      "image" : "assets/spadrille2-removebg-preview.png"
    },
    {
      "image" : "assets/spadrille3-removebg-preview.png"
    }
  ];

  int selectIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black87,
          size: 30,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 30 , top: 15),
            child: Row(
              children: [
                const Icon(Icons.circle_outlined , color: Colors.orange),
                const SizedBox(width: 10),
                const Text("Gipsy" , style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                )),
                const SizedBox(width: 5),
                const Text("Bee" , style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  color: Colors.orange
                )),
                const SizedBox(width: 100,),
                Container(
                  child: const Icon(Icons.menu),
                )
              ],
            ),
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10),
          child: ListView(
            children: [
                Container(
                  color: Colors.grey[200],
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 300,
                  child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      onPageChanged: (value) {
                        print(value);
                      },
                      itemBuilder: (context, index) {
                          return Column(
                            children: [
                                Expanded(child: Container(
                                  child: Image.asset(widget.dataitems["photos"]),
                                )),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10 , left: 10),
                                      height : 17,
                                      width : 17,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100),
                                          color: Colors.orange
                                      ),
                                    ),
                                    const SizedBox(width: 10,),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      height : 17,
                                      width : 17,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100),
                                          color: Colors.grey[400]
                                      ),
                                    ),
                                    const SizedBox(width: 10,),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      height : 17,
                                      width : 17,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100),
                                          color: Colors.grey[400],
                                      ),
                                    )
                                  ],
                                )
                            ],
                          );
                      },
                  )
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                        //color : Colors.red,
                        margin: const EdgeInsets.only(top: 20),
                        child: const Text("Kinetix KB 231 Sport Shoes" , style: TextStyle(
                          fontSize: 25,
                          fontWeight:FontWeight.bold,
                        ),),
                      ),
                      const SizedBox(height: 6),
                      const Text("Men's shoes" , style: TextStyle(
                        color: Colors.grey,
                        fontSize: 17,
                      )),
                      const SizedBox(height: 10,),
                      Text(widget.dataitems["price"] , style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      )),
                    ],
                  ),
                ),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 80),
                  child: Row(
                    children: [
                      Container(
                       margin: const EdgeInsets.only(bottom: 60),
                        child: const Text("Color : " , style: TextStyle(
                          fontSize: 20,
                        ),),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            RadioListTile(
                              title: const Text("Gray"),
                              value: "Gray",
                              activeColor: Colors.blue,
                              groupValue: color,
                              onChanged: (value) {
                                color = value;
                              },
                            ),
                            RadioListTile(
                              title: const Text("Black"),
                              value: "Gray",
                              activeColor: Colors.blue,
                              groupValue: color,
                              onChanged: (value) {
                                color = value;
                              },
                            ),
                          ],
                        )
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 80),
                  child: MaterialButton(
                    color: Colors.black87,
                    textColor: Colors.white,
                    onPressed: () {

                  },child: const Text("+Add To Card"),),
                )
            ],
          ),
      ),
    );
  }
}
