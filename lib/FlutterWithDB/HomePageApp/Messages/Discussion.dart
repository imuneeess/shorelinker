import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/NavigationBotton/HomeBouttomsSheets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class DiscussionPage extends StatefulWidget {
  final String NomComplet;
  final String ProfileImage;
  final String UserId;//UserId pour le destinataire
  const DiscussionPage({super.key, required this.NomComplet, required this.ProfileImage, required this.UserId, });

  @override
  State<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  bool isGoogleUser = false;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();


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

  Future<void> sendMessage(String userSender, String userReceived, String message) async {
    try {
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      DocumentReference messageDoc = FirebaseFirestore.instance
          .collection('profiles')
          .doc(userReceived)
          .collection('messages')
          .doc(userSender);

      DocumentSnapshot annonceSnapshot = await messageDoc.get();

      final currentUserData = {
        'userReceived': userReceived,
        'userSender': userSender,
        'nameSender': await getUserName(),
        'imageSender': await getProfileImageUrl(),
        'imageReceived': widget.ProfileImage,
        'nameReceived': widget.NomComplet,
        'message': message,
        'timestamp': formattedDate,
        'read': false,
      };

      if (!annonceSnapshot.exists) {
        await messageDoc.set({
          'messages': [currentUserData],
        });
      } else {
        await messageDoc.update({
          'messages': FieldValue.arrayUnion([currentUserData]),
        });
      }

      await updateUnreadNotificationsCount(userSender, userReceived);
      await NotificationsCountUser(userSender, userReceived);

      print('Le message a été ajouté avec succès !!!');
    } catch (e) {
      print('Erreur lors du traitement du message: $e');
    }
  }

  Future<void> updateUnreadNotificationsCount(String userSender, String userReceived) async {
    try {
      DocumentReference annonceRef = FirebaseFirestore.instance
          .collection('profiles')
          .doc(userReceived)
          .collection('messages')
          .doc(userSender);

      DocumentSnapshot annonceSnapshot = await annonceRef.get();
      if (!annonceSnapshot.exists) {
        print('messages non trouvée.');
        return;
      }

      var annonceData = annonceSnapshot.data() as Map<String, dynamic>;
      List<dynamic> messages = annonceData['messages'] ?? [];

      int unreadCount = messages.where((notif) => notif['read'] == false).length;

      await annonceRef.update({
        'UnreadMessagesCount': unreadCount,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du compteur de messages non lues: $e');
    }
  }

  Future<void> NotificationsCountUser(String userSender, String userReceived) async {
    try {
      DocumentReference annonceRef = FirebaseFirestore.instance
          .collection('profiles')
          .doc(userReceived)
          .collection('messages')
          .doc(userSender);

      DocumentSnapshot annonceSnapshot = await annonceRef.get();
      if (!annonceSnapshot.exists) {
        print('messages non trouvée.');
        return;
      }

      await annonceRef.update({
        'MessagesCountForUer': 1,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du compteur de messages non lues: $e');
    }
  }

  /*Stream<List<Map<String, dynamic>>> getDiscussion(String userReceived, String userSend) {
    return FirebaseFirestore.instance
        .collection('profiles')
        .doc(userReceived)
        .collection('messages')
        .doc(userSend)
        .snapshots()
        .map((docSnapshot) {
      if (docSnapshot.exists) {
        var messageData = docSnapshot.data() as Map<String, dynamic>;
        List<dynamic> messages = messageData['messages'] as List<dynamic>;
        return messages.map((message) => {
          'userSender': message['userSender'],
          'userReceived': message['userReceived'],
          'nameSender': message['nameSender'],
          'imageSender': message['imageSender'],
          'message': message['message'],
          'timestamp': message['timestamp'],
          'read': message['read'],
        }).toList();
      } else {
        return [];
      }
    });
  }*/
  Stream<List<Map<String, dynamic>>> getCompleteDiscussion(String userReceived, String userSend) {
    // Récupérer les messages envoyés par userReceived à userSend
    Stream<List<Map<String, dynamic>>> receivedMessagesStream = FirebaseFirestore.instance
        .collection('profiles')
        .doc(userReceived)
        .collection('messages')
        .doc(userSend)
        .snapshots()
        .map((docSnapshot) {
      if (docSnapshot.exists) {
        var messageData = docSnapshot.data() as Map<String, dynamic>;
        List<dynamic> messages = messageData['messages'] as List<dynamic>;
        return messages.map((message) => {
          'userSender': message['userSender'],
          'userReceived': message['userReceived'],
          'nameSender': message['nameSender'],
          'imageSender': message['imageSender'],
          'message': message['message'],
          'timestamp': message['timestamp'],
          'read': message['read'],
        }).toList();
      } else {
        return [];
      }
    });

    // Récupérer les messages envoyés par userSend à userReceived
    Stream<List<Map<String, dynamic>>> sentMessagesStream = FirebaseFirestore.instance
        .collection('profiles')
        .doc(userSend)
        .collection('messages')
        .doc(userReceived)
        .snapshots()
        .map((docSnapshot) {
      if (docSnapshot.exists) {
        var messageData = docSnapshot.data() as Map<String, dynamic>;
        List<dynamic> messages = messageData['messages'] as List<dynamic>;
        return messages.map((message) => {
          'userSender': message['userSender'],
          'userReceived': message['userReceived'],
          'nameSender': message['nameSender'],
          'imageSender': message['imageSender'],
          'message': message['message'],
          'timestamp': message['timestamp'],
          'read': message['read'],
        }).toList();
      } else {
        return [];
      }
    });

    // Fusionner les deux flux de messages
    return Rx.combineLatest2<List<Map<String, dynamic>>, List<Map<String, dynamic>>, List<Map<String, dynamic>>>(
      receivedMessagesStream,
      sentMessagesStream,
          (receivedMessages, sentMessages) {
        // Combiner les messages des deux côtés
        List<Map<String, dynamic>> allMessages = receivedMessages + sentMessages;

        // Trier les messages par timestamp pour avoir une conversation chronologique
        allMessages.sort((a, b) {
          DateTime dateA = DateTime.parse(a['timestamp']);
          DateTime dateB = DateTime.parse(b['timestamp']);
          return dateA.compareTo(dateB);
        });

        return allMessages;
      },
    );
  }

  Future<void> markAllNotificationsAsRead(String userReceived, String userSender) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Assurez-vous que l'utilisateur est connecté

    final profileRef = FirebaseFirestore.instance.collection('profiles').doc(userReceived);
    final messagesSnapshot = await profileRef.collection('messages').get();

    for (var messageDoc in messagesSnapshot.docs) {
      if(messageDoc.id == userSender) {
        var messageData = messageDoc.data();
        List<dynamic> NotificationMessages = List.from(messageData['messages'] ?? []);

        bool updated = false;

        for (var notificationMsg in NotificationMessages) {
          if (notificationMsg['read'] == false) {
            notificationMsg['read'] = true;
            updated = true;
          }
        }

        if (updated) {
          await messageDoc.reference.update({
            'messages': NotificationMessages,
          });

          int unreadMessageCount = NotificationMessages.where((notif) => notif['read'] == false).length;


          await messageDoc.reference.update({
            'UnreadMessagesCount': unreadMessageCount,

          });
        }
      }
      break;
    }
  }



  @override
  void initState() {
    checkUserType();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 55, top: 7),
                  height : 43,
                  width: 43,
                  child: InkWell(
                    child: widget.ProfileImage.startsWith('http')
                        ? CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(widget.ProfileImage),
                    )
                        : CircleAvatar(
                      radius: 24,
                      backgroundImage: FileImage(File(widget.ProfileImage)),
                      child: widget.ProfileImage.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 110,top: 9),
                  child: Text(widget.NomComplet,style: const TextStyle(
                    fontFamily: "assets/Roboto-Regular.ttf",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 110,top: 31),
                  child: const Text("Usager Fes-Shore",style: TextStyle(
                    fontFamily: "assets/Roboto-Regular.ttf",
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey
                  ),),
                )
              ],
            ),
          ),
        ]
      ),
      body: Container(
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 3),
                height: 1,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F2EF),
                )
            ),
            Expanded(
              child: ListView(
                controller: _scrollController, // Ajoutez le ScrollController ici
                children: [
                  Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 25),
                            height: 90,
                            width: 90,
                            child: InkWell(
                              child: widget.ProfileImage != '' && widget.ProfileImage.startsWith('http')
                                  ? CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(widget.ProfileImage),
                              )
                                  : widget.ProfileImage != ''
                                  ? CircleAvatar(
                                radius: 24,
                                backgroundImage: FileImage(File(widget.ProfileImage)),
                                child: widget.ProfileImage.isEmpty ? const Icon(Icons.person) : null,
                              )
                                  : const Icon(Icons.person),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 120),
                            child: Text(
                              widget.NomComplet,
                              style: const TextStyle(
                                fontFamily: "assets/Roboto-Regular.ttf",
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Voir le profil
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 160),
                            child: MaterialButton(
                              elevation: 0.0,
                              onPressed: () {
                                if (widget.UserId != '') {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => HomeBottomSheets(
                                        initialPage: 'DiscussionProfile',
                                        userId: widget.UserId,
                                        NomComplet: widget.NomComplet,
                                      ),
                                    ),
                                  );
                                }
                              },
                              shape: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Colors.grey[100],
                              textColor: Colors.black,
                              child: const Text('Voir le profil'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: getCompleteDiscussion(widget.UserId, FirebaseAuth.instance.currentUser!.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Erreur: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text('Aucune discussion avec ${widget.NomComplet}'));
                          } else {
                            var firestoreMessages = snapshot.data!;

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scrollController.hasClients) {
                                _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                              }
                            });

                            return Column(
                              children: List.generate(firestoreMessages.length, (index) {
                                var messageData = firestoreMessages[index];
                                String message = messageData['message'] ?? '';
                                String timeMessages = messageData['timestamp'] ?? '';
                                bool isCurrentUser = messageData['userSender'] == FirebaseAuth.instance.currentUser!.uid;

                                // Convertir le timestamp en DateTime
                                DateTime messageTime = DateTime.parse(timeMessages);
                                String formattedTime = DateFormat('HH:mm').format(messageTime);

                                // Vérifier si le message précédent est du même utilisateur
                                bool showTimestamp = false;
                                if (index > 0) {
                                  var previousMessageData = firestoreMessages[index - 1];
                                  String previousTimeMessages = previousMessageData['timestamp'] ?? '';
                                  bool isPreviousCurrentUser = previousMessageData['userSender'] == FirebaseAuth.instance.currentUser!.uid;
                                  DateTime previousMessageTime = DateTime.parse(previousTimeMessages);

                                  // Afficher le timestamp si la différence est suffisante ou si l'utilisateur a changé
                                  Duration difference = messageTime.difference(previousMessageTime);
                                  if (difference.inHours >= 12 || isPreviousCurrentUser != isCurrentUser) {
                                    showTimestamp = true;
                                  }
                                } else {
                                  showTimestamp = true; // Afficher le timestamp pour le premier message
                                }

                                return Column(
                                  children: [
                                    if (showTimestamp)
                                      Container(
                                        margin: const EdgeInsets.only(top: 15 , bottom: 10),
                                        child: Text(
                                          formattedTime,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    Align(
                                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                                      child: Container(
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7), // Limite la largeur du message
                                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isCurrentUser ? Colors.blue : Colors.grey[100],
                                          borderRadius: isCurrentUser ?
                                          const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            bottomLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                          ) : const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                          ),
                                        ),
                                        child: Text(
                                          message,
                                          style: TextStyle(
                                            color: isCurrentUser ? Colors.white : Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "assets/Roboto-Regular.ttf",
                                          ),
                                          softWrap: true, // Assure le retour à la ligne
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      cursorColor: Colors.blue,
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Écrire un message...',
                        hintStyle: const TextStyle(
                            fontSize: 14
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(24, 143, 212, 0.25), // Couleur rgba(24, 143, 212, 0.25)
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.blue,
                    onPressed: () async{
                      if (_messageController.text.isNotEmpty) {
                        await sendMessage(FirebaseAuth.instance.currentUser!.uid, widget.UserId, _messageController.text);
                        _messageController.clear();
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      }
                      print("bonjour ${widget.NomComplet}");
                    },
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
