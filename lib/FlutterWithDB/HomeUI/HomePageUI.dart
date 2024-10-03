import 'package:carousel_slider/carousel_slider.dart';
import 'package:courseflutter/FlutterWithDB/HomeUI/GlobalWidgetFooter.dart';
import 'package:courseflutter/FlutterWithDB/HomeUI/GlobalWidgetHomeUI.dart';
import 'package:flutter/material.dart';

/*void main() {
  runApp(MyApp());
}*/

/*class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePageUI(),
    );
  }
}*/

class HomePageUI extends StatefulWidget {
  const HomePageUI({super.key});

  @override
  _HomePageUIState createState() => _HomePageUIState();
}

class _HomePageUIState extends State<HomePageUI> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffEEEBDE),
        body: isLoading ? const Center(child: CircularProgressIndicator(color: Colors.blue)) : Container(
          child: ListView(
            children: [
              GlobalWidgetHomeUI(
                  imageCustom: "assets/home-banner.jpg",
                  widget: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: Image.asset("assets/images8.png", height: 70),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 20),
                                  child: InkWell(
                                    onTap: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await Future.delayed(const Duration(seconds: 2));
                                      Navigator.of(context).pushNamed('/register');
                                      setState(() {
                                        isLoading = false;
                                      });
                                    },
                                    child: const Text("S'inscrire" , style: TextStyle(fontSize: 13.5 , color: Colors.white),),
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.all(7),
                                  child: InkWell(
                                    onTap: () async{
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await Future.delayed(const Duration(seconds: 2));
                                      Navigator.of(context).pushNamed('/login');
                                      setState(() {
                                        isLoading = false;
                                      });
                                    },
                                    child: Container(
                                      child: Text(
                                        "S'identifier",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "assets/Roboto-Regular.ttf",
                                          fontSize: 13.5,
                                          color: Colors.blue[500]
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10, top: 35),
                        child: const Text(
                          "Fès-Shore, un futur parc pour créer de nouveaux potentiels en domaine d'informatiques",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w300,
                            fontFamily: "assets/Roboto-Regular.ttf",
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15, top: 10),
                            child: const Text(
                              "Découvrez notre application XPERIS app en cliquant sur S'identifier",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w300,
                                fontFamily: "assets/Roboto-Regular.ttf",
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 45, top: 120, right: 15),
                        child: const Text(
                          "Des Prestations Haut de gamme disponibles" ,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 30,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Roboto",
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 25, top: 10, right: 5),
                        child: const Text(
                          "Nombreuses services disponibles (un système de covoiturage, la gestion des nouvelles annonces fès-shore, Discussion intrasite...)",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Roboto",
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 130,
                              child: InkWell(
                                onTap: () {
                                  // une redirection
                                },
                                child: MaterialButton(
                                  shape: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide.none
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  color: const Color(0xff635bff),
                                  textColor: Colors.white,
                                  onPressed: () {
                                    Navigator.of(context).pushNamed("/register");
                                  },
                                  child: const Text(
                                    "Commencer",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "assets/Roboto-Regular.ttf",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 250,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 2),
                          autoPlayAnimationDuration: const Duration(milliseconds: 800),
                          enlargeCenterPage: true,
                          viewportFraction: 0.6,
                          pageSnapping: true,
                          enableInfiniteScroll: true, // Assure un défilement infini si besoin
                        ),
                        items: [
                          'assets/Fes ShoreDernier.jpg',
                          'assets/fes-shore-2.jpg',
                          'assets/CGI.jpg',
                          'assets/alten2.jpg',
                          'assets/Fes-shoreFinale.jpg',
                          'assets/Fes-shore10.png',
                        ].map((item) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              item,
                              fit: BoxFit.fill,
                              width: MediaQuery.of(context).size.width, // Ajuste la largeur à la taille de l'écran
                              height: 250, // Ajuste la hauteur pour maintenir les proportions
                              filterQuality: FilterQuality.high, // Améliore la qualité du filtre
                            ),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        child: Image.asset("assets/images8.png",height: 100),
                      ),
                      const SizedBox(height: 30),
                      GlobalWidgetFooter(
                          imageCustom: 'assets/Fes ShoreDernier.jpg',
                          widget: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 120),
                                    padding: const EdgeInsets.only(top: 30, left: 20,right: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5)
                                    ),
                                    height: 250,
                                    width: 320,
                                    child: Column(
                                      children: [
                                        const Text("Fés shore est le premier parc Tier2 de MEDZ, "
                                            "Fés Shore bénéficie d’un emplacement stratégique, "
                                            "d’un large pool universitaire et de coûts "
                                            "de structure grandement compétitifs",style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                          fontFamily: "assets/Roboto-Regular.ttf",
                                        ),),
                                        const SizedBox(height: 20),
                                        /*Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                child: Image.asset('assets/webhelp.png',height: 50,width: 50,),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                child: Image.asset('assets/atos.png',height: 50,width: 50,),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                child: Image.asset('assets/axa.png',height: 50,width: 50,),
                                              ),
                                            )
                                          ],
                                        )*/
                                        CarouselSlider(
                                          options: CarouselOptions(
                                            height: 70,
                                            autoPlay: true,
                                            autoPlayInterval: const Duration(seconds: 2),
                                            autoPlayAnimationDuration: const Duration(milliseconds: 800),
                                            enlargeCenterPage: true,
                                            viewportFraction: 0.35,
                                            pageSnapping: true,
                                            enableInfiniteScroll: true, // Assure un défilement infini si besoin
                                          ),
                                          items: [
                                            'assets/CGI-logo.png',
                                            'assets/Alten-logo.png',
                                            'assets/intelcia.png',
                                            'assets/GFI.png',
                                            'assets/axa.png',
                                            'assets/atos.png',
                                            'assets/actical.png'
                                          ].map((item) => Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 2),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.asset(
                                                item,
                                                fit: BoxFit.fill,
                                                width: 70, // Ajuste la largeur à la taille de l'écran
                                                height: 70, // Ajuste la hauteur pour maintenir les proportions
                                                filterQuality: FilterQuality.high, // Améliore la qualité du filtre
                                              ),
                                            ),
                                          )).toList(),
                                        ),
                                      ],
                                    )
                                  ),
                                ],
                              )
                            ],
                          )
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 45, top: 80, right: 5),
                        child: const Text(
                          'Des infrastructures et services de qualités',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 30,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Roboto",
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 25, top: 10, right: 5),
                        child: const Text(
                          "Nombreuses commodités et service d'accompagnement (sécurité, restauration, parking, support au recrutement...)",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Roboto",
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                      GlobalWidgetFooter(
                          imageCustom: 'assets/Fes-shoreFinale.jpg',
                          widget: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 50),
                                      child: const Text("Fes Shore\nen chiffres",style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 22,
                                        fontFamily: "assets/Roboto-Regular.ttf",
                                      ),),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15 ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      Column(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(right: 70),
                                            child: const Text("20 ha",style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 30,
                                              fontFamily: "assets/Roboto-Regular.ttf",
                                            ),),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(right: 70),
                                            child: const Text("superficie globale",style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10,
                                              fontFamily: "assets/Roboto-Regular.ttf",
                                            ),),
                                          )
                                        ],
                                      ),
                                      Column(
                                      children: [
                                        Container(
                                          child: const Text("3000",style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 30,
                                            fontFamily: "assets/Roboto-Regular.ttf",
                                          ),),
                                        ),
                                        Container(
                                          child: const Text("M de surface modulables",style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 10,
                                            fontFamily: "assets/Roboto-Regular.ttf",
                                          ),),
                                        )
                                      ],
                                    )
                                  ],
                                )

                              ],
                          )),
                      const SizedBox(height: 30),
                      Container(
                        //color : Color(0xff635bff),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 10,top: 10),
                                height: 70,
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Fes Shore",style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.w500,fontFamily: "assets/Roboto-Regular.ttf",)),
                                    Row(
                                      children: [
                                        const Text("Intérssé par cette application?",style: TextStyle(fontSize: 12 , color: Colors.black)),
                                        const SizedBox(width: 10),
                                        InkWell(onTap: () {
                                          Navigator.of(context).pushNamed("/register");
                                        }, child:const Text("Découvrez-vous",style: TextStyle(fontSize: 12 , color: Color(0xff635bff),fontWeight: FontWeight.bold))),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
              )
            ],
          ),
        )
    );
  }
}


