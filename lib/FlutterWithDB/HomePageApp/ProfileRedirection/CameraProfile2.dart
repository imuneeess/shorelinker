import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CameraProfile2 extends StatefulWidget {
  final Widget widget;
  final String docId;
  final String profileId; // Ajouter profileId

  const CameraProfile2({super.key, required this.widget, required this.profileId, required this.docId});

  @override
  _CameraProfileState createState() => _CameraProfileState();
}

class _CameraProfileState extends State<CameraProfile2> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool isGoogleUser = false;
  User? user  = FirebaseAuth.instance.currentUser;
  Future<List<Map<String, dynamic>>> getAllAnnouncements(String docId) async {
    List<Map<String, dynamic>> allAnnouncements = [];
    try {
      QuerySnapshot profilesSnapshot = await FirebaseFirestore.instance.collection('profiles').get();
      for (QueryDocumentSnapshot profileDoc in profilesSnapshot.docs) {
        QuerySnapshot annoncesSnapshot = await profileDoc.reference.collection('annonces').get();
        for (QueryDocumentSnapshot annonceDoc in annoncesSnapshot.docs) {
          if (annonceDoc.id == docId) {
            allAnnouncements.add({
              ...annonceDoc.data() as Map<String, dynamic>,
            });
          }
        }
      }

    } catch (e) {
      print('Erreur lors de la récupération des annonces: $e');
    }
    return allAnnouncements;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.white,
            ),
            height: 145,
            width: 140,
            margin: const EdgeInsets.only(left: 15),
            padding: const EdgeInsets.all(4),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getAllAnnouncements(widget.docId), // Passer profileId ici
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading image'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No image available'));
                } else {
                  var annonces = snapshot.data!;

                  return ListView(
                    children: annonces.map((data) {
                      String userAnnonce = data['userAnnonce'];
                      String ownerID = data['ownerId'];
                      return Container(
                        child: Column(
                          children: [
                            ownerID == ((user!.uid) != '') ? Container() :
                            ClipOval(
                                child: userAnnonce.startsWith('http')  ?
                                Image.network(
                                  height: 135,
                                  userAnnonce,
                                  fit: BoxFit.cover, // Ajuste l'image pour couvrir le conteneur
                                ) :
                                Image.file(
                                  height: 135,
                                  width: double.infinity,
                                  File(userAnnonce),
                                  fit: BoxFit.cover, // Ajuste l'image pour couvrir le conteneur
                                )
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
          Positioned(
            child: widget.widget,
          ),
        ],
      ),
    );
  }
}
