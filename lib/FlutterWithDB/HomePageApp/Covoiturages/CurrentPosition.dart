import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CurrentPositionService {


  Future<void> getCurrentPosition({
    required BuildContext context,
    required Function(LatLng position, List<Marker> markers) onPositionChanged,
    required GoogleMapController? googleMapController,
  }) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez activer votre localisation actuelle")),
      );
      return;
    }

    // Vérifier les permissions de localisation
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission refusée")),
        );
        return;
      }
    }

    // Obtenir la position actuelle
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng currentPosition = LatLng(position.latitude, position.longitude);

    // Créer un marqueur pour la position actuelle
    List<Marker> markers = [
      Marker(
        markerId: const MarkerId("current_location"),
        position: currentPosition,
        infoWindow: const InfoWindow(title: "Votre position actuelle"),
      ),
    ];

    // Appeler le callback pour mettre à jour l'état de la position et des marqueurs
    onPositionChanged(currentPosition, markers);

    // Animation fluide vers la position actuelle avec un zoom plus élevé
    CameraPosition cameraPosition = CameraPosition(
      target: currentPosition,
      zoom: 16, // Ajustez le niveau de zoom ici
    );

    googleMapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }
}
