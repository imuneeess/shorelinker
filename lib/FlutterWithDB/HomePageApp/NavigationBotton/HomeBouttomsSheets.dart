import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Annonces/Annonce.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/CommentsPosts/CommentsPosts.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Covoiturages/Covoiturage.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/JaimePosts/LikerRedirection.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/JaimePosts/liker.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Messages/messages.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/NavigationBotton/CustomBottomNavigationBar.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Notifications/NotificationsPage.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/ProfileRedirection/ProfileRediriction.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/ProfileRedirection/ProfileRedirictionSearch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/HomePageApp.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/ProfilePage.dart';

import '../Messages/ProfileRedirictionDiscussion.dart';

class HomeBottomSheets extends StatefulWidget {
  static final GlobalKey<_HomeBottomSheetsState> homeBottomSheetKey = GlobalKey<_HomeBottomSheetsState>();
  final String initialPage;
  final String? ownerId;
  final String? userId;
  final String? docId;
  final String? NomComplet;// Assurez-vous que cette ligne est présente
  final String? postId;// Assurez-vous que cette ligne est présente

  const HomeBottomSheets({super.key, this.initialPage = 'ActualitesPage', this.ownerId, this.NomComplet, this.postId, this.userId, this.docId});

  @override
  State<HomeBottomSheets> createState() => _HomeBottomSheetsState();
}


