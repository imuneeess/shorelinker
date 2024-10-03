
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/NavigationBotton/HomeBouttomsSheets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'Search/CustomSearch.dart';


class HomePageDrawer extends StatefulWidget {
  final VoidCallback? onDrawerOpen; // Fonction pour ouvrir le drawer
  const HomePageDrawer({super.key, this.onDrawerOpen});
  @override
  State<HomePageDrawer> createState() => _CustomAppBar();
}

class _CustomAppBar extends State<HomePageDrawer>  {
  bool isGoogleUser = false;
  User? user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

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
      return await storage.read(key: 'profile_image');
    }
  }

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
          QuerySnapshot annoncesSnapshot = await profileDoc.reference.collection('messages').get();
          for (QueryDocumentSnapshot annonceDoc in annoncesSnapshot.docs) {
            var annonceData = annonceDoc.data() as Map<String, dynamic>;
            int notificationsForUser= annonceData['MessagesCountForUer'] ?? 0;
            AllNotificationsCount.add(
                {'MessagesCountForUer': notificationsForUser});
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
    final messagesSnapshot = await profileRef.collection('messages').get();

    for (var messageDoc in messagesSnapshot.docs) {
      messageDoc.reference.update({
        'MessagesCountForUer': 0,
      });
      }
    }

  @override
  void initState() {
    checkUserType();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: InkWell(
        onTap: () {
          widget.onDrawerOpen?.call();
        },
        child: Icon(Icons.menu , color: Colors.blue[700],),
      ),
      actions: [
        Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 65),
              child: Text("ShoreLinker",style: TextStyle(
                fontSize: 22,
                color: Colors.blue[700],
                fontWeight: FontWeight.w600,
                fontFamily: "assets/Roboto-Regular.ttf",
              ),),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              children: [
                InkWell(
                  onTap: () async {
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const HomeBottomSheets(initialPage: 'message')));
                    await markAllNotificationsAsRead();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 36,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle, // Forme circulaire pour une meilleure esthétique
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          margin: const EdgeInsets.only(left: 3,top: 1),
                          child: Image.asset("assets/messanger.png", color: Colors.grey[700],)
                        ),
                        Positioned(
                          left: 24,
                          bottom: 20,
                          child: StreamBuilder<List<Map<String, dynamic>>>(
                            stream: user != null ? getNotificationsCount(user!.uid) : const Stream.empty(),
                            builder: (context, snapshot) {
                              int totalNotifs = 0;
                              if (snapshot.hasData) {
                                for (var item in snapshot.data!) {
                                  totalNotifs += (item['MessagesCountForUer'] as num?)?.toInt() ?? 0;
                                }
                              }
                              return totalNotifs > 0
                                  ? Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Center(
                                  child: Text(
                                    '$totalNotifs',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                                  : const SizedBox.shrink();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                    height: 37,
                    width: 37,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(100)
                    ),
                    margin: const EdgeInsets.only(left: 55,right: 15,top: 8),
                    child: InkWell(
                      onTap: () {
                        showSearch(context: context, delegate: CustomSearch());
                      },
                      child: const Icon(Icons.search, size: 28),
                    )
                  ),
              ],
            )

          ],
        )

      ],
    );
  }

}