import 'dart:async';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Covoiturages/CurrentPosition.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'AspectGlobale.dart';
import 'SearchingCar.dart';

class RechercheCovoituragePage extends StatefulWidget {
  const RechercheCovoituragePage({super.key});

  @override
  State<RechercheCovoituragePage> createState() => _CovoituragePageState();
}

class _CovoituragePageState extends State<RechercheCovoituragePage> {
  var covoituragesProches = [];
  bool ontap = false ;
  CameraPosition cameraPosition = const CameraPosition(target: LatLng(34.01789928905642, -5.0072285905480385) , zoom: 13.5);
  GoogleMapController? googleMapController;
  List<Marker> markers = [];
  LatLng? _currentPosition;
  final CurrentPositionService currentPositionService = CurrentPositionService();
  final CovoiturageService covoiturageService = CovoiturageService();
  late CovoiturageMarkerService markerService;

  Future<void> rechercherCovoituragesProches(LatLng position) async {
    List<Covoiturage> covoituragesTrouves =  await covoiturageService.rechercherCovoituragesProches(position);

    List<Marker> newMarkers = await markerService.createCovoiturageMarkers(covoituragesTrouves);

    setState(() {
      covoituragesProches = covoituragesTrouves;
      markers = newMarkers;
    });
  }
  Future<void> _getCurrentPosition() async {
    await currentPositionService.getCurrentPosition(
      context: context,
      googleMapController: googleMapController,
      onPositionChanged: (LatLng position, List<Marker> updatedMarkers) {
        setState(() {
          _currentPosition = position;
          print(_currentPosition);
          markers = updatedMarkers;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    markerService = CovoiturageMarkerService(context);
  }
  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Container(
              height: 800,
              child: Column(
                children: [
                  Expanded(child: GoogleMap(initialCameraPosition: cameraPosition ,
                    onTap: (LatLng latlng) {
                      _currentPosition = latlng;
                    },
                    markers: markers.toSet() ,
                    mapType: MapType.hybrid,
                    onMapCreated: (controller) {
                      googleMapController = controller;
                    },
                  ))
                ],
              ),
            ),
            Positioned(
              bottom: 640,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue)
                ),
                margin: EdgeInsets.only(left: 20),
                width: 370,
                child: Column(
                  children: [
                    Container(
                      child: InkWell(
                        onTap: () {
                          _getCurrentPosition();
                          ontap = true;
                        },
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                Container(child: Icon(Icons.location_on, color: Colors.blue[800],),margin: EdgeInsets.only(left: 20,top: 17),),
                              ],
                              mainAxisAlignment: MainAxisAlignment.start,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 60, top: 10),
                              child: Text('Début de localisation',style: TextStyle(
                                fontSize: 8,
                                color: Colors.blue[800]
                              ),),
                            ),
                            ontap ? Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 60, top: 22),
                                  child: Text('Sélectionner votre position',style: TextStyle(
                                    fontWeight: FontWeight.w600,))),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 20, top: 22),
                                      child: Text('Selected',style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green
                                      ),)),
                                  ],
                                )
                              ],
                            ) :  Container(
                                margin: EdgeInsets.only(left: 60, top: 22),
                                child: Text('Sélectionner votre position',style: TextStyle(
                                  fontWeight: FontWeight.w600,))),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                        height: 1,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F2EF),
                        )
                    ),
                    Container(
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              Container(child: Icon(Icons.flag, color: Colors.blue[800],),margin: EdgeInsets.only(left: 20,top: 17),),
                            ],
                            mainAxisAlignment: MainAxisAlignment.start,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 60, top: 10),
                            child: Text('Destination',style: TextStyle(
                                fontSize: 8,
                                color: Colors.blue[800]
                            ),),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 60, top: 22),
                            child: Text('Fes Shore',style: TextStyle(
                              fontWeight: FontWeight.w600,

                            ),),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 15, right: 15),
                                child: InkWell(
                                  onTap: () async {
                                    if (_currentPosition != null) {
                                      await rechercherCovoituragesProches(_currentPosition!);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Veuillez d'abord sélectionner votre position actuelle."))
                                      );
                                    }
                                  },
                                  child: Icon(Icons.search_rounded , size: 30,),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 300,
              child: Container(
                width: MediaQuery.of(context).size.width, // Assurez-vous que la largeur est définie
                height: 200, // Définissez une hauteur fixe pour le conteneur
                color: Colors.white,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: covoituragesProches.length,
                  itemBuilder: (context, index) {
                    final covoiturage = covoituragesProches[index];
                    return Column(
                      children: [
                        Row(
                          children: [
                            Container(child: Text(covoiturage.prenom)),
                            Container(child: Text('${covoiturage.distance.toStringAsFixed(2)} mètres'),),
                          ],
                          mainAxisAlignment: MainAxisAlignment.start,
                        )
                      ],

                    );
                  },
                ),
              ),
            )

          ],
        )
    );
  }*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: 800,
            child: Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: cameraPosition,
                    onTap: (LatLng latlng) {
                      _currentPosition = latlng;
                    },
                    markers: markers.toSet(),
                    mapType: MapType.terrain,
                    onMapCreated: (controller) {
                      googleMapController = controller;
                    },
                  ),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 640,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue),
              ),
              margin: const EdgeInsets.only(left: 20),
              width: 370,
              child: Column(
                children: [
                  Container(
                    child: InkWell(
                      onTap: () {
                        _getCurrentPosition();
                        ontap = true;
                      },
                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 20, top: 17),
                                child: Icon(Icons.location_on, color: Colors.blue[800],),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 60, top: 10),
                            child: Text(
                              'Début de localisation',
                              style: TextStyle(fontSize: 8, color: Colors.blue[800]),
                            ),
                          ),
                          ontap
                              ? Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 60, top: 22),
                                child: const Text('Sélectionner votre position', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 20, top: 22),
                                    child: const Text('Selected', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
                                  ),
                                ],
                              )
                            ],
                          )
                              : Container(
                            margin: const EdgeInsets.only(left: 60, top: 22),
                            child: const Text('Sélectionner votre position', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 1,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F2EF),
                    ),
                  ),
                  Container(
                    child: Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 20, top: 17),
                              child: Icon(Icons.flag, color: Colors.blue[800],),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 60, top: 10),
                          child: Text(
                            'Destination',
                            style: TextStyle(fontSize: 8, color: Colors.blue[800]),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 60, top: 22),
                          child: const Text(
                            'Fes Shore',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 15, right: 15),
                              child: InkWell(
                                onTap: () async {
                                  if (_currentPosition != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.white,
                                        content: const Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            ),
                                            SizedBox(width: 15),
                                            Expanded(
                                              child: Text(
                                                'Chargement en cours de covoiturages...',
                                                style: TextStyle(color: Colors.green),
                                              ),
                                            ),
                                          ],
                                        ),
                                        duration: const Duration(seconds: 3),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        elevation: 6,
                                        margin: const EdgeInsets.all(10),
                                      ),
                                    );
                                    await rechercherCovoituragesProches(_currentPosition!);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Veuillez d'abord sélectionner votre position actuelle!"))
                                    );
                                  }
                                },
                                child: const Icon(Icons.search_rounded, size: 30,),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
          /*Positioned(
            bottom: 300,
            child: Container(
              width: MediaQuery.of(context).size.width, // Assurez-vous que la largeur est définie
              height: 200, // Définissez une hauteur fixe pour le conteneur
              color: Colors.white,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: covoituragesProches.length,
                itemBuilder: (context, index) {
                  final covoiturage = covoituragesProches[index];
                  return Column(
                    children: [
                      Row(
                        children: [
                          Container(child: Text(covoiturage.prenom)),
                          Container(child: Text('${covoiturage.distance.toStringAsFixed(2)} mètres'),),
                        ],
                        mainAxisAlignment: MainAxisAlignment.start,
                      )
                    ],
                  );
                },
              ),
            ),
          )*/
        ],
      ),
    );
  }
}
