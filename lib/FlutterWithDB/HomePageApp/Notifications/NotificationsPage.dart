import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/CommentsPosts/CommentsPosts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rxdart/rxdart.dart';

import '../../Authentification/GoogleAuth/GoogleOut.dart';
import '../CustomAppBar/CustomAppBar.dart';
import '../CustomDrawer/CustomDrawer.dart';
import '../NavigationBotton/HomeBouttomsSheets.dart';

class NotificationsPage extends StatefulWidget{
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPage();
}

class _NotificationsPage extends State<NotificationsPage> {
  String? messageNotifs ;
  User? user = FirebaseAuth.instance.currentUser;
  final GlobalKey<ScaffoldState> profilePageKeyNotifs = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  GoogleOut googleOut = GoogleOut();
  bool isGoogleUser = false;
  String userEmail = '';
  bool isProfilePageVisible = false;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> _logout() async {
    setState(() {
      isLoading = true;
    });
    try {
      await googleOut.logout(context);
    } catch (e) {
      print("Erreur de déconnexion: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  void _handleSignOut() async {
    Navigator.of(context).pop(); // Ferme le drawer
    await _logout();
  }

  Future<void> getEmailUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (user.providerData.any((provider) => provider.providerId == 'google.com')) {
          userEmail = await storage.read(key: 'googleEmail') ?? '';
          setState(() {});
        }
        else {
          userEmail = await storage.read(key: 'Email') ?? '';
          setState(() {});
        }
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> checkUserType() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (user.providerData.any((provider) => provider.providerId == 'google.com')) {
          setState(() {
            isGoogleUser = true;
          });
        }
        else {
          setState(() {
            isGoogleUser = false;
          });
        }
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<String?> getProfileImageUrl() async {
    if (isGoogleUser) {
      return await storage.read(key: 'userProfileImageUrl');
    } else {
      return await storage.read(key: 'profile_image'); // Image importée depuis la galerie
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
        return userData['NomComplet'] ?? 'Nom non disponible';
      }
      return 'User';
    } catch (e) {
      print("Erreur lors de la récupération du nom: $e");
      return 'Nom non disponible';
    }
  }

  Future<String> getUserId() async {
    try {
      DocumentSnapshot annonceSnapshot = await FirebaseFirestore.instance
          .collection("profiles")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (annonceSnapshot.exists) {
        var annonceData = annonceSnapshot.data() as Map<String, dynamic>;
        var userId = annonceData['id'] ?? 'Texte non disponible';
        return userId;
      }
      return 'Texte non disponible';
    } catch (e) {
      print("Erreur lors de la récupération du texte de l'annonce: $e");
      return 'Erreur lors de la récupération du texte';
    }
  }


  Stream<List<Map<String, dynamic>>> getPersonsNotifications(String userId) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty(); // Return an empty stream if the user is not logged in
    }
    return FirebaseFirestore.instance
        .collection('profiles')
        .snapshots()
        .asyncMap((profilesSnapshot) async {
      List<Map<String, dynamic>> AllPersonsNotified = [];
      for (QueryDocumentSnapshot profileDoc in profilesSnapshot.docs) {
        if(profileDoc.id == userId) {
          QuerySnapshot annoncesSnapshot = await profileDoc.reference.collection('annonces').get();
          for (QueryDocumentSnapshot annonceDoc in annoncesSnapshot.docs) {
            var annonceData = annonceDoc.data() as Map<String, dynamic>;

            if (annonceData['notifications'] != null) {
              List<dynamic> Notifications = annonceData.containsKey('notifications') && annonceData['notifications'] is List
                  ? List.from(annonceData['notifications'] as List<dynamic>)
                  : [];
              for (var notification in Notifications) {
                // Assurez-vous que chaque like contient les informations nécessaires
                AllPersonsNotified.add({
                  'userName': notification['userName'],
                  'userLiker': notification['userId'],
                  'imageProfile': notification['imageProfile'],
                  'typeNotifs' : notification['typeNotifs'],
                  'annonceId': notification['annonceId'],
                  'ContexteAnnonce': notification['ContexteAnnonce'],
                  'ListOfNotifications' : Notifications,
                  'date' : notification['date'],
                });
              }
            }
          }
          break;
        }
      }
      // Tri des notifications par date (de la plus récente à la plus ancienne)
      AllPersonsNotified.sort((a, b) {
        DateTime dateA = DateTime.parse(a['date']);
        DateTime dateB = DateTime.parse(b['date']);
        return dateB.compareTo(dateA);  // Tri décroissant
      });
      return AllPersonsNotified;
    });
  }

  Stream<List<Map<String, dynamic>>> getPersonsNotificationsComments(String userId) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty(); // Return an empty stream if the user is not logged in
    }
    return FirebaseFirestore.instance
        .collection('profiles')
        .snapshots()
        .asyncMap((profilesSnapshot) async {
      List<Map<String, dynamic>> AllPersonsCommented = [];
      for (QueryDocumentSnapshot profileDoc in profilesSnapshot.docs) {
        if(profileDoc.id == userId) {
          QuerySnapshot annoncesSnapshot = await profileDoc.reference.collection('annonces').get();
          for (QueryDocumentSnapshot annonceDoc in annoncesSnapshot.docs) {
            var annonceData = annonceDoc.data() as Map<String, dynamic>;
            if (annonceData['notificationsComments'] != null){
              List<dynamic> NotificationsComments = annonceData.containsKey('notificationsComments') && annonceData['notificationsComments']
              is List
                  ? List.from(annonceData['notificationsComments'] as List<dynamic>)
                  : [];
              for (var notification in NotificationsComments) {
                // Assurez-vous que chaque like contient les informations nécessaires
                AllPersonsCommented.add({
                  'userName': notification['userName'],
                  'userLiker': notification['userId'],
                  'imageProfile': notification['imageProfile'],
                  'typeNotifs' : notification['typeNotifs'],
                  'annonceId': notification['annonceId'],
                  'ContexteAnnonce': notification['ContexteAnnonce'],
                  'ListOfNotifications' : NotificationsComments,
                  'date' : notification['date'],
                });
              }
            }
          }
          break;
        }
      }
      AllPersonsCommented.sort((a, b) {
        DateTime dateA = DateTime.parse(a['date']);
        DateTime dateB = DateTime.parse(b['date']);
        return dateB.compareTo(dateA);  // Tri décroissant
      });
      return AllPersonsCommented;
    });
  }

  Stream<List<Map<String, dynamic>>> combinedNotificationsStream(String userId) {
    return Rx.combineLatest2(
      getPersonsNotifications(userId),
      getPersonsNotificationsComments(userId),
          (List<Map<String, dynamic>> likes, List<Map<String, dynamic>> comments) {
        return [...likes, ...comments];
      },
    );
  }




  @override
  void initState() {
    getEmailUser();
    checkUserType();
    getUserName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: profilePageKeyNotifs, // Assurez-vous que le globalKey est défini ici
      drawer: CustomDrawer(
        isGoogleUser: isGoogleUser,
        userEmail: userEmail,
        getProfileImageUrl: getProfileImageUrl,
        onHomePressed: () {
          print("Home button pressed");
          Navigator.of(context).pop();
          Navigator.of(context).pushNamedAndRemoveUntil("/homepage", (route) => false);// Ferme le drawer
        },
        onProfilePressed: () {
          Navigator.of(context).pop();
        },
        onAboutUsPressed: () {},
        onSignOutPressed: () {
          _handleSignOut();
        },
        getUserName: getUserName,
      ),
      body: Container(
        child: Column(
          children: [
            CustomAppBar(
              onDrawerOpen: () {
                profilePageKeyNotifs.currentState?.openDrawer();
              },
            ),
            Expanded(
              child: Container(
                child: ListView(
                  children: [
                    Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F2EF),
                        )
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15,top: 10),
                      child: const Text("Notifications",style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontFamily: "assets/Roboto-Regular.ttf",
                      )),
                    ),
                    const SizedBox(height: 10),
                    Container(
                        height: 2,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F2EF),
                        )
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: user != null ? getPersonsNotifications(user!.uid) : const Stream.empty(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(child: const Center(child: CircularProgressIndicator(color: Colors.blue)));
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Erreur: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return StreamBuilder<List<Map<String, dynamic>>>(
                            stream:  user != null ? getPersonsNotificationsComments(user!.uid) : const Stream.empty(),
                            builder: (context, CommentsSnapshot) {
                              if (!CommentsSnapshot.hasData || CommentsSnapshot.data!.isEmpty) {
                                return const Center(child: Text("Aucune Notification pour le moment"));
                              } else{
                                return Container();
                              }
                            },
                          );
                        } else {
                          var annonces = snapshot.data!;

                          // Regrouper les notifications par annonceId
                          Map<String, List<Map<String, dynamic>>> groupedNotifications = {};
                          for (var data in annonces) {
                            String annonceId = data['annonceId'] ?? '';
                            if (!groupedNotifications.containsKey(annonceId)) {
                              groupedNotifications[annonceId] = [];
                            }
                            groupedNotifications[annonceId]!.add(data);
                          }

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: groupedNotifications.entries.map((entry) {
                              String annonceId = entry.key;
                              List<Map<String, dynamic>> notifications = entry.value;
                              String ContexteAnnonce = notifications.first['ContexteAnnonce'] ?? '';
                              // Construire le message combiné
                              String userName = notifications.first['userName'] ?? '';
                              String imageProfile = notifications.first['imageProfile'] ?? '';
                              String typeNotifs = notifications.first['typeNotifs'] ?? '';
                              int likeCount = notifications.length;
                              DateTime now = DateTime.now();
                              String dateNotifsStr = notifications.first['date'] ?? '';
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

                              String messageNotifs;
                              if (likeCount == 1) {
                                messageNotifs = "$userName ";
                              } else {
                                messageNotifs = "$userName ";
                              }

                              return Column(
                                children: [
                                  const SizedBox(height: 3),
                                  Stack(
                                    children: [
                                      likeCount == 1 ?
                                      Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(left: 25),
                                            height: 45,
                                            width: 45,
                                            child: InkWell(
                                              child: imageProfile.startsWith('http')
                                                  ? CircleAvatar(
                                                backgroundImage: NetworkImage(imageProfile),
                                              )
                                                  : CircleAvatar(
                                                backgroundImage: FileImage(File(imageProfile)),
                                                child: imageProfile.isEmpty ? const Icon(Icons.person) : null,
                                              ),
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => HomeBottomSheets(
                                                      initialPage: 'LikerRedidirection',
                                                      userId: notifications.first['userLiker'],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(left: 90,top: 8,right: 50),
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: messageNotifs,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: "assets/Roboto-Regular.ttf",
                                                      color: Colors.black, // Couleur du texte normal
                                                    ),
                                                  ),TextSpan(
                                                    text: "a $typeNotifs votre post ",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: "assets/Roboto-Regular.ttf",
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black, // Couleur du texte normal
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(left: 90,top: 7 , right: 10),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets.only(left: 7),
                                                      child: const Icon(Icons.more_vert),
                                                    ),
                                                    Container(margin: const EdgeInsets.only(top: 25),child: Text(timeAgo,style: const TextStyle(fontSize: 10),),)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(left: 90, top: 27,right: 80),
                                            child: Text(
                                              ContexteAnnonce,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontFamily: "assets/Roboto-Regular.ttf",
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(left: 75, top: 35),
                                            child: MaterialButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CommentsPosts(annonceId: annonceId, userId: notifications.first['userLiker']),
                                                  ),
                                                );
                                              },
                                              textColor: Colors.blue[800],
                                              child: const Text(
                                                "Voir le post",style: TextStyle(fontSize: 13),),
                                            ),
                                          ),
                                        ],
                                      )
                                          : Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(left: 25),
                                            height: 50,
                                            width: 50,
                                            child: InkWell(
                                              child: imageProfile.startsWith('http')
                                                  ? CircleAvatar(
                                                backgroundImage: NetworkImage(imageProfile),
                                              )
                                                  : CircleAvatar(
                                                backgroundImage: FileImage(File(imageProfile)),
                                                child: imageProfile.isEmpty ? const Icon(Icons.person) : null,
                                              ),
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => HomeBottomSheets(
                                                      initialPage: 'LikerRedidirection',
                                                      userId: notifications.first['userLiker'],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(left: 90,top: 5,right: 58),
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: messageNotifs,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: "assets/Roboto-Regular.ttf",
                                                      color: Colors.black, // Couleur du texte normal
                                                    ),
                                                  ),TextSpan(
                                                    text: "et ${likeCount - 1} autres personnes ont $typeNotifs votre post",
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 16,
                                                      color: Colors.black87, // Couleur du texte normal
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(left: 90,top: 7 , right: 10),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets.only(left: 7),
                                                      child: const Icon(Icons.more_vert),
                                                    ),
                                                    Container(margin: const EdgeInsets.only(top: 25),child: Text(timeAgo,style: const TextStyle(fontSize: 10),),)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(left: 73, top: 30),
                                            child: MaterialButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CommentsPosts(annonceId: annonceId, userId: notifications.first['userLiker']),
                                                  ),
                                                );
                                              },
                                              textColor: Colors.blue[800],
                                              child: const Text(
                                                "Voir le post",style: TextStyle(
                                                  fontSize: 12
                                              ),),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                ],
                              );
                            }).toList(),
                          );
                        }
                      },),
                    StreamBuilder<List<Map<String, dynamic>>> (
                      stream: user != null ? getPersonsNotificationsComments(user!.uid) : const Stream.empty(),
                      builder: (context, CommentsSnapshot) {
                        if (!CommentsSnapshot.hasData || CommentsSnapshot.data!.isEmpty) {
                          return StreamBuilder<List<Map<String, dynamic>>>(
                            stream: user != null ? getPersonsNotifications(user!.uid) : const Stream.empty(),
                            builder: (context, likeSnapshot) {
                              if (!likeSnapshot.hasData || likeSnapshot.data!.isEmpty) {
                                return Container();
                              } else {
                                return Container(); // Retourne rien si des notifications de likes existent
                              }
                            },
                          );
                        }  else {
                          var annonces = CommentsSnapshot.data!;
                          // Regrouper les notifications par annonceId
                          Map<String, List<Map<String, dynamic>>> groupedNotifications = {};
                          for (var data in annonces) {
                            String annonceId = data['annonceId'] ?? '';
                            if (!groupedNotifications.containsKey(annonceId)) {
                              groupedNotifications[annonceId] = [];
                            }
                            groupedNotifications[annonceId]!.add(data);
                          }
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: groupedNotifications.entries.map((entry) {
                              String annonceId = entry.key;
                              List<Map<String, dynamic>> notifications = entry.value;
                              String ContexteAnnonce = notifications.first['ContexteAnnonce'] ?? '';
                              // Construire le message combiné
                              String userName = notifications.first['userName'] ?? '';
                              String imageProfile = notifications.first['imageProfile'] ?? '';
                              String typeNotifs = notifications.first['typeNotifs'] ?? '';
                              DateTime now = DateTime.now();
                              String dateNotifsStr = notifications.first['date'] ?? '';
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

                              int CommentsCount = notifications.length;

                              String messageNotifs;
                              if (CommentsCount == 1) {
                                messageNotifs = "$userName ";
                              } else {
                                messageNotifs = "$userName ";
                              }

                              return Column(
                                children: [
                                  const SizedBox(height: 3),
                                  Stack(
                                    children: [
                                      CommentsCount == 1 ?
                                      Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(left: 25),
                                            height: 50,
                                            width: 50,
                                            child: InkWell(
                                              child: imageProfile.startsWith('http')
                                                  ? CircleAvatar(
                                                backgroundImage: NetworkImage(imageProfile),
                                              )
                                                  : CircleAvatar(
                                                backgroundImage: FileImage(File(imageProfile)),
                                                child: imageProfile.isEmpty ? const Icon(Icons.person) : null,
                                              ),
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => HomeBottomSheets(
                                                      initialPage: 'LikerRedidirection',
                                                      userId: notifications.first['userLiker'],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(left: 90,top: 8,right: 50),
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: messageNotifs,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: "assets/Roboto-Regular.ttf",
                                                      color: Colors.black, // Couleur du texte normal
                                                    ),
                                                  ),TextSpan(
                                                    text: "a $typeNotifs votre post publié : ",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: "assets/Roboto-Regular.ttf",
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black, // Couleur du texte normal
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(left: 90,top: 7 , right: 10),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets.only(left: 7),
                                                      child: const Icon(Icons.more_vert),
                                                    ),
                                                    Container(margin: const EdgeInsets.only(top: 25),child: Text(timeAgo,style: const TextStyle(fontSize: 10),),)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(left: 185, top: 27,right: 65),
                                            child: Text(
                                              ContexteAnnonce,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontFamily: "assets/Roboto-Regular.ttf",
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(left: 75, top: 35),
                                            child: MaterialButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CommentsPosts(annonceId: annonceId, userId: notifications.first['userLiker']),
                                                  ),
                                                );
                                              },
                                              textColor: Colors.blue[800],
                                              child: const Text(
                                                "Voir le post",style: TextStyle(
                                                  fontSize: 12
                                              ),),
                                            ),
                                          ),
                                        ],
                                      )
                                          : Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(left: 25),
                                            height: 50,
                                            width: 50,
                                            child: InkWell(
                                              child: imageProfile.startsWith('http')
                                                  ? CircleAvatar(
                                                backgroundImage: NetworkImage(imageProfile),
                                              )
                                                  : CircleAvatar(
                                                backgroundImage: FileImage(File(imageProfile)),
                                                child: imageProfile.isEmpty ? const Icon(Icons.person) : null,
                                              ),
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => HomeBottomSheets(
                                                      initialPage: 'LikerRedidirection',
                                                      userId: notifications.first['userLiker'],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(left: 90,top: 5,right: 80),
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: messageNotifs,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: "assets/Roboto-Regular.ttf",
                                                      color: Colors.black, // Couleur du texte normal
                                                    ),
                                                  ),TextSpan(
                                                    text: "et ${CommentsCount - 1} autres personnes ont $typeNotifs votre post : ",
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 16,
                                                      color: Colors.black87, // Couleur du texte normal
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(left: 135 , top: 43,right: 70),
                                            child: Text(
                                              ContexteAnnonce,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontFamily: "assets/Roboto-Regular.ttf",
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(left: 90,top: 7 , right: 10),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets.only(left: 7),
                                                      child: const Icon(Icons.more_vert),
                                                    ),
                                                    Container(margin: const EdgeInsets.only(top: 25),child: Text(timeAgo,style: const TextStyle(fontSize: 10),),)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(left: 73, top: 48),
                                            child: MaterialButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CommentsPosts(annonceId: annonceId, userId: notifications.first['userLiker']),
                                                  ),
                                                );
                                              },
                                              textColor: Colors.blue[800],
                                              child: const Text(
                                                "Voir le post",style: TextStyle(
                                                  fontSize: 12
                                              ),),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                ],
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),

                  ]
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}
