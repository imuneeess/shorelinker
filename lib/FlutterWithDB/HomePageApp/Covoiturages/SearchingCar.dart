import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Covoiturage {
  final String id;
  final String CovoiturageUser;
  final bool request;
  final Timestamp timestamp;
  final String prenom;
  final int places;
  final String vehiculeType;
  final String prix;
  final String quartier;
  final String destination;
  final double distance;
  final GeoPoint position; // Ajout de la position


  Covoiturage({
    required this.id,
    required this.CovoiturageUser,
    required this.request,
    required this.timestamp,
    required this.prenom,
    required this.places,
    required this.vehiculeType,
    required this.prix,
    required this.quartier,
    required this.destination,
    required this.distance,
    required this.position,
  });
}

class CovoiturageService {
  Future<List<Covoiturage>> rechercherCovoituragesProches(LatLng position) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    GeoPoint userPosition = GeoPoint(position.latitude, position.longitude);
    List<Covoiturage> covoituragesTrouves = [];

    try {
      QuerySnapshot profilesSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .get();

      for (var profileDoc in profilesSnapshot.docs) {
        if (profileDoc.id == userId) continue;

        QuerySnapshot covoituragesSnapshot = await profileDoc.reference
            .collection('covoiturages')
            .get();

        for (var covoiturageDoc in covoituragesSnapshot.docs) {
          GeoPoint covoituragePosition = covoiturageDoc['position'];
          String vehiculeType = covoiturageDoc['vehiculeType'];
          print(vehiculeType);
          double distance = Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            covoituragePosition.latitude,
            covoituragePosition.longitude,
          );

          covoituragesTrouves.add(Covoiturage(
            id: covoiturageDoc.id,
            prenom: covoiturageDoc['prenom'],
            places: covoiturageDoc['places'],
            vehiculeType: vehiculeType,
            prix: covoiturageDoc['prix'],
            quartier: covoiturageDoc['quartier'],
            destination: covoiturageDoc['destination'],
            distance: distance,
            position: covoiturageDoc['position'],
            CovoiturageUser: covoiturageDoc['CovoiturageUser'],
            request: covoiturageDoc['request'],
            timestamp: covoiturageDoc['timestamp'],  // Récupération de la position depuis Firestore

          ));
        }
      }

      // Trier les covoiturages par distance croissante
      covoituragesTrouves.sort((a, b) => a.distance.compareTo(b.distance));
    } catch (e) {
      print('Erreur lors de la recherche de covoiturages : $e');
    }

    return covoituragesTrouves;
  }
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
      _currentPosition = LatLng(position.latitude, position.longitude);
      markers.add(Marker(
        markerId: MarkerId("current_location"),
        position: _currentPosition!,
        infoWindow: InfoWindow(title: "Votre position actuelle"),
      ));
      print(_currentPosition);
    });

    // Animation fluide vers la position actuelle avec un zoom plus élevé
    CameraPosition cameraPosition = CameraPosition(
      target: _currentPosition!,
      zoom: 16,  // Ajustez le niveau de zoom ici
    );

    googleMapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }*/

/*Future<void> rechercherCovoituragesProches(LatLng Position) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    GeoPoint userPosition;
    userPosition = GeoPoint(Position.latitude, Position.longitude);
    try {
      QuerySnapshot profilesSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .get();

      List<Covoiturage> covoituragesTrouves = [];

      for (var profileDoc in profilesSnapshot.docs) {
        if (profileDoc.id == userId) continue;

        QuerySnapshot covoituragesSnapshot = await profileDoc.reference
            .collection('covoiturages')
            .get();

        for (var covoiturageDoc in covoituragesSnapshot.docs) {
          GeoPoint covoituragePosition = covoiturageDoc['position'];

          double distance = Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            covoituragePosition.latitude,
            covoituragePosition.longitude,
          );

          covoituragesTrouves.add(Covoiturage(
            id: covoiturageDoc.id,
            prenom: covoiturageDoc['prenom'],
            places: covoiturageDoc['places'],
            vehiculeType: covoiturageDoc['vehiculeType'],
            prix: covoiturageDoc['prix'],
            quartier: covoiturageDoc['quartier'],
            destination: covoiturageDoc['destination'],
            distance: distance,
          ));
        }
      }

      covoituragesTrouves.sort((a, b) => a.distance.compareTo(b.distance));

      setState(() {
        covoituragesProches = covoituragesTrouves;
      });
    } catch (e) {
      print('Erreur lors de la recherche de covoiturages : $e');
    }
  }*/