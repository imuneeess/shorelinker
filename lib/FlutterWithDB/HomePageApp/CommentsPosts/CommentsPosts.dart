import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../NavigationBotton/HomeBouttomsSheets.dart';

class CommentsPosts extends StatefulWidget{
  final String annonceId;
  final String userId;

  const CommentsPosts({super.key, required this.annonceId, required this.userId,});
  @override
  State<CommentsPosts> createState() => _CommentsPosts();
}

class _CommentsPosts extends State<CommentsPosts> {
  List<Map<String, dynamic>> comments = [];

  bool isGoogleUser = false;
  late String timeAgo;
  final TextEditingController _commentController = TextEditingController();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool isLoading = false ;
  bool showCommentField = false;


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

  void redirectToProfile(String ownerId) async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => HomeBottomSheets(initialPage: 'profileRedirection',ownerId: ownerId,)// Assurez-vous que vous avez une page ProfilePage qui accepte ownerId
      ),
    );
    setState(() {
      isLoading = false;
    });
  }

  Stream<List<Map<String, dynamic>>> getAnnonceByComments(String docID) {
    return FirebaseFirestore.instance
        .collection('profiles')
        .snapshots()
        .asyncMap((profilesSnapshot) async {
      List<Map<String, dynamic>> allAnnouncements = [];
      for (QueryDocumentSnapshot profileDoc in profilesSnapshot.docs) {
        QuerySnapshot annoncesSnapshot = await profileDoc.reference.collection('annonces').get();
        for (QueryDocumentSnapshot annonceDoc in annoncesSnapshot.docs) {
          if (annonceDoc.id == docID) {
            allAnnouncements.add({
              ...annonceDoc.data() as Map<String, dynamic>,
              'id' : annonceDoc.id ,
            });
            break;
          }
        }
      }
      return allAnnouncements;
    });
  }

  Stream<List<Map<String, dynamic>>> getPersonsCommentsPosts(String annonceId) {
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
          if (annonceDoc.id == annonceId) { // Filtrer par profileId
            var annonceData = annonceDoc.data() as Map<String, dynamic>;
            List<dynamic> Comments = annonceData.containsKey('comments') && annonceData['comments'] is List
                ? List.from(annonceData['comments'] as List<dynamic>)
                : [];
            for (var comment in Comments) {
              // Assurez-vous que chaque like contient les informations nécessaires
              AllPersons.add({
                'userName': comment['userName'],
                'userCommented': comment['userId'],
                'imageProfile': comment['imageProfile'],
                'commentaire' : comment['commentaire'],
                'timestamp': comment['timestamp'],
                'TitreProfil' : comment['TitreProfil'],
              });
            }
            break; // On a trouvé le post, pas besoin de continuer la recherche
          }
        }
      }
      return AllPersons;
    });
  }

  Future<void> updateCommentsCount(String userId, String annonceId) async {
    try {
      DocumentReference annonceRef = FirebaseFirestore.instance
          .collection('profiles')
          .doc(userId)
          .collection('annonces')
          .doc(annonceId);

      DocumentSnapshot annonceSnapshot = await annonceRef.get();
      if (!annonceSnapshot.exists) {
        print('Annonce non trouvée.');
        return;
      }

      var annonceData = annonceSnapshot.data() as Map<String, dynamic>;
      List<dynamic> Comments = annonceData['comments'] ?? [];
      int CommentsCount = Comments.length;

      await annonceRef.update({
        'CommentsCount': CommentsCount,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du compteur de commnentaires: $e');
    }
  }


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

  Future<void> addCommentsNotification(String userId, String annonceId) async {
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
        'typeNotifs' : 'commenté',
        'date': formattedDate, // Ajout du timestamp
        'read': false, // Ajout d'un champ pour indiquer si la notification a été lue
      };

      // Ajoutez le commentaire à la liste des commentaires
      await annoncesRef.update({
        'notificationsComments': FieldValue.arrayUnion([currentUserData]),
      });

      await updateUnreadNotificationsCount(userId, annonceId);

      print("Notification de commentaire a été ajouté avec succées !!");

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
      List<dynamic> notifications = annonceData['notificationsComments'] ?? [];

      int unreadCount = notifications.where((notif) => notif['read'] == false).length;

      await annonceRef.update({
        'UnreadNotificationsCommentsCount': unreadCount,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du compteur de notifications non lues: $e');
    }
  }

  Future<void> handleComments(String annonceId, String userId, String commentaire) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Référence au document de l'annonce
      DocumentReference annonceRef = FirebaseFirestore.instance
          .collection('profiles')
          .doc(userId)
          .collection('annonces')
          .doc(annonceId);

      // Récupération des données de l'annonce
      DocumentSnapshot annonceSnapshot = await annonceRef.get();

      // Vérifiez si le document existe
      if (!annonceSnapshot.exists) {
        print('Annonce non trouvée.');
        return;
      }

      // Préparez le commentaire à ajouter
      final currentUserData = {
        'userId': currentUser.uid,
        'userName': await getUserName(),
        'imageProfile': await getProfileImageUrl(),
        'commentaire': commentaire,
        'TitreProfil' : await getTitreProfil(),
      };

      // Ajoutez le commentaire à la liste des commentaires
      await annonceRef.update({
        'comments': FieldValue.arrayUnion([currentUserData]),
      });
      await addCommentsNotification(userId, annonceId);
      await updateCommentsCount(userId, annonceId);

      print('Commentaire a été ajouté avec succès !!!');
    } catch (e) {
      print('Erreur lors du traitement du commentaire: $e');
    }
  }

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

  @override
  void initState() {
    checkUserType();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Commentaires',
          style: TextStyle(
            fontSize: 22,
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontFamily: "assets/Roboto-Regular.ttf",
          ),
        ),
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
            Expanded(
              child: Container(
                child: ListView(
                  children: [
                    const SizedBox(height: 5),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: getAnnonceByComments(widget.annonceId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Colors.blue));
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Erreur: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('Aucune annonce disponible'));
                        } else {
                          var annonces = snapshot.data!;

                          return Column(
                            children: annonces.map((data) {
                              String imageUrl = data['imageUrl'] ?? "";
                              String ownerId = data['ownerId'];
                              String postId = data['id'];
                              String nameUser = data['nameUser'] ?? '';
                              String userAnnonce = data['userAnnonce'] ?? '';
                              String text = data['text'] ?? '';
                              var timestamp = data['timestamp'];
                              DateTime pastDate = timestamp != null ? (timestamp as Timestamp).toDate() : DateTime.now();
                              DateTime now = DateTime.now();
                              int daysDifference = now.difference(pastDate).inDays;
                              int hoursDifference = now.difference(pastDate).inHours;
                              int minutesDifference = now.difference(pastDate).inMinutes;
                              int secondesDifference = now.difference(pastDate).inSeconds;

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

                              List<dynamic> likes = (data['likes'] as List<dynamic>?) ?? [];
                              bool isLiked = likes.any((like) => like['userId'] == FirebaseAuth.instance.currentUser?.uid);
                              int likesCount = data['likesCount'] is int ? data['likesCount'] as int : 0;
                              int comments = data['CommentsCount'] is int ? data['CommentsCount'] as int : 0;

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
                                                ? Container(
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
                                                      redirectToProfile(ownerId);
                                                    }
                                                  }
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
                                                        fontSize: 15,
                                                      ),
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
                                                  ),
                                                ],
                                              ),
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
                                        const SizedBox(height: 10),
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
                                        const SizedBox(height: 8),
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
                                                              isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
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
                                                  onTap: () {
                                                    print("like is clicked!!!");
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
                                                            child: Icon(
                                                              Icons.mode_comment_outlined,
                                                              color: Colors.grey[600],
                                                              size: 20,
                                                            ),
                                                          ),
                                                          Container(
                                                            margin: const EdgeInsets.only(left: 10, top: 15),
                                                            child: Text(
                                                              "Commenter",
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.w600,
                                                                fontFamily: "assets/Roboto-Regular.ttf",
                                                                color: Colors.grey[700],
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
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
                                        ),
                                        const SizedBox(height: 15),
                                        Container(
                                          height: 1,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF3F2EF),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        StreamBuilder<List<Map<String, dynamic>>>(
                                            stream: getPersonsCommentsPosts(widget.annonceId),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return Container(child: const Text("loading..."));
                                              } else if (snapshot.hasError) {
                                                return Center(child: Text('Erreur: ${snapshot.error}'));
                                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                                return const Center(child: Text("Aucun Commentaire pour ce post"));
                                              }else{
                                                var annonces = snapshot.data!;
                                                return Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: annonces.map((data){
                                                    String userName = data['userName'] ?? 'Inconnu';
                                                    String imageProfile = data['imageProfile'] ?? '';
                                                    String commentaire = data['commentaire'] ?? '';
                                                    String TitreProfil = data['TitreProfil'] ?? '';
                                                    String userId = data['userCommented'] ?? '';
                                                    return Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const SizedBox(height: 3),
                                                        Stack(
                                                          children: [
                                                            Container(
                                                              margin: const EdgeInsets.only(left: 20),
                                                              height: 35,
                                                              width: 35,
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
                                                                          userId: userId),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                color: Colors.grey[100],
                                                                borderRadius: BorderRadius.circular(10)
                                                              ),
                                                              margin: const EdgeInsets.only(left: 67, right: 20), // Ajustez la marge si nécessaire
                                                              padding : const EdgeInsets.only(left : 5,right : 5 ),
                                                              child: Stack(
                                                                children: [
                                                                  Container(
                                                                    margin: const EdgeInsets.only(left: 8, top: 5),
                                                                    child: Text(
                                                                      userName,
                                                                      style: const TextStyle(
                                                                        fontSize: 15,
                                                                        fontFamily: "assets/Roboto-Regular.ttf",
                                                                        fontWeight: FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: const EdgeInsets.only(top: 28, left: 8),
                                                                    child: Text(
                                                                      TitreProfil,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      maxLines: 1,
                                                                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: const EdgeInsets.only(left: 8, top: 55,bottom: 15),
                                                                    child: Text(
                                                                      commentaire,
                                                                      style: const TextStyle(fontSize: 15),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 12),
                                                        Container(
                                                            height: 1,
                                                            decoration: const BoxDecoration(
                                                              color: Color(0xFFF3F2EF),
                                                            )
                                                        ),
                                                        const SizedBox(height: 12),
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
                                ],
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0, 0),
                      blurRadius: 1.0,
                    )
                  ],
                  color: Colors.white
              ),
              margin: const EdgeInsets.only(bottom: 1),
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 5),
                    height: 38,
                    width: 38,
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
                          );
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                        margin:const EdgeInsets.only(left: 5),
                        child: TextFormField(
                          controller: _commentController,
                          cursorColor: Colors.blue,
                          cursorHeight: 25,
                          decoration: InputDecoration(
                            hintText : "Ajouter un commentaire",
                            hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14
                            ),
                            contentPadding: const EdgeInsets.only(left: 15),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(24, 143, 212, 0.25), // Couleur rgba(24, 143, 212, 0.25)
                                width: 2,
                              ),
                            ),
                          ),
                        )
                    ),
                  ),
                  const SizedBox(width: 8), // Correction de la taille de l'espace horizontal
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: MaterialButton(
                      color: Colors.grey[300],
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      onPressed: () async {
                        if(_commentController.text.isNotEmpty) {
                          final newComment = _commentController.text;
                          _commentController.clear(); // Effacer immédiatement pour une meilleure réactivité
                          await handleComments(widget.annonceId, widget.userId, newComment);
                          setState(() {});
                          // Pas besoin de setState() ici car le StreamBuilder se mettra à jour automatiquement
                        }
                      },
                      child: Text('Publier',style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}