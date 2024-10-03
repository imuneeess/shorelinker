import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCovoiturage extends StatefulWidget {
  const AddCovoiturage({super.key});

  @override
  State<AddCovoiturage> createState() => _AddCovoiturageState();
}

class _AddCovoiturageState extends State<AddCovoiturage> {
  CameraPosition cameraPosition = const CameraPosition(target: LatLng(34.01789928905642, -5.0072285905480385) , zoom: 6);
  List<Marker> markers = [];
  GoogleMapController? googleMapController;
  final _formKey = GlobalKey<FormState>();
  String _prenom = '';
  int _places = 1;
  String _vehiculeType = 'Voiture';
  final bool _request = false;
  String? _prix ;
  LatLng? _currentPosition;
  String _quartier = '';

  Future<void> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez activer votre localisation actuelle"))
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permission refusée"))
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      markers.add(Marker(
        markerId: const MarkerId("current_location"),
        position: _currentPosition!,
        infoWindow: const InfoWindow(title: "Votre position actuelle"),
      ));
      print(_currentPosition);
    });

    // Animation fluide vers la position actuelle avec un zoom plus élevé
    CameraPosition cameraPosition = CameraPosition(
      target: _currentPosition!,
      zoom: 16.0,  // Ajustez le niveau de zoom ici
    );

    googleMapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }
  /*Future<void> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Veuillez activer votre localisation actuelle"))
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Permission refusée"))
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {

      markers.add(Marker(
        markerId: MarkerId("current_location"),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(title: "Votre position actuelle"),
      ));
    });

    // Animation fluide vers la position actuelle avec un zoom plus élevé
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 16.0,  // Ajustez le niveau de zoom ici
    );

    googleMapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }*/


  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Enregistrez les informations dans Firestore
      await FirebaseFirestore.instance.collection('profiles')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("covoiturages")
          .add({
        'prenom': _prenom,
        'places': _places,
        'vehiculeType': _vehiculeType,
        'request': _request,
        'prix': "${_prix!} MAD",
        'timestamp': FieldValue.serverTimestamp(),
        'position': _currentPosition != null
            ? GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude)
            : null,
        'quartier': _quartier,
        'destination': 'Fes Shore',
        'CovoiturageUser': FirebaseAuth.instance.currentUser!.uid,
      });

      // Réinitialisez les champs
      _formKey.currentState!.reset();
      setState(() {
        _currentPosition = null;
        markers.clear(); // Réinitialise également les marqueurs
      });

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
                  'la covoiturage a été ajouté avec succès.',
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
    }
  }

  final List<String> _vehicules = ['Voiture', 'Moto'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 65),
            child: const Text("Ajouter une covoiturage",style: TextStyle(
              fontSize: 15.5,
            ),),
          ),
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: MaterialButton(
              elevation: 0.0,
              shape: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(50)
              ),
              color: Colors.grey[200],
              textColor: Colors.black,
              onPressed: _submitForm,
              child: const Text(
                "Ajouter",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: "assets/Roboto-Regular.ttf",
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        child: ListView(
          children: [
            Stack(
              children: [
                Container(
                    height: 1,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F2EF),
                    )
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Carrousel des véhicules
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 100,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 2),
                            autoPlayAnimationDuration: const Duration(milliseconds: 800),
                            enlargeCenterPage: true,
                            viewportFraction: 0.5,
                            pageSnapping: true,
                            enableInfiniteScroll: true, // Assure un défilement infini si besoin
                          ),
                          items: [
                            'assets/covoiturageCaroussel.png',
                            'assets/Biker2.png',
                            'assets/car1.png',
                            'assets/Biker2.png',
                            'assets/car2.png',
                          ].map((item) => Container(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                item,
                                fit: BoxFit.fill,
                                width: 150, // Ajuste la largeur à la taille de l'écran
                                height: 80, // Ajuste la hauteur pour maintenir les proportions
                                filterQuality: FilterQuality.high, // Améliore la qualité du filtre
                              ),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 35),
                        // Prénom
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: TextFormField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 15),
                              labelText: 'Prénom',
                              labelStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.5
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!, // Couleur de la bordure initiale
                                  width: 1.5, // Épaisseur de la bordure initiale
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(24, 143, 212, 0.25), // Couleur rgba(24, 143, 212, 0.25)
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez saisir votre prénom';
                              }
                              return null;
                            },
                            onSaved: (value) => _prenom = value!,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Nombre de places
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 15),
                              labelText: 'Nombre de places disponibles',
                              labelStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.5
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!, // Couleur de la bordure initiale
                                  width: 1.5, // Épaisseur de la bordure initiale
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(24, 143, 212, 0.25), // Couleur rgba(24, 143, 212, 0.25)
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez saisir le nombre de places disponibles';
                              }
                              return null;
                            },
                            onSaved: (value) => _places = int.parse(value!),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Type de véhicule
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: DropdownButtonFormField<String>(
                            value: _vehiculeType,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 15),
                              labelText: 'Type de véhicule',
                              labelStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.5
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!, // Couleur de la bordure initiale
                                  width: 1.5, // Épaisseur de la bordure initiale
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(24, 143, 212, 0.25), // Couleur rgba(24, 143, 212, 0.25)
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            dropdownColor: Colors.white,
                            items: _vehicules.map((vehicule) {
                              return DropdownMenuItem<String>(
                                value: vehicule,
                                child: Text(
                                  vehicule,
                                  style: const TextStyle(color: Colors.black ,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "assets/Roboto-Regular.ttf",
                                      fontSize: 15), // Couleur du texte de chaque élément
                                ),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _vehiculeType = value!),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Prix
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 15),
                              labelText: 'Prix',
                              labelStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.5
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!, // Couleur de la bordure initiale
                                  width: 1.5, // Épaisseur de la bordure initiale
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(24, 143, 212, 0.25), // Couleur rgba(24, 143, 212, 0.25)
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez saisir le prix de covoiturage';
                              }
                              return null;
                            },
                            onSaved: (value) => _prix = value! ,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Nom du quartier
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: TextFormField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 15),
                              labelText: 'Nom du quartier',
                              labelStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.5
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!, // Couleur de la bordure initiale
                                  width: 1.5, // Épaisseur de la bordure initiale
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(24, 143, 212, 0.25), // Couleur rgba(24, 143, 212, 0.25)
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez saisir votre nom de quartier';
                              }
                              return null;
                            },
                            onSaved: (value) => _quartier = value!,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: const Text("Appuyer sur la boutton de zoom pour accéder a votre localisation actuel (Obligatoire)",style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                ))
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Sélection de la position
                        Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              height: 240,
                              child: Column(
                                children: [
                                  Expanded(child: GoogleMap(initialCameraPosition: cameraPosition ,
                                    onTap: (LatLng latlng) {
                                      _currentPosition = latlng;
                                    },
                                    markers: markers.toSet() ,
                                    mapType: MapType.normal,
                                    onMapCreated: (controller) {
                                      googleMapController = controller;
                                    },
                                  ))
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 95,
                              right: 10,
                              child: FloatingActionButton(
                                elevation: 0,
                                onPressed: _getCurrentPosition,
                                mini: true, // Utilisez la propriété `mini` pour un bouton plus petit
                                shape: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100),
                                    borderSide: BorderSide.none
                                ),
                                backgroundColor: Colors.white,
                                child: const Icon(Icons.my_location, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
