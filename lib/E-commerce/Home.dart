
import 'package:courseflutter/E-commerce/DetailsClick.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget{
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int selectedIndex = 0;
  List<Map> liste = [
    {"icons" : Icons.person , "Title" : "Men"},
    {"icons" : Icons.person_2 , "Title" : "Woman"},
    {"icons" : Icons.wb_sunny_outlined , "Title" : "Electrical"},
    {"icons" : Icons.play_lesson_outlined , "Title" : "Hobbies"},
  ];
  List<Map> photos = [
    {
      "photos" : "assets/Casque-removebg-preview.png" ,
      "Title" : "Logitech G 231" ,
      "subtitle" : "Bluetooth Headphone",
      "price" : "\$359"
    },
    {
      "photos" : "assets/spadrille-removebg-preview.png" ,
      "Title" : "Spadrille Sport" ,
      "subtitle" : "Chaussure sportif 36",
      "price" : "\$899"
    },
  ];

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          onTap: (value) {
            selectedIndex = value;
          },
          iconSize: 35,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.black45,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: "*",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "*"),
            BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined), label: "*"),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: ListView(
            children: [
               Row(
                 children: [
                    Expanded(child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: const TextStyle(
                          height: 2
                        ),
                        border: InputBorder.none,
                        fillColor: Colors.grey[200],
                        filled: true,
                        prefixIcon: Container(
                          padding: const EdgeInsets.only(left: 18 , right: 10),
                          margin: const EdgeInsets.only(top: 0),
                          child: const Icon(Icons.search , size: 33.0),
                        )
                      ),
                    )
                    ),
                    const SizedBox(width: 20),
                    const Icon(Icons.menu , size: 40.0),
                 ],
               ),
              Container(
                margin: const EdgeInsets.only(top: 35),
                child: const Text("Categories" , style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 2
                ),),
              ),
              const SizedBox(height: 20,),
              SizedBox(
                width: 500,
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 20),
                          child: Column(
                            children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration : BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(150)
                                  ) ,
                                  child: Icon(liste[index]["icons"] , size: 40),
                                ),
                                Text(liste[index]["Title"] , style : const TextStyle(
                                color: Colors.black87
                              )),
                            ],
                          ),
                        );
                    },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 35),
                child: const Text("Best Selling" , style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 2
                ),),
              ),
              const SizedBox(height: 30,),
              SizedBox(
                //color: Colors.red,
                height: 650,
                child: GridView.builder(
                  shrinkWrap: true,physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisExtent: 350
                      ),
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailsClick(dataitems: photos[index])));
                            },
                            child: SizedBox(
                              height: 350,
                              //color: Colors.yellow,
                              child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      height: 250,
                                      width: 300,
                                      color: Colors.grey[200],
                                      child: Image.asset(photos[index]["photos"]),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(right: 30 , top: 15),
                                        child: Text(photos[index]["Title"] , style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold
                                        ),)
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(right: 30),
                                        child: Text(photos[index]["subtitle"], style: TextStyle(
                                          color: Colors.grey[500]
                                        ),),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(right: 120),
                                        child: Text(photos[index]["price"] ,
                                          style: TextStyle(
                                              color: Colors.orange[300],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                          ),),

                                    ),
                                  ],
                              ),
                            ),
                          );
                      },
                  ),
                ),
            ],
          ),
        ),
      );
  }

}