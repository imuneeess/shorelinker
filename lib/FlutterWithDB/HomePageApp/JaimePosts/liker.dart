import 'dart:io';
import 'package:courseflutter/FlutterWithDB/HomePageApp/NavigationBotton/HomeBouttomsSheets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LikePage extends StatefulWidget{
  final String postId ;
  const LikePage({super.key, required this.postId});
  @override
  State<LikePage> createState() => _MyApp();
}

class _MyApp extends State<LikePage> {


  Stream<List<Map<String, dynamic>>> getLikeByPosts(String postId) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty(); // Return an empty stream if the user is not logged in
    }
    return FirebaseFirestore.instance
        .collection('profiles')
        .snapshots()
        .asyncMap((profilesSnapshot) async {
      List<Map<String, dynamic>> allLikes = [];
      for (QueryDocumentSnapshot profileDoc in profilesSnapshot.docs) {
        QuerySnapshot annoncesSnapshot = await profileDoc.reference.collection('annonces').get();
        for (QueryDocumentSnapshot annonceDoc in annoncesSnapshot.docs) {
          if (annonceDoc.id == postId) { // Filtrer par profileId
            allLikes.add(annonceDoc.data() as Map<String, dynamic>);
            break;
          }
        }
      }
      return allLikes;
    });
  }

  Stream<List<Map<String, dynamic>>> getPersonsLikesPosts(String postId) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty(); // Return an empty stream if the user is not logged in
    }
    return FirebaseFirestore.instance
        .collection('profiles')
        .snapshots()
        .asyncMap((profilesSnapshot) async {
      List<Map<String, dynamic>> AllPersons = [];
      for (QueryDocumentSnapshot profileDoc in profilesSnapshot.docs) {
        QuerySnapshot annoncesSnapshot = await profileDoc.reference.collection('annonces').get();
        for (QueryDocumentSnapshot annonceDoc in annoncesSnapshot.docs) {
          if (annonceDoc.id == postId) { // Filtrer par profileId
            var annonceData = annonceDoc.data() as Map<String, dynamic>;
            List<dynamic> likes = annonceData.containsKey('likes') && annonceData['likes'] is List
                ? List.from(annonceData['likes'] as List<dynamic>)
                : [];
            for (var like in likes) {
              // Assurez-vous que chaque like contient les informations nécessaires
              AllPersons.add({
                'userName': like['userName'],
                'userLiker': like['userId'],
                'imageProfile': like['imageProfile'],
                'userTitreProfil': like['userTitreProfil'],
              });
            }
            break; // On a trouvé le post, pas besoin de continuer la recherche
          }
        }
      }
      return AllPersons;
    });
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Réactions" , style: TextStyle(
          fontSize: 22,
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontFamily: "assets/Roboto-Regular.ttf",
        ),),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              height: 1,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F2EF),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: getLikeByPosts(widget.postId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(child: const Text("loading..."));
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Aucune annonce disponible'));
                    }else{
                      var annonces = snapshot.data!;

                      return Column(
                        children: annonces.map((data){
                          int likesCount = data['likesCount'] is int ? data['likesCount'] as int : 0;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 20),
                                child: Text("Toutes ($likesCount)",style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                  fontFamily: "assets/Roboto-Regular.ttf",
                                  fontSize: 14,
                                ),),
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    }
                  }
              ),
            ),
            const SizedBox(height: 7),
            Container(
              margin: const EdgeInsets.only(right: 300),
              height: 4,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 3),
            Container(
              height: 2,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F2EF),
              ),
            ),
            Expanded(
              child: Container(
                child: ListView(
                  children: [
                    StreamBuilder<List<Map<String, dynamic>>>(
                        stream: getPersonsLikesPosts(widget.postId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(child: const Text("loading..."));
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Erreur: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text("Aucun J'aime pour ce post"));
                          }else{
                            var annonces = snapshot.data!;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: annonces.map((data){
                                String userName = data['userName'] ?? 'Inconnu';
                                String imageProfile = data['imageProfile'] ?? '';
                                String userTitreProfil = data['userTitreProfil'] ?? '';
                                String userLiker = data['userLiker'] ?? '' ;
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 3),
                                    Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(left: 20),
                                            height: 50,
                                            width: 50,
                                            child: InkWell(
                                              child: imageProfile.startsWith('http')
                                                  ? CircleAvatar(
                                                backgroundImage: NetworkImage(imageProfile),
                                              )
                                                  : CircleAvatar(
                                                backgroundImage: FileImage(File(imageProfile)),
                                                child: imageProfile.isEmpty
                                                    ? const Icon(Icons.person)
                                                    : null,
                                              ),
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => HomeBottomSheets(
                                                        initialPage: 'LikerRedidirection',
                                                        userId: userLiker),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color : Colors.blue,
                                              borderRadius: BorderRadius.circular(100),
                                              border: const Border(
                                                top: BorderSide(
                                                  color: Colors.white
                                                ),
                                                  left: BorderSide(
                                                      color: Colors.white
                                                  )
                                              )
                                            ),
                                            margin: const EdgeInsets.only(top: 33, left: 55),
                                            padding: const EdgeInsets.all(2),
                                            child: const Icon(Icons.thumb_up, color: Colors.white,size: 12,),
                                          ),
                                          Container(
                                              margin: const EdgeInsets.only(left: 78,top: 5),
                                              child: Text(userName,style: const TextStyle(
                                                fontSize: 15,
                                                fontFamily: "assets/Roboto-Regular.ttf",
                                                fontWeight: FontWeight.w500,
                                              ))
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(left: 78,top: 28),
                                            child: Text(
                                                userTitreProfil,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(fontSize: 11,color: Colors.grey[700]),
                                            ),
                                          )
                                        ],
                                      ),
                                    const SizedBox(height: 3),
                                    Container(
                                      height: 1,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF3F2EF),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                  ],
                                );
                              }).toList(),

                            );
                          }
                        }
                    ),
                  ],
                ),
              ),
            ),
            /*Row(
              Container(child: Text(userName)),
              Container(
                child: Text(userTitreProfil,style: TextStyle(
                    fontSize: 12
                ),),
              ),
            )*/
          ],
        ),
      ),
    );
  }
}
