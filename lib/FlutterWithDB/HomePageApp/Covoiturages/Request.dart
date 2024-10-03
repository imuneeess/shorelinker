import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Messages/Discussion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'AnimatedAsset.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {

  User? user = FirebaseAuth.instance.currentUser;

  bool _isContainerVisible = false;

  void _toggleContainerVisibility() {
    setState(() {
      _isContainerVisible = !_isContainerVisible;
    });
  }

  Stream<List<Map<String, dynamic>>> getAllCovoituragesForCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty(); // Return an empty stream if the user is not logged in
    }

    return FirebaseFirestore.instance
        .collection('profiles')
        .doc(user.uid) // Récupère uniquement les covoiturages de l'utilisateur connecté
        .collection('covoiturages')
        .snapshots()
        .asyncMap((messagesSnapshot) async {
      List<Map<String, dynamic>> allCovoiturages = [];

      for (QueryDocumentSnapshot messageDoc in messagesSnapshot.docs) {
        var messageData = messageDoc.data() as Map<String, dynamic>;
        List<dynamic> covoiturages = messageData.containsKey('RequestedPersonnes') && messageData['RequestedPersonnes'] is List
            ? List.from(messageData['RequestedPersonnes'] as List<dynamic>)
            : [];
        for (var requestedPersonne in covoiturages) {
          allCovoiturages.add({
            'CovoituragesId': requestedPersonne['CovoituragesId'],
            'ProfileRequested': requestedPersonne['ProfileRequested'],
            'date': requestedPersonne['date'],
            'destination': requestedPersonne['destination'],
            'userId': requestedPersonne['userId'],
            'userNameRequested': requestedPersonne['userNameRequested'],
          });
        }
      }

      // Trier les messages par timestamp du plus récent au plus ancien
      allCovoiturages.sort((a, b) {
        DateTime dateA = DateTime.parse(a['date']);
        DateTime dateB = DateTime.parse(b['date']);
        return dateB.compareTo(dateA); // Inverser l'ordre pour trier du plus récent au plus ancien
      });

      return allCovoiturages;
    });
  }


  Future<void> showCovoiturageDetails(String userId, String covoiturageId,String userDiscussion,String image , String name) async {
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
                      child: const Text('Contacter',style: TextStyle(fontWeight: FontWeight.w600),),
                      onPressed: () async{
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                          DiscussionPage(NomComplet: name, ProfileImage: image, UserId: userDiscussion)));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Demande de covoiturage",style: TextStyle(
          color: Colors.blue[900],
          fontSize: 16.5
        ),),
        iconTheme: IconThemeData(
          color: Colors.blue[900]
        ),
      ),
      body: Stack(
        children: [
          Container(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F2EF),
                          )
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: StreamBuilder<List<Map<String, dynamic>>>(
                              stream: user != null ? getAllCovoituragesForCurrentUser() : const Stream.empty(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: Text('Chargement pour les demandes...'));
                                }else if (snapshot.hasError) {
                                  return Center(child: Text('Erreur : ${snapshot.error}'));
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Center(child: Text("Aucun covoiturage disponible!"));
                                } else {
                                  var allCovoiturages= snapshot.data!;

                                  return Column(
                                    children: allCovoiturages.map((data) {

                                      String CovoituragesId = data['CovoituragesId'];
                                      String name = data['userNameRequested'];
                                      String image = data['ProfileRequested'];
                                      String dateNotifsStr = data['date'] ?? '';
                                      String userId = data['userId'] ?? '' ;
                                      DateTime now = DateTime.now();
                                      DateTime dateNotifs;
                                      try {
                                        dateNotifs = DateTime.parse(dateNotifsStr);
                                      } catch (e) {
                                        print('Erreur de format de date: $e');
                                        dateNotifs = now; // ou une autre valeur par défaut
                                      }
                                      int daysDifference = now.difference(dateNotifs).inDays;
                                      int hoursDifference = now.difference(dateNotifs).inHours;
                                      int minutesDifference = now.difference(dateNotifs).inMinutes;
                                      int secondesDifference = now.difference(dateNotifs).inSeconds;
                                      String timeAgo;

                                      if (daysDifference > 0) {
                                        timeAgo = '$daysDifference j.';
                                      } else if (hoursDifference > 0) {
                                        timeAgo = '$hoursDifference h.';
                                      } else if (minutesDifference > 0) {
                                        timeAgo = '$minutesDifference min.';
                                      } else if (secondesDifference > 0) {
                                        timeAgo = '$secondesDifference sec.';
                                      } else {
                                        timeAgo = 'Maintenant...';
                                      }

                                      return Column(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(top: 15),
                                            child: InkWell(
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets.only(left: 15),
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.blueGrey, width: 1),
                                                          borderRadius: BorderRadius.circular(100),
                                                        ),
                                                        height: 60,
                                                        width: 60,
                                                        child: CircleAvatar(
                                                          backgroundImage: image.startsWith('http')
                                                              ? NetworkImage(image)
                                                              : (image.isEmpty
                                                              ? const AssetImage('assets/default_profile.png')
                                                              : FileImage(File(image)) as ImageProvider),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsets.only(left : 60, top: 40),
                                                        decoration: BoxDecoration(
                                                            border: const Border(
                                                                right: BorderSide(color: Colors.white),
                                                                left: BorderSide(color: Colors.white),
                                                                top: BorderSide(color: Colors.white),
                                                                bottom:BorderSide(color: Colors.white)
                                                            ),
                                                            borderRadius: BorderRadius.circular(100),
                                                            color: Colors.blue
                                                        ),
                                                        padding: const EdgeInsets.all(2),
                                                        child: const Icon(Icons.help,color: Colors.white,size: 13,),
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsets.only(left: 30, top: 65),
                                                        child: Text(timeAgo,style: const TextStyle(
                                                            fontSize: 9,
                                                            color: Colors.grey
                                                        ),),
                                                      ),
                                                    ],
                                                  ),
                                                  Expanded(
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          margin: const EdgeInsets.only(left: 12, top: 5),
                                                          child: Text(
                                                            name,
                                                            style: const TextStyle(
                                                              fontFamily: "assets/Roboto-Regular.ttf",
                                                              fontSize: 17,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                margin: const EdgeInsets.only(top: 30, right: 30 , left: 12),
                                                                child: Text(
                                                                  '$name a demandé le covoiturage que vous avea partagé',
                                                                  style: const TextStyle(
                                                                    fontFamily: "assets/Roboto-Regular.ttf",
                                                                    fontSize: 12,
                                                                    color: Colors.grey,
                                                                  ),
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 1,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          margin: const EdgeInsets.only(left: 12, top: 48),
                                                          child: Text('voir la demande',style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors.blue[900]
                                                          ),),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              onTap: () async{
                                                //print('id '  + userId);
                                                await showCovoiturageDetails(user!.uid, CovoituragesId,userId,image, name);
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            )
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _isContainerVisible ? MediaQuery.of(context).size.height * 0.3 : MediaQuery.of(context).size.height,
            left: MediaQuery.of(context).size.width * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isContainerVisible ? 1 : 0,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(child: Text("Détails du covoiturage")),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
