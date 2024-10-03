import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Covoiturages/AddCovoiturage.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Covoiturages/RechercheCovoituragePage.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Covoiturages/Request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CovoituragePage extends StatefulWidget {
  const CovoituragePage({super.key});

  @override
  State<CovoituragePage> createState() => _CovoituragePageState();
}

class _CovoituragePageState extends State<CovoituragePage> {

  CameraPosition cameraPosition = const CameraPosition(target: LatLng(34.01789928905642, -5.0072285905480385) , zoom: 13.5);
  GoogleMapController? googleMapController;
  List<Marker> markers = [];
  User? user = FirebaseAuth.instance.currentUser;

  Stream<List<Map<String, dynamic>>> getNotificationsCount(String userId) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty(); // Return an empty stream if the user is not logged in
    }
    return FirebaseFirestore.instance
        .collection('profiles')
        .snapshots()
        .asyncMap((profilesSnapshot) async {
      List<Map<String, dynamic>> AllNotificationsCount = [];
      for (QueryDocumentSnapshot profileDoc in profilesSnapshot.docs) {
        if(profileDoc.id == userId) {
          QuerySnapshot CovoiturageSnapshot = await profileDoc.reference.collection('covoiturages').get();
          for (QueryDocumentSnapshot CovoiturageDoc in CovoiturageSnapshot.docs) {
            var CovoiturageData = CovoiturageDoc.data() as Map<String, dynamic>;
            int notificationsCovoiturage = CovoiturageData['NotificationsCovoiturageCount'] ?? 0;
            AllNotificationsCount.add(
                {'NotificationsCovoiturageCount': notificationsCovoiturage});
          }
          break;
        }
      }
      return AllNotificationsCount;
    });
  }

  Future<void> markAllNotificationsAsRead(String userSender) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Assurez-vous que l'utilisateur est connecté

    final profileRef = FirebaseFirestore.instance.collection('profiles').doc(user.uid);
    final CovoiturageSnapshot = await profileRef.collection('covoiturages').get();

    for (var CovoiturageDoc in CovoiturageSnapshot.docs) {
        var CovoiturageData = CovoiturageDoc.data();
        List<dynamic> NotificationCovoiturages = List.from(CovoiturageData['RequestedPersonnes'] ?? []);

        bool updated = false;

        for (var requestNotifs in NotificationCovoiturages) {
          if (requestNotifs['read'] == false) {
            requestNotifs['read'] = true;
            updated = true;
          }
        }

        if (updated) {
          await CovoiturageDoc.reference.update({
            'RequestedPersonnes': NotificationCovoiturages,
          });

          int unreadMessageCount = NotificationCovoiturages.where((notif) => notif['read'] == false).length;


          await CovoiturageDoc.reference.update({
            'NotificationsCovoiturageCount': unreadMessageCount,

          });
        }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: 730,
            child: Column(
              children: [
                Expanded(child: GoogleMap(initialCameraPosition: cameraPosition ,
                  onTap: (LatLng latlng) {
                    print(latlng.latitude);
                    print(latlng.longitude);
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
                height: 55,
                width: 390,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white,
                ),
                child: Stack(
                  children: [
                      InkWell(
                        onTap: () async{
                          await markAllNotificationsAsRead(user!.uid);
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                            const RequestPage()));
                        },
                        child: Container(margin : const EdgeInsets.only(top: 5, left: 8) , child: Image.asset('assets/covoiturage2.png')),
                      ),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: user != null ? getNotificationsCount(user!.uid) : const Stream.empty(),
                      builder: (context, snapshot) {
                          int totalCovoiturage = 0;
                          if (snapshot.hasData) {
                            for (var item in snapshot.data!) {
                              totalCovoiturage += (item['NotificationsCovoiturageCount'] as num?)?.toInt() ?? 0;
                            }
                          }
                          int totalNotifications = totalCovoiturage;
                          return Stack(
                              children: [
                                if (totalNotifications > 0)
                                  Positioned(
                                    bottom: 35,
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 50),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      constraints: const BoxConstraints(
                                        maxWidth: 14,
                                        maxHeight: 14,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$totalNotifications',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                          );
                      },
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 83, top: 18),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RechercheCovoituragePage()),
                          );
                        },
                        child: Text('Rechercher une covoiturage...', style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700]
                        ),),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 16.5 , right: 20),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const AddCovoiturage()));
                            },
                            child: Icon(Icons.add, size: 28 , color: Colors.grey[700],),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
          ),
        ],
      )
    );
  }
}
