import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courseflutter/FlutterWithDB/Authentification/GoogleAuth/GoogleOut.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/CommentsPosts/CommentsPosts.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/CustomDrawer/CustomDrawer.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/HomepageDrawer.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/NavigationBotton/HomeBouttomsSheets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';


class HomePageApp extends StatefulWidget {

  const HomePageApp({super.key});

  @override
  State<HomePageApp> createState() => _HomePageApp();
}

class _HomePageApp extends State<HomePageApp> {

  Map<String, bool> likedPosts = {}; // Stocke les likes localement
  Map<String, dynamic> postStates = {}; // Stocke l'état local des posts

  bool isGoogleUser = false;
  String userEmail = '';
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool isLoading = false;
  bool isProfilePageVisible = false;
  GoogleOut googleOut = GoogleOut();
  //Timer? _timer;
  final GlobalKey<ScaffoldState> _homeScaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> profilePageKey = GlobalKey<ScaffoldState>();
  List<QueryDocumentSnapshot> annonces = [];

  Future<String> getTextAnnonce(String annonceId, String userId) async {
    try {
      DocumentSnapshot annonceSnapshot = await FirebaseFirestore.instance
          .collection("profiles")
          .doc(userId)
          .collection("annonces")
          .doc(annonceId)
          .get();

      if (annonceSnapshot.exists) {
        var annonceData = annonceSnapshot.data() as Map<String, dynamic>;
        return annonceData['text'] ?? 'Texte non disponible';
      }
      return 'Texte non disponible';
    } catch (e) {
      print("Erreur lors de la récupération du texte de l'annonce: $e");
      return 'Erreur lors de la récupération du texte';
    }
  }


