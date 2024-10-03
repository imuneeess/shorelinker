import 'package:flutter/material.dart';

class Home extends StatefulWidget{
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int selectedIndex = 0;
  List<Widget> liste = [
    const Text("Bonjour Hamza" , style: TextStyle(fontSize: 20 , color: Colors.red)),
    const Text("Bonjour Issam" , style: TextStyle(fontSize: 20 , color: Colors.green),)
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
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(150)
                          ),
                          child: const Icon(Icons.person , color: Colors.black54 , size: 40),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          child: const Text("Men" , style: TextStyle(
                              color: Colors.black54
                          ),),
                        ),
                      ],
                    ),
                  ),
                  //SizedBox(width: 18),
                  Container(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(150)
                          ),
                          child: const Icon(Icons.person_2 , color: Colors.black54 , size: 40),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          child: const Text("Woman" , style: TextStyle(color: Colors.black54)),
                        )
                      ],
                    ),
                  ),
                  //SizedBox(width: 18),
                  Container(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(150)
                          ),
                          child: const Icon(Icons.wb_sunny_outlined , color: Colors.white70 , size: 40),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          child: const Text("Electrical" , style: TextStyle(color: Colors.black54)),
                        )
                      ],
                    ),
                  ),
                  //SizedBox(width: 18),
                  Container(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(150)
                          ),
                          child: const Icon(Icons.play_lesson_outlined , color: Colors.black54 , size: 40),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          child: const Text("Hobbies" , style: TextStyle(color: Colors.black54)),
                        )
                      ],
                    ),
                  ),
                ],
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
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 30),
                height: 350,
                width: 1000,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed("/detail");
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 20),
                            height: 250,
                            width: 170,
                            color: Colors.grey[200],
                            child: Image.asset("assets/Casque-removebg-preview.png"),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 50),
                                  child: const Text("Logitech G 231" , style: TextStyle(
                                    fontSize: 20
                                    , color: Colors.black87
                                    , fontWeight: FontWeight.bold,
                                  )),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(right: 50),
                                  child: const Text("Bluetooth Headphone" , style: TextStyle(
                                      color: Colors.grey
                                  )),
                                ),
                                Container(
                                    margin: const EdgeInsets.only(right: 142),child: const Text('\$359' , style: TextStyle(
                                    color: Colors.orange, fontSize: 20 , fontWeight: FontWeight.bold
                                ),))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () {
                        print("Apple is clicked!!!");
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(30),
                            color: Colors.grey[200],
                            height: 250,
                            width: 176,
                            child: Image.asset("assets/AppleWatsh-removebg-preview.png"),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10,right: 28),
                            child: const Text("Apple Watch S4" , style: TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold
                            ),),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 90),
                            child: Text("Smart Switch" , style: TextStyle(
                                color: Colors.grey[500]
                            ),),
                          ),
                          Container(
                              margin: const EdgeInsets.only(right: 125),
                              child: const Text('\$899' , style: TextStyle(
                                  color: Colors.orange, fontSize: 20 , fontWeight: FontWeight.bold
                              ),))

                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}