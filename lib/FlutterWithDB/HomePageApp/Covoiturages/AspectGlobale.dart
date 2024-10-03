import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Covoiturages/AnimatedAsset.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'SearchingCar.dart';

class CovoiturageMarkerService {
  final BuildContext context;

  CovoiturageMarkerService(this.context);

  Future<BitmapDescriptor> _getMarkerIcon(String vehiculeType) async {
    String assetPath;
    if (vehiculeType == "Voiture") {
      assetPath = 'assets/voitureRouge.png'; // chemin vers l'icône de voiture
    } else if (vehiculeType == "Moto") {
      assetPath = 'assets/motoBleu.png'; // chemin vers l'icône de moto
    } else {
      assetPath = 'assets/car2.png'; // icône par défaut
    }

    return await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)), // Taille de l'icône
      assetPath,
    );
  }

  Future<List<Marker>> createCovoiturageMarkers(List<Covoiturage> covoiturages) async {
    List<Marker> markers = [];

    for (var covoiturage in covoiturages) {
      BitmapDescriptor markerIcon = await _getMarkerIcon(covoiturage.vehiculeType);

      Marker marker = Marker(
        markerId: MarkerId(covoiturage.id),
        position: LatLng(covoiturage.position.latitude, covoiturage.position.longitude),
        icon: markerIcon,
        infoWindow: InfoWindow(
          title: covoiturage.prenom,
          snippet: 'Distance: ${covoiturage.distance.toStringAsFixed(2)} mètres',
          onTap: () async {
            await _showCovoiturageDetails(covoiturage.id, covoiturage.CovoiturageUser);
          },
        ),
      );

      markers.add(marker);
    }

    return markers;
  }

  Future<void> _showCovoiturageDetails(String covoiturageId, String userId) async {
    // Récupérer les détails du covoiturage depuis Firestore
    DocumentSnapshot covoiturageDoc = await FirebaseFirestore.instance
        .collection('profiles')
        .doc(userId) // Remplacez par l'ID utilisateur approprié
        .collection('covoiturages')
        .doc(covoiturageId)
        .get();

    if (covoiturageDoc.exists) {
      // Extraire les informations du document
      var data = covoiturageDoc.data() as Map<String, dynamic>;

      GeoPoint position = data['position'];

      Timestamp timestamp = data['timestamp'] ;
      DateTime dateTime = timestamp.toDate();

      // Formater la date et l'heure sans UTC et avec AM/PM
      String formattedDate = DateFormat('dd MMMM yyyy à hh:mm:ss a').format(dateTime);
      // Afficher les détails dans une boîte de dialogue ou une nouvelle page
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.blue[900],
            shape: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.white
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            content: Stack(
              children: [
                data['vehiculeType'] == "Moto" ?
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 20),
                          child: const FlipImage(imagePath: 'assets/Biker2.png',size: 100),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 210,top: 5),
                          child: const Icon(Icons.location_on,color: Colors.white),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 175, top: 35),
                          child: const Text(
                            'Départ localisation :',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 175, top: 50),
                          child: Text(
                            data['quartier'],
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                        Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 120),
                              child: const Text('Prenom : ' , style: TextStyle(
                                color: Colors.grey
                              )),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 120 , left: 72),
                              child: Text(data['prenom'] , style: const TextStyle(
                                  color: Colors.white,
                              )),
                            )
                          ],
                        ),
                        Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 145),
                              child: const Text('Prix : ' , style: TextStyle(
                                  color: Colors.grey
                              )),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 145 , left: 40),
                              child: Text(data['prix'], style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13
                              )),
                            )
                          ],
                        ),
                        Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 170),
                              child: const Text('Nombre de places : ' , style: TextStyle(
                                  color: Colors.grey
                              )),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 170 , left: 140),
                              child: Text('${data['places']}', style: const TextStyle(
                                color: Colors.white,
                              )),
                            )
                          ],
                        ),
                        Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 195),
                              child: const Text("L'horaire : " , style: TextStyle(
                                  color: Colors.grey
                              )),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 195 , left: 75),
                              child: Text(formattedDate, style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5
                              )),
                            )
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 230),
                          height: 150, // Hauteur de la carte, ajustez si nécessaire
                          child: GoogleMap(
                            mapType: MapType.hybrid,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(position.latitude, position.longitude),
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('location'),
                                position: LatLng(position.latitude, position.longitude),
                              ),
                            },
                          ),
                        ),
                      ],
                    ) :
                Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: const FlipImage(imagePath: 'assets/voitureRouge.png'),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 210,top: 5),
                      child: const Icon(Icons.location_on,color: Colors.white),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 175, top: 35),
                      child: const Text(
                        'Départ localisation :',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 175, top: 50),
                      child: Text(
                        data['quartier'],
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 120),
                          child: const Text('Prenom : ' , style: TextStyle(
                              color: Colors.grey
                          )),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 120 , left: 72),
                          child: Text(data['prenom'] , style: const TextStyle(
                            color: Colors.white,
                          )),
                        )
                      ],
                    ),
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 145),
                          child: const Text('Prix : ' , style: TextStyle(
                              color: Colors.grey
                          )),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 145 , left: 40),
                          child: Text(data['prix'], style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13
                          )),
                        )
                      ],
                    ),
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 170),
                          child: const Text('Nombre de places : ' , style: TextStyle(
                              color: Colors.grey
                          )),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 170 , left: 140),
                          child: Text('${data['places']}', style: const TextStyle(
                            color: Colors.white,
                          )),
                        )
                      ],
                    ),
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 195),
                          child: const Text("L'horaire : " , style: TextStyle(
                              color: Colors.grey
                          )),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 195 , left: 75),
                          child: Text(formattedDate, style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5
                          )),
                        )
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 230),
                      height: 150, // Hauteur de la carte, ajustez si nécessaire
                      child: GoogleMap(
                        mapType: MapType.hybrid,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(position.latitude, position.longitude),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('location'),
                            position: LatLng(position.latitude, position.longitude),
                          ),
                        },
                      ),
                    ),
                  ],
                ),
                // Ajoutez la carte avec la localisation
              ],
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: MaterialButton(
                      color: Colors.white,
                      textColor: Colors.blue[900],
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.white
                        )
                      ),
                      child: const Text('Fermer',style: TextStyle(fontWeight: FontWeight.w600),),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Container(
                    child: MaterialButton(
                      color: Colors.white,
                      textColor: Colors.green,
                      shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Colors.white
                          )
                      ),
                      child: const Text('Request',style: TextStyle(fontWeight: FontWeight.w600),),
                      onPressed: () async{
                        await addCovoiturageNotification(covoiturageId, userId);
                        Navigator.of(context).pop();
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
                                    'La demande a été envoyé avec succés!',
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
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    } else {
      // Afficher un message d'erreur si le covoiturage n'existe pas
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Covoiturage non trouvé')),
      );
    }
  }


  Future<void> addCovoiturageNotification(String covoiturageId, String userId) async {
    try {
      DocumentReference CovoiturageRef = FirebaseFirestore.instance
          .collection('profiles')
          .doc(userId)
          .collection('covoiturages')
          .doc(covoiturageId) ;// Utilisation de l'ID du post pour identifier la notification

      DocumentSnapshot CovoiturageSnapshot = await CovoiturageRef.get();

      if (!CovoiturageSnapshot.exists) {
        print('Covoiturage non trouvée.');
        return;
      }

      // Générer l'heure actuelle sous forme de chaîne formatée
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      // Préparez le commentaire à ajouter
      final currentUserRequested = {
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'CovoituragesId': covoiturageId,
        'userNameRequested': await getUserName(),
        'ProfileRequested': await getProfileImage(),
        'date': formattedDate,
        'read': false,
        'destination' : 'Fes Shore',
      };

      // Ajoutez le commentaire à la liste des covoiturages
      await CovoiturageRef.update({
        'RequestedPersonnes': FieldValue.arrayUnion([currentUserRequested]),
      });


      await updateUnreadNotificationsCount(covoiturageId, userId);

      print("Covoiturages a été ajouté avec succées !!");

    } catch (e) {
      print('Erreur lors de l\'ajout de la Covoiturages: $e');
    }
  }

  Future<void> updateUnreadNotificationsCount(String covoiturageId, String userId) async {
    try {
      DocumentReference CovoiturageRef = FirebaseFirestore.instance
          .collection('profiles')
          .doc(userId)
          .collection('covoiturages')
          .doc(covoiturageId);

      DocumentSnapshot CovoiturageSnapshot = await CovoiturageRef.get();
      if (!CovoiturageSnapshot.exists) {
        print('Annonce non trouvée.');
        return;
      }

      var CovoiturageData = CovoiturageSnapshot.data() as Map<String, dynamic>;
      List<dynamic> covoiturages = CovoiturageData['RequestedPersonnes'] ?? [];

      int unreadCount = covoiturages.where((requeted) => requeted['read'] == false).length;

      await CovoiturageRef.update({
        'NotificationsCovoiturageCount': unreadCount,
        'NotificationsCovoiturage': unreadCount,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du compteur de Covoiturages non lues: $e');
    }
  }

  Future<String> getUserName() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("profiles")
          .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        return userData['NomComplet'] ?? 'User';
      }
      return 'User';
    } catch (e) {
      print("Erreur lors de la récupération du nom: $e");
      return 'Nom non disponible';
    }
  }

  Future<String> getProfileImage() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("profiles")
          .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        return userData['ProfileImage'] ?? 'User';
      }
      return 'ProfileImage';
    } catch (e) {
      print("Erreur lors de la récupération du nom: $e");
      return 'ProfileImage non disponible';
    }
  }
}
