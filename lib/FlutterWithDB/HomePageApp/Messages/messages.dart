import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Messages/Discussion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key });
  @override
  State<MessagesPage> createState() => _MessagesPage();
}

class _MessagesPage extends State<MessagesPage> {


  /*Stream<List<Map<String, dynamic>>> getMessagesByCurrentUser(String userContacted) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.empty(); // Return an empty stream if the user is not logged in
    }
    return FirebaseFirestore.instance
        .collection('profiles')
        .snapshots()
        .asyncMap((profilesSnapshot) async {
      List<Map<String, dynamic>> allMessages = [];

      for (QueryDocumentSnapshot profileDoc in profilesSnapshot.docs) {
        QuerySnapshot messagesSnapshot = await profileDoc.reference.collection('messages').get();
        for (QueryDocumentSnapshot messageDoc in messagesSnapshot.docs) {
          if(messageDoc.id == userContacted){
            var messageData = messageDoc.data() as Map<String, dynamic>;
            List<dynamic> messages = messageData.containsKey('messages') && messageData['messages'] is List
                ? List.from(messageData['messages'] as List<dynamic>)
                : [];
            for (var message in messages) {
              // Ajouter le message à la liste
              allMessages.add({
                'userReceived': message['userReceived'],
                'userSender': message['userSender'],
                'nameSender': message['nameSender'],
                'message': message['message'],
                'imageReceived': message['imageReceived'],
                'nameReceived': message['nameReceived'],
                'imageSender': message['imageSender'],
                'timestamp': message['timestamp'],
                'read': message['read'],
              });
            }
          }
          break;
        }
      }

      // Trier les messages par timestamp du plus récent au plus ancien
      allMessages.sort((a, b) {
        DateTime dateA = DateTime.parse(a['timestamp']);
        DateTime dateB = DateTime.parse(b['timestamp']);
        return dateB.compareTo(dateA); // Inverser l'ordre pour trier du plus récent au plus ancien
      });

      return allMessages;
    });
  }*/