class _HomeBottomSheetsState extends State<HomeBottomSheets> {
  User? user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;
  late String page;


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
          QuerySnapshot annoncesSnapshot = await profileDoc.reference.collection('annonces').get();
          for (QueryDocumentSnapshot annonceDoc in annoncesSnapshot.docs) {
            var annonceData = annonceDoc.data() as Map<String, dynamic>;
            int notificationsCount = annonceData['UnreadNotificationsCount'] ?? 0;
            int notificationsCountComments = annonceData['UnreadNotificationsCommentsCount'] ?? 0;
            AllNotificationsCount.add(
                {'NotificationsCount': notificationsCount , 'notificationsCountComments' : notificationsCountComments});
          }
          QuerySnapshot CovoiturageSnapshot = await profileDoc.reference.collection('covoiturages').get();
          for (QueryDocumentSnapshot CovoiturageDoc in CovoiturageSnapshot.docs) {
            var CovoiturageData = CovoiturageDoc.data() as Map<String, dynamic>;
            int notificationsCovoiturage = CovoiturageData['NotificationsCovoiturage'] ?? 0;
            AllNotificationsCount.add(
                {'notificationsCovoiturage': notificationsCovoiturage});
          }
          break;
        }
      }
      return AllNotificationsCount;
    });
  }

  Future<void> markAllNotificationsAsRead() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Assurez-vous que l'utilisateur est connecté

    final profileRef = FirebaseFirestore.instance.collection('profiles').doc(user.uid);
    final annoncesSnapshot = await profileRef.collection('annonces').get();

    for (var annonceDoc in annoncesSnapshot.docs) {
      var annonceData = annonceDoc.data();
      List<dynamic> notificationsLikes = List.from(annonceData['notifications'] ?? []);
      List<dynamic> notificationsComments = List.from(annonceData['notificationsComments'] ?? []);

      bool updated = false;

      for (var notification in notificationsLikes) {
        if (notification['read'] == false) {
          notification['read'] = true;
          updated = true;
        }
      }

      for (var notification in notificationsComments) {
        if (notification['read'] == false) {
          notification['read'] = true;
          updated = true;
        }
      }

      if (updated) {
        await annonceDoc.reference.update({
          'notifications': notificationsLikes,
          'notificationsComments': notificationsComments,
        });

        int unreadLikesCount = notificationsLikes.where((notif) => notif['read'] == false).length;
        int unreadCommentsCount = notificationsComments.where((notif) => notif['read'] == false).length;

        await annonceDoc.reference.update({
          'UnreadNotificationsCount': unreadLikesCount,
          'UnreadNotificationsCommentsCount': unreadCommentsCount,
        });
      }
    }
  }

  Future<void> markAllNotificationsCovoiturage() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Assurez-vous que l'utilisateur est connecté

    final profileRef = FirebaseFirestore.instance.collection('profiles').doc(user.uid);
    final messagesSnapshot = await profileRef.collection('covoiturages').get();


    for (var CovoiturageDoc in messagesSnapshot.docs) {
      var CovoiturageData = CovoiturageDoc.data();
      List<dynamic> NotificationCovoiturages = List.from(CovoiturageData['RequestedPersonnes'] ?? []);

      if (NotificationCovoiturages.isNotEmpty) {
        CovoiturageDoc.reference.update({
          'NotificationsCovoiturage' : 0 ,
          'request' : true,
        });
      }else{
        CovoiturageDoc.reference.update({
          'request' : false,
        });
      }
    }
  }


  @override
  void initState() {
    super.initState();
    page = widget.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      extendBody: true,
      bottomNavigationBar: StreamBuilder<List<Map<String, dynamic>>>(
          stream: user != null ? getNotificationsCount(user!.uid) : const Stream.empty(),
          builder: (context, snapshot) {
            int totalLikes = 0;
            int totalComments = 0;
            int totalCoivoiturage = 0;

            if (snapshot.hasData) {
              for (var item in snapshot.data!) {
                totalLikes += (item['NotificationsCount'] as num?)?.toInt() ?? 0;
                totalComments += (item['notificationsCountComments'] as num?)?.toInt() ?? 0;
                totalCoivoiturage += (item['notificationsCovoiturage'] as num?)?.toInt() ?? 0;
              }
            }
            int totalNotifications = totalLikes + totalComments;
            int totalNotificationsCovoiturage = totalCoivoiturage;
            return CustomBottomAppBar(
              notificationCount: totalNotifications,
              notificationCountCovoiturage: totalNotificationsCovoiturage,
              onChange: (index) async {
                if (index == 3) {  // Si l'utilisateur clique sur l'onglet Notifications
                  await markAllNotificationsAsRead();
                }else if (index == 1){
                  await markAllNotificationsCovoiturage();
                }
                setState(() {
                  switch (index) {
                    case 0:
                      page = 'ActualitesPage';
                      break;
                    case 1:
                      page = 'CovoituragePage';
                      break;
                    case 2:
                      page = 'PublierPage';
                      break;
                    case 3:
                      page = 'NotificationsPage';
                      break;
                    case 4:
                      page = 'profile';
                      break;
                  }
                });
              },
            );

          }),
      body: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.blue))
          else
            Builder(
              builder: (context) {
                switch (page) {
                  case 'ActualitesPage':
                    return const HomePageApp();
                  case 'NotificationsPage':
                    return const NotificationsPage();
                  case 'CovoituragePage':
                   return const CovoituragePage();
                  case 'PublierPage':
                    return const PublicationPage();
                  case 'profile':
                    return const ProfilePage();
                  case 'profileRedirection' :
                    return RedirictionPage(ownerId: widget.ownerId ?? '', docId: widget.docId ?? '');
                  case 'message' :
                    return const MessagesPage();
                  case 'CommentsPage' :
                    return CommentsPosts(annonceId: widget.docId ?? '', userId: widget.userId ?? '');
                  case 'SearchingProfile' :
                    return ProfileRedirictionSearch(userId: widget.ownerId ?? '');
                  case 'DiscussionProfile' :
                    return ProfileRedirictionDiscussion(userId: widget.userId?? '', NomComplet: widget.NomComplet ?? '');
                  case 'like' :
                    return LikePage(postId: widget.postId ?? '');
                  case 'LikerRedidirection' :
                    return LikerRedirection(userId: widget.userId ?? '');
                  default:
                    return Container();
                }
              },
            ),
        ],
      ),
    );
  }
}
/*
PandaBar(
                  backgroundColor: Colors.white,
                  buttonColor: Colors.grey[600],
                  buttonSelectedColor: Colors.grey[600],
                  buttonData: [
                    PandaBarButtonData(
                      id: 'ActualitesPage',
                      icon: Icons.home,
                      title: 'home',
                    ),
                    PandaBarButtonData(
                        id: 'NotificationsPage',
                        icon: Icons.notifications,
                        title: 'Notifications ${totalNotifications}',

                    ),
                    PandaBarButtonData(
                        id: 'CovoituragePage',
                        icon: Icons.car_crash,
                        title: 'Covoiturage'
                    ),
                    PandaBarButtonData(
                      id: 'profile',
                      icon: Icons.person,
                      title: 'Profile',
                    ),
                  ],
                  onChange: (selectedPage) {
                    setState(() {
                      page = selectedPage;
                    });
                  },
                  onFabButtonPressed: () {
                    showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return PublicationPage();
                        }
                    );
                  });
*/