  Future<void> updateLikesCount(String profileId, String annonceId) async {
    try {
      DocumentReference annonceRef = FirebaseFirestore.instance
          .collection('profiles')
          .doc(profileId)
          .collection('annonces')
          .doc(annonceId);

      DocumentSnapshot annonceSnapshot = await annonceRef.get();
      if (!annonceSnapshot.exists) {
        print('Annonce non trouvée.');
        return;
      }

      var annonceData = annonceSnapshot.data() as Map<String, dynamic>;
      List<dynamic> likes = annonceData['likes'] ?? [];
      int likesCount = likes.length;

      await annonceRef.update({
        'likesCount': likesCount,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du compteur de likes: $e');
    }
  }


  Future<void> addLikeNotification(String userId, String annonceId) async {
    try {
      DocumentReference annoncesRef = FirebaseFirestore.instance
          .collection('profiles')
          .doc(userId)
          .collection('annonces')
          .doc(annonceId) ;// Utilisation de l'ID du post pour identifier la notification

      DocumentSnapshot annonceSnapshot = await annoncesRef.get();

      if (!annonceSnapshot.exists) {
        print('Annonce non trouvée.');
        return;
      }

      // Générer l'heure actuelle sous forme de chaîne formatée
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());


      // Préparez le commentaire à ajouter
      final currentUserData = {
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'annonceId': annonceId,
        'userName': await getUserName(),
        'imageProfile': await getProfileImageUrl(),
        'ContexteAnnonce' : await getTextAnnonce(annonceId, userId),
        'typeNotifs' : 'aimé',
        'date': formattedDate, // Ajout du timestamp
        'read': false, // Ajout d'un champ pour indiquer si la notification a été lue
      };

      // Ajoutez le commentaire à la liste des commentaires
      await annoncesRef.update({
        'notifications': FieldValue.arrayUnion([currentUserData]),
      });

      await updateUnreadNotificationsCount(userId, annonceId);

      print("Notification a été ajouté avec succées !!");

    } catch (e) {
      print('Erreur lors de l\'ajout de la notification: $e');
    }
  }

  Future<void> updateUnreadNotificationsCount(String profileId, String annonceId) async {
    try {
      DocumentReference annonceRef = FirebaseFirestore.instance
          .collection('profiles')
          .doc(profileId)
          .collection('annonces')
          .doc(annonceId);

      DocumentSnapshot annonceSnapshot = await annonceRef.get();
      if (!annonceSnapshot.exists) {
        print('Annonce non trouvée.');
        return;
      }

      var annonceData = annonceSnapshot.data() as Map<String, dynamic>;
      List<dynamic> notifications = annonceData['notifications'] ?? [];

      int unreadCount = notifications.where((notif) => notif['read'] == false).length;

      await annonceRef.update({
        'UnreadNotificationsCount': unreadCount,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du compteur de notifications non lues: $e');
    }
  }


  // ca marche mais en commentaire
  Future<void> handleLike(String profileId, String annonceId) async {
    // Mise à jour optimiste de l'état local
    setState(() {
      if (!postStates.containsKey(annonceId)) {
        postStates[annonceId] = {'isLiked': false, 'likesCount': 0};
      }
      postStates[annonceId]['isLiked'] = !postStates[annonceId]['isLiked'];
      postStates[annonceId]['likesCount'] += postStates[annonceId]['isLiked'] ? 1 : -1;
    });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      DocumentReference annonceRef = FirebaseFirestore.instance
          .collection('profiles')
          .doc(profileId)
          .collection('annonces')
          .doc(annonceId);

      DocumentSnapshot annonceSnapshot = await annonceRef.get();
      if (!annonceSnapshot.exists) {
        print('Annonce non trouvée.');
        return;
      }

      var annonceData = annonceSnapshot.data() as Map<String, dynamic>;
      List<dynamic> likes = annonceData.containsKey('likes') && annonceData['likes'] is List
          ? List.from(annonceData['likes'] as List<dynamic>)
          : [];

      final currentUserData = {
        'userId': currentUser.uid,
        'userName': await getUserName(),
        'imageProfile': await getProfileImageUrl(),
        'userTitreProfil' : await getTitreProfil(),
      };

      if (likes.any((like) => like['userId'] == currentUser.uid)) {
        await annonceRef.update({
          'likes': FieldValue.arrayRemove([currentUserData]),
        });
        await removeNotification(profileId, annonceId, currentUser.uid, 'aimé');
      } else {
        await annonceRef.update({
          'likes': FieldValue.arrayUnion([currentUserData]),
        });
        await addLikeNotification(profileId, annonceId);
      }

      // Mise à jour du compteur de likes dans Firestore
      await updateLikesCount(profileId, annonceId);

      // Récupération du nombre réel de likes après la mise à jour
      DocumentSnapshot updatedSnapshot = await annonceRef.get();
      var updatedData = updatedSnapshot.data() as Map<String, dynamic>;
      int realLikesCount = updatedData['likesCount'] ?? 0;

      // Mise à jour de l'état local avec le nombre réel de likes
      setState(() {
        postStates[annonceId]['likesCount'] = realLikesCount;
      });
    } catch (e) {
      print('Erreur lors du traitement du like: $e');
      // En cas d'erreur, on revient à l'état précédent
      /*setState(() {
        postStates[annonceId]['isLiked'] = !postStates[annonceId]['isLiked'];
        postStates[annonceId]['likesCount'] += postStates[annonceId]['isLiked'] ? 1 : -1;
      });*/
    }
  }


  /*Future<void> handleLike(String profileId, String annonceId) async {
    setState(() {
      // Mise à jour immédiate de l'état local
      likedPosts[annonceId] = !(likedPosts[annonceId] ?? false);
    });
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;
      //annonces
      DocumentReference annonceRef = FirebaseFirestore.instance
          .collection('profiles')
          .doc(profileId)
          .collection('annonces')
          .doc(annonceId);

      DocumentSnapshot annonceSnapshot = await annonceRef.get();
      if (!annonceSnapshot.exists) {
        print('Annonce non trouvée.');
        return;
      }

      var annonceData = annonceSnapshot.data() as Map<String, dynamic>;
      List<dynamic> likes = annonceData.containsKey('likes') && annonceData['likes'] is List
          ? List.from(annonceData['likes'] as List<dynamic>)
          : [];

      final currentUserData = {
        'userId': currentUser.uid,
        'userName': await getUserName(),
        'imageProfile': await getProfileImageUrl(),
        'userTitreProfil' : await getTitreProfil(),
      };

      if (likes.any((like) => like['userId'] == currentUser.uid)) {
        await annonceRef.update({
          'likes': FieldValue.arrayRemove([currentUserData]),
        });
        await removeNotification(profileId, annonceId, currentUser.uid, 'aimé');
      } else {
        await annonceRef.update({
          'likes': FieldValue.arrayUnion([currentUserData]),
        });
        await addLikeNotification(profileId, annonceId);
      }
      await updateLikesCount(profileId, annonceId);
      // Met à jour le compteur de likes après modification
    } catch (e) {
      print('Erreur lors du traitement du like: $e');
    }
  }*/



  Future<void> removeNotification(String profileId, String annonceId, String userId, String typeNotifs) async {
    try {
      DocumentReference annonceRef = FirebaseFirestore.instance
          .collection('profiles')
          .doc(profileId)
          .collection('annonces')
          .doc(annonceId);

      DocumentSnapshot annonceSnapshot = await annonceRef.get();
      if (!annonceSnapshot.exists) return;

      var annonceData = annonceSnapshot.data() as Map<String, dynamic>;
      List<dynamic> notifications = List.from(annonceData['notifications'] ?? []);

      notifications.removeWhere((notif) =>
      notif['userId'] == userId && notif['typeNotifs'] == typeNotifs);

      await annonceRef.update({
        'notifications': notifications,
      });

      await updateUnreadNotificationsCount(profileId, annonceId);
    } catch (e) {
      print('Erreur lors de la suppression de la notification: $e');
    }
  }

  Future<void> getAnnonce() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('profiles')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('annonces')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      annonces = querySnapshot.docs;
    });
  }

  Stream<List<QueryDocumentSnapshot>> getAnnonceStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.error('Utilisateur non connecté');
    }
    return FirebaseFirestore.instance
        .collection('profiles')
        .doc(user.uid)
        .collection('annonces')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }


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
        return userData['NomComplet'] ?? 'User';
      }
      return 'User';
    } catch (e) {
      print("Erreur lors de la récupération du nom: $e");
      return 'Nom non disponible';
    }
  }

  Future<String> getTitreProfil() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("profiles")
          .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        return userData['TitreProfil'] ?? 'User';
      }
      return 'User';
    } catch (e) {
      print("Erreur lors de la récupération du nom: $e");
      return 'Nom non disponible';
    }
  }

  void ProfileRediriction() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const HomeBottomSheets(initialPage: 'profile')));
    setState(() {
      isLoading = false;
    });
  }

  Stream<List<Map<String, dynamic>>> getAllAnnouncements() {
    return FirebaseFirestore.instance
        .collection('profiles')
        .snapshots()
        .asyncMap((profilesSnapshot) async {
      List<Map<String, dynamic>> allAnnouncements = [];
      for (QueryDocumentSnapshot profileDoc in profilesSnapshot.docs) {
        QuerySnapshot annoncesSnapshot = await profileDoc.reference.collection('annonces').get();
        for (QueryDocumentSnapshot annonceDoc in annoncesSnapshot.docs) {
          allAnnouncements.add({
            ...annonceDoc.data() as Map<String, dynamic>,
            'id': annonceDoc.id, // Inclure l'ID du document
          });
        }
      }
      allAnnouncements.sort((a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));
      return allAnnouncements;
    });
  }



  Future<void> _deletePost(BuildContext context, String postId) async {
    try {
      DocumentSnapshot postDoc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('annonces')
          .doc(postId)
          .get();
      if (!postDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annonce non trouvée')),
        );
        return;
      }
      //important
      String ownerId = postDoc.get('ownerId');
      if (ownerId != FirebaseAuth.instance.currentUser!.uid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous n\'êtes pas autorisé à supprimer cette annonce')),
        );
        return;
      }
      final bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: const OutlineInputBorder(
                borderRadius: BorderRadius.zero
            ),
            content: const Text('Voulez-vous vraiment supprimer '
                'définitivement cette activité de ShoreLinker ?'),
            actions: <Widget>[
              TextButton(
                child: Text('Annuler',style: TextStyle(color: Colors.grey[800],fontWeight: FontWeight.w600),),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              const SizedBox(width: 15),
              TextButton(
                child: Text('Supprimer' , style: TextStyle(color: Colors.grey[800],fontWeight: FontWeight.w600),),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      // Si l'utilisateur confirme la suppression
      if (confirmDelete == true) {
        // Supprimer le document
        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('annonces')
            .doc(postId)
            .delete();

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
                    'Le post a été supprimé avec succès!',
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
      }
    } catch (e) {
      print('Erreur lors de la suppression du post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression du post')),
      );
    }
  }

  void redirectToProfile(String ownerId,String postId) async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HomeBottomSheets(initialPage: 'profileRedirection',ownerId: ownerId, docId: postId,)// Assurez-vous que vous avez une page ProfilePage qui accepte ownerId
      ),
    );
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getEmailUser();
    checkUserType();
    getUserName();
    getTitreProfil();
    //getAnnonce();
    super.initState();
    //_timer = Timer.periodic(Duration(minutes: 1), (Timer t) => setState(() {}));
  }
  @override
  void dispose() {
    //_timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.blue))
        : Scaffold(
      key: _homeScaffoldKey,
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
          isGoogleUser: isGoogleUser,
          userEmail: userEmail,
          getProfileImageUrl: getProfileImageUrl,
          onHomePressed: () {
            print("Home button pressed");
            Navigator.of(context).pop(); // Ferme le drawer
          },
          onProfilePressed : ProfileRediriction,
          onAboutUsPressed: () {},
          onSignOutPressed: () {
            _handleSignOut();
          },
          getUserName: getUserName,
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              HomePageDrawer(
                onDrawerOpen: () {
                  _homeScaffoldKey.currentState?.openDrawer(); // Ouvre le drawer
                },
              ),
              Container(
                  height: 1,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F2EF),
                  )
              ),
              Container(
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 10 , top: 10),
                      height: 45,
                      width: 45,
                      child: FutureBuilder<String?>(
                        future: getProfileImageUrl(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(child: Text('Error loading image'));
                          } else if (!snapshot.hasData || snapshot.data == null) {
                            return const Center(child: Text('No image available'));
                          } else {
                            return ClipOval(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: (){
                                    if (!mounted) return;
                                    setState(() {isLoading=true;});
                                    try{
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                                          const HomeBottomSheets(initialPage: 'profile')));
                                    }catch(e){
                                      print('Error navigated to the profile page');
                                    }
                                    finally {
                                      if (!mounted) return;
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  },
                                  child: isGoogleUser
                                      ? Image.network(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  )
                                      : Image.file(
                                    File(snapshot.data!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 10,right: 10),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.grey)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: const Text("What's on your mind?", style: TextStyle(
                                fontSize: 15,
                              ),),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: InkWell(
                                onTap: () async{
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await Future.delayed(const Duration(seconds: 2));
                                  Navigator.of(context).pushNamed("/Annonce");
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                child: Icon(Icons.camera_alt, color: Colors.grey[600],),
                              )
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F2EF),
                  )
              ),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: getAllAnnouncements(), // Appelle la méthode pour récupérer toutes les annonces
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            'Chargement en cours...',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.blue[900]),
                          ),
                          const SizedBox(height: 10),
                          const LinearProgressIndicator(color: Colors.blue),
                        ],
                      ),
                    );
                  } else {
                    var annonces = snapshot.data!;


                    // Initialisation des `postStates` pour chaque annonce
                    for (var annonce in annonces) {
                      String annonceId = annonce['id'];

                      // Initialisation de l'état local si ce n'est pas déjà fait
                      if (!postStates.containsKey(annonceId)) {
                        bool isLiked = annonce['likes']?.any((like) => like['userId'] == FirebaseAuth.instance.currentUser?.uid) ?? false;
                        int likesCount = annonce['likesCount'] ?? 0;

                        postStates[annonceId] = {
                          'isLiked': isLiked,
                          'likesCount': likesCount,
                        };
                      }
                    }

                    return Column(
                      children: annonces.map((data) {
                        String postId = data['id']; // Utilisez l'ID du document pour la suppression
                        String ownerId = data['ownerId'];
                        String imageUrl = data['imageUrl'] ?? '';
                        String nameUser = data['nameUser'] ?? '' ;
                        String userAnnonce = data['userAnnonce'] ?? '';
                        String text = data['text'] ?? '';
                        var timestamp = data['timestamp'];
                        DateTime pastDate = timestamp != null ? (timestamp as Timestamp).toDate() : DateTime.now();
                        DateTime now = DateTime.now();
                        int daysDifference = now.difference(pastDate).inDays;
                        int hoursDifference = now.difference(pastDate).inHours;
                        int minutesDifference = now.difference(pastDate).inMinutes;
                        int secondesDifference = now.difference(pastDate).inSeconds;
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

                        // Assurez-vous que 'likes' est bien une liste avant de faire la vérification
                        List<dynamic> likes = (data['likes'] as List<dynamic>?) ?? [];
                        //bool isLiked = likedPosts[postId] ?? likes.any((like) => like['userId'] == FirebaseAuth.instance.currentUser?.uid);
                        //int likesCount = data['likesCount'] is int ? data['likesCount'] as int : 0;
                        //int comments = data['CommentsCount'] is int ? data['CommentsCount'] as int : 0;

                        // ca marche
                       // bool isLiked = postStates[postId]?['isLiked'] ?? likes.any((like) => like['userId'] == FirebaseAuth.instance.currentUser?.uid);
                        //int likesCount = postStates[postId]?['likesCount'] ?? (data['likesCount'] as int? ?? 0);

                        bool isLiked = postStates[postId]?['isLiked'] ?? likes.any((like) => like['userId'] == FirebaseAuth.instance.currentUser?.uid);
                        int likesCount = postStates[postId]?['likesCount'] ?? (likes.length ?? 0);
                        int comments = postStates[postId]?['commentsCount'] ?? (data['CommentsCount'] as int? ?? 0);



                        return Column(
                          children: [
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      userAnnonce.isNotEmpty
                                          ?
                                      Container(
                                          margin: const EdgeInsets.only(left: 17,top: 8),
                                          height: 47,
                                          width : 47,
                                          child: InkWell(
                                            child: userAnnonce.startsWith('http')
                                                ? CircleAvatar(
                                              backgroundImage: NetworkImage(userAnnonce),
                                            )
                                                : CircleAvatar(
                                              backgroundImage: FileImage(File(userAnnonce)),
                                              child: userAnnonce.isEmpty
                                                  ? const Icon(Icons.person)
                                                  : null,
                                            ),
                                            onTap: () {
                                              if (ownerId == FirebaseAuth.instance.currentUser!.uid) {
                                                ProfileRediriction();
                                              }else{
                                                redirectToProfile(ownerId,postId);
                                              }
                                            },
                                          ))
                                          : Container(),
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(left: 10, top: 10),
                                              child: Text(
                                                nameUser,
                                                style: const TextStyle(
                                                    fontFamily: "assets/Roboto-Regular.ttf",
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(top: 31, left: 10),
                                              child: const Text(
                                                "Usager ShoreLinker",
                                                style: TextStyle(fontSize: 11.5, color: Colors.grey),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(top: 47, left: 10),
                                              child: Text(
                                                timeAgo,
                                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(top: 10, right: 5),
                                                  child: PopupMenuButton<String>(
                                                    color: Colors.white,
                                                    onSelected: (String result) async {
                                                      if (result == 'delete') {
                                                        await _deletePost(context, postId); // Passez l'ID du post ici
                                                        print('Supprimer le post');
                                                      } else if (result == 'disable_comments') {
                                                        //Traitement de désactiver
                                                        print('Désactiver les commentaires');
                                                      } else if (result == 'report') {
                                                        //Traitement de signaler
                                                        print('Signaler le post');
                                                        // Ajouter la logique pour signaler le post ici
                                                      }
                                                    },
                                                    itemBuilder: (BuildContext context) {
                                                      List<PopupMenuEntry<String>> items = [];
                                                      if (ownerId == FirebaseAuth.instance.currentUser!.uid) {
                                                        items.add(
                                                          const PopupMenuItem<String>(
                                                            value: 'delete',
                                                            child: ListTile(
                                                              leading: Icon(Icons.delete, color: Colors.grey),
                                                              title: Text('Supprimer le post'),
                                                            ),
                                                          ),
                                                        );
                                                        items.add(
                                                          const PopupMenuItem<String>(
                                                            value: 'disable_comments',
                                                            child: ListTile(
                                                              leading: Icon(Icons.comments_disabled, color: Colors.grey),
                                                              title: Text('Désactiver les commentaires sur ce post'),
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        // Utilisateur n'est pas le propriétaire du post
                                                        items.add(
                                                           PopupMenuItem<String>(
                                                            value: 'report',
                                                            child: ListTile(
                                                              leading: Icon(Icons.flag, color: Colors.grey[800]),
                                                              title: const Text('Signaler ce post'),
                                                            ),
                                                          ),
                                                        );
                                                      }

                                                      return items;
                                                    },
                                                    child: const Icon(Icons.more_vert),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 12),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
                                      child: Text(
                                        text,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                  imageUrl.isNotEmpty
                                      ? SizedBox(
                                    width: double.infinity,
                                    child: ClipRRect(
                                      child: Image.network(
                                        imageUrl,
                                        height: 350,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                      : Container(),
                                  const SizedBox(height: 7),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(left: 30),
                                        child: Stack(
                                          children: [
                                            likesCount == 0 ? Container(margin: const EdgeInsets.only(left: 30),) :
                                            Stack(
                                              children: [
                                                Container(
                                                    margin: const EdgeInsets.only(top: 3),
                                                    child: const Icon(Icons.thumb_up, color: Colors.blue,size: 15,)),
                                                InkWell(
                                                  child: Container(
                                                    margin: const EdgeInsets.only(left: 22,top: 2),
                                                    child: Text('$likesCount',style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.grey[700],
                                                      fontSize: 12,
                                                    ),),
                                                  ),
                                                  onTap: () {
                                                    Navigator.of(context).push(MaterialPageRoute(
                                                        builder: (context) => HomeBottomSheets(initialPage: 'like' , postId: postId,)));
                                                  },
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 160),
                                      Container(
                                        child: Stack(
                                          children: [
                                            comments == 0 ? Container() :
                                            InkWell(
                                              child: Container(
                                                margin: const EdgeInsets.only(left: 80, top: 2),
                                                child: Text(
                                                  '$comments commentaires',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey[700],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 7),
                                  Container(
                                    height: 1,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF3F2EF),
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: InkWell(
                                            child: Stack(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets.only(left: 25, top: 15),
                                                      child: Icon(
                                                        isLiked
                                                            ? Icons.thumb_up_alt
                                                            : Icons.thumb_up_alt_outlined,
                                                        color: isLiked ? Colors.blue : Colors.grey[600],
                                                        size: 20,
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: const EdgeInsets.only(left: 10, top: 15),
                                                      child: Text(
                                                        isLiked ? "J'aime" : "J'aime",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          color: isLiked ? Colors.blue : Colors.grey[700],
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                              onTap: () async {
                                                await handleLike(ownerId, postId); // Passez les ID corrects ici
                                                //setState(() {});
                                              }
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(left: 20),
                                          child: InkWell(
                                            child: Stack(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets.only(left: 25, top: 15),
                                                      child: Icon(Icons.mode_comment_outlined,color: Colors.grey[600],size: 20,),
                                                    ),
                                                    Container(
                                                        margin: const EdgeInsets.only(left: 10, top: 15),
                                                        child: Text("Commenter" , style: TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                            fontFamily: "assets/Roboto-Regular.ttf",
                                                            color: Colors.grey[700],
                                                            fontSize: 14
                                                        ),)
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) => CommentsPosts(annonceId: postId, userId: ownerId)
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(left: 20),
                                          child: InkWell(
                                            child: Stack(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets.only(left: 25, top: 15),
                                                      child: Icon(Icons.share_outlined,color: Colors.grey[600],size: 20,),
                                                    ),
                                                    Container(
                                                        margin: const EdgeInsets.only(left: 10, top: 15),
                                                        child: Text("partager" , style: TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                            fontFamily: "assets/Roboto-Regular.ttf",
                                                            color: Colors.grey[700],
                                                            fontSize: 14
                                                        ),)
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                            onTap: () {
                                              print('Partage is clicked!!!');
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            Container(
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3F2EF),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  }
                },
              )

            ],
          ),
        ],

      ),
    );
  }
}
/*
if (isProfilePageVisible)
            Positioned.fill(
              child: GestureDetector(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: ProfilePage(),
                  ),
                ),
              ),
            ),
            Color(0xFFF3F2EF)
 */