  Stream<List<Map<String, dynamic>>> getAllMessagesForCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty(); // Return an empty stream if the user is not logged in
    }
    return FirebaseFirestore.instance
        .collection('profiles')
        .snapshots()
        .asyncMap((profilesSnapshot) async {
      List<Map<String, dynamic>> allMessages = [];

      for (QueryDocumentSnapshot profileDoc in profilesSnapshot.docs) {
        QuerySnapshot messagesSnapshot = await profileDoc.reference.collection('messages').get();
        for (QueryDocumentSnapshot messageDoc in messagesSnapshot.docs) {
          var messageData = messageDoc.data() as Map<String, dynamic>;
          List<dynamic> messages = messageData.containsKey('messages') && messageData['messages'] is List
              ? List.from(messageData['messages'] as List<dynamic>)
              : [];
          for (var message in messages) {
            if (message['userSender'] == user.uid || message['userReceived'] == user.uid) {
              allMessages.add({
                'userReceived': message['userReceived'],
                'userSender': message['userSender'],
                'nameSender': message['nameSender'],
                'message': message['message'],
                'imageReceived': message['imageReceived'],
                'nameReceived': message['nameReceived'],
                'imageSender': message['imageSender'],
                'timestamp': message['timestamp'],
                'read': message['read'],
              });
            }
          }
        }
      }

      // Trier les messages par timestamp du plus récent au plus ancien
      allMessages.sort((a, b) {
        DateTime dateA = DateTime.parse(a['timestamp']);
        DateTime dateB = DateTime.parse(b['timestamp']);
        return dateB.compareTo(dateA); // Inverser l'ordre pour trier du plus récent au plus ancien
      });

      return allMessages;
    });
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
    }
  }


  Stream<int> getNotificationsCountUser(String userReceived, String userSender) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty(); // Return an empty stream if the user is not logged in
    }

    return FirebaseFirestore.instance
        .collection('profiles')
        .doc(userReceived)
        .collection('messages')
        .doc(userSender)
        .snapshots()
        .map((messageDocSnapshot) {
      if (messageDocSnapshot.exists) {
        var messageData = messageDocSnapshot.data() as Map<String, dynamic>;
        int unreadMessageCount = messageData['UnreadMessagesCount'] ?? 0;
        return unreadMessageCount;
      } else {
        return 0; // No messages found
      }
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
        title: const Text(
          "Messages",
          style: TextStyle(
            fontFamily: "assets/Roboto-Regular.ttf",
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Change la couleur de l'icône de retour ici
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: Image.asset('assets/discussion2.png',color: Colors.white,),
          )
        ],
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: getAllMessagesForCurrentUser(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(color: Colors.blue,));
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Erreur: ${snapshot.error}'));
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(child: Text("Aucun message trouvé"));
                            } else {
                              var allMessages = snapshot.data!;

                              // Regrouper les messages par userReceived ou userSender et garder le plus récent
                              var uniqueContacts = <String, Map<String, dynamic>>{};

                              for (var data in allMessages) {
                                String contactId = data['userSender'] == FirebaseAuth.instance.currentUser!.uid
                                    ? data['userReceived']
                                    : data['userSender'];

                                if (uniqueContacts.containsKey(contactId)) {
                                  DateTime currentTimestamp = DateTime.parse(data['timestamp']);
                                  DateTime existingTimestamp = DateTime.parse(uniqueContacts[contactId]!['timestamp']);
                                  if (currentTimestamp.isAfter(existingTimestamp)) {
                                    uniqueContacts[contactId] = data;
                                  }
                                } else {
                                  uniqueContacts[contactId] = data;
                                }
                              }

                              // Convertir le map en une liste triée par timestamp
                              var sortedContacts = uniqueContacts.values.toList()
                                ..sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));

                              return Column(
                                children: sortedContacts.map((data) {
                                  // Vérifier qui est l'expéditeur du message pour afficher les bonnes informations
                                  bool isCurrentUserSender = data['userSender'] == FirebaseAuth.instance.currentUser!.uid;
                                  String name = isCurrentUserSender ? data['nameReceived'] : data['nameSender'];
                                  String image = isCurrentUserSender ? data['imageReceived'] : data['imageSender'];
                                  String message = data['message'] ?? '';
                                  String contactId = isCurrentUserSender ? data['userReceived'] : data['userSender'];
                                  bool isRead = data['read'] ?? false;

                                  return Column(
                                    children: [
                                      InkWell(
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
                                                    child: const Icon(Icons.chat_bubble,color: Colors.white,size: 13,),
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
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                  isCurrentUserSender
                                                      ? Row(
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets.only(left: 12, top: 30),
                                                        child: const Text(
                                                          "Vous : ",
                                                          style: TextStyle(
                                                            fontFamily: "assets/Roboto-Regular.ttf",
                                                            fontSize: 14,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          margin: const EdgeInsets.only(top: 31, right: 30),
                                                          child: Text(
                                                            message,
                                                            style: const TextStyle(
                                                              fontFamily: "assets/Roboto-Regular.ttf",
                                                              fontSize: 14,
                                                              color: Colors.grey,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                      : Stack(
                                                        children: [
                                                          Container(
                                                            child: StreamBuilder<int>(
                                                              stream: getNotificationsCountUser(FirebaseAuth.instance.currentUser!.uid, contactId ),
                                                              builder: (context, snapshot) {
                                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                                  return const Center(child: CircularProgressIndicator());
                                                                } else if (snapshot.hasError) {
                                                                  return Center(child: Text('Erreur: ${snapshot.error}'));
                                                                } else if (!snapshot.hasData) {
                                                                  return const Center(child: Text('Aucun message non lu'));
                                                                } else {
                                                                  int unreadMessageCount = snapshot.data!;
                                                                  return Stack(
                                                                    children: [
                                                                      unreadMessageCount > 0 ? Stack(
                                                                        children: [
                                                                          Container(
                                                                            margin: const EdgeInsets.only(left: 12,top: 33),
                                                                            decoration: BoxDecoration(
                                                                              color: Colors.red,
                                                                              borderRadius: BorderRadius.circular(12),
                                                                            ),
                                                                            constraints: const BoxConstraints(
                                                                              maxWidth: 16.5,
                                                                              maxHeight: 16.5,
                                                                            ),
                                                                            child: Center(
                                                                              child: Text(
                                                                                '$unreadMessageCount',
                                                                                style: const TextStyle(
                                                                                  color: Colors.white,
                                                                                  fontSize: 10.5,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            margin: const EdgeInsets.only(left: 35, top: 30,right: 30),
                                                                            child: Text(
                                                                              message,
                                                                              style: TextStyle(
                                                                                fontFamily: "assets/Roboto-Regular.ttf",
                                                                                fontSize: 14,
                                                                                color: isRead ? Colors.grey : Colors.black,
                                                                                fontWeight: FontWeight.w500,
                                                                              ),
                                                                              overflow: TextOverflow.ellipsis,
                                                                              maxLines: 1,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                        : Container(
                                                                        margin: const EdgeInsets.only(left: 13, top: 30,right: 30),
                                                                        child: Text(
                                                                          message,
                                                                          style: TextStyle(
                                                                            fontFamily: "assets/Roboto-Regular.ttf",
                                                                            fontSize: 14,
                                                                            color: isRead ? Colors.grey[500] : Colors.black,
                                                                            fontWeight: FontWeight.w400,
                                                                          ),
                                                                          overflow: TextOverflow.ellipsis,
                                                                          maxLines: 1,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                ],
                                              ),
                                            ),

                                          ],
                                        ),
                                        onTap: () async {
                                          print(contactId);
                                          await markAllNotificationsAsRead(FirebaseAuth.instance.currentUser!.uid, contactId);
                                          print('markAllNotificationsAsRead completed'); // Debugging
                                          print('onTap triggered'); // Debugging
                                          await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => DiscussionPage(
                                                NomComplet: name,
                                                ProfileImage: image,
                                                UserId: contactId,
                                              ),
                                            ),
                                          );
                                          setState(() {});
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  );
                                }).toList(),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}
