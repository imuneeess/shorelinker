import 'dart:io';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Annonces/AnnonceTextForm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';// Import pour le package audio

class PublicationPage extends StatefulWidget{
  const PublicationPage({super.key});
  @override
  State<PublicationPage> createState() => _MyApp();
}

class _MyApp extends State<PublicationPage> {
  bool isGoogleUser = false ;
  TextEditingController AnnonceController = TextEditingController();
  CollectionReference profiles = FirebaseFirestore.instance.collection('profiles');
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  Map<String, dynamic>? userData;
  bool isLoading = false ;
  File? file;
  XFile? imageGallery;
  String? imageUrl;
  String userEmail = '';
  final AudioPlayer _audioPlayer = AudioPlayer();

  /*Future<void> playSound() async {
    await _audioPlayer.setAsset('assets/sounds/soungofShareAnnonce.mp3');
    _audioPlayer.play();
  }*/

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    imageGallery = await picker.pickImage(source: ImageSource.gallery);
    if (imageGallery != null) {
      setState(() {
        file = File(imageGallery!.path);
      });
    }
  }

  Future<String> getEmailUser() async {
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
      return userEmail;
    } catch (e) {
      print(e);
      rethrow;
    }
  }


  Future<void> uploadAnnouncement() async {
    if (AnnonceController.text.isEmpty) {
      print('Annonce text is empty');
      return;
    }

    String? imageUrl;

    if (file != null) {
      final imagename = basename(file!.path);
      final refStorage = FirebaseStorage.instance.ref("Annonces_images/$imagename");

      try {
        await refStorage.putFile(file!);
        imageUrl = await refStorage.getDownloadURL();
        print('Image URL: $imageUrl');
      } catch (e) {
        print('Erreur lors du téléchargement de l\'image: $e');
        imageUrl = null;
      }
    }

    try {
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('annonces')
          .add({
        'text': AnnonceController.text,
        'imageUrl': imageUrl,
        'nameUser': await getUserName(),
        'userAnnonce': await getProfileImageUrl(),
        'timestamp': FieldValue.serverTimestamp(),
        'ownerId': FirebaseAuth.instance.currentUser!.uid,
      });
      print('Annonce ajoutée avec succès');
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'annonce: $e');
    }

    //playSound();

    // Réinitialisez les champs si le widget est encore monté
    if (mounted) {
      setState(() {
        file = null;
        imageGallery = null;
      });
      if (AnnonceController.hasListeners) {
        AnnonceController.clear();
      }
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
        title: const Text("Partager une annonce",style: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: "assets/Roboto-Regular.ttf",
            fontSize: 17
        ),),
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: MaterialButton(
                elevation: 0,
                textColor: Colors.grey[500],
                color: Colors.grey[200],
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none
                ),
                onPressed: () async{
                  setState(() {
                    isLoading = true;
                  });
                  await Future.delayed(const Duration(seconds: 2));
                  uploadAnnouncement();
                  Navigator.of(context).pushNamedAndRemoveUntil("/homepage", (route) => false);
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
                              'Une nouvelle annonce a été publié!',
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
                  setState(() {
                    isLoading = false;
                  });
                } ,
                child: Text("Publier",style: TextStyle(fontFamily: "assets/Roboto-Regular.ttf",color: Colors.grey[700]))),
          )
        ],
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator(color: Colors.blue)) : Padding(
        padding: const EdgeInsets.all(0.0),
        child: ListView(
          shrinkWrap: true,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                height: 2,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F2EF),
                )
            ),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 20 , top: 20),
                  height: 50,
                  width: 50,
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
                        return InkWell(
                          child: ClipOval(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            FutureBuilder<String>(
                              future: getUserName(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Text('Loading...');
                                } else if (snapshot.hasError) {
                                  return const Text('User');
                                } else if (!snapshot.hasData || snapshot.data == null) {
                                  return const Text('User');
                                } else {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      title: Text(
                                        snapshot.data!,
                                        style: const TextStyle(
                                            fontFamily: "assets/Roboto-Regular.ttf",
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            Positioned(
                              left: 15,
                              top: 40,
                              child: Row(
                                children: [
                                  const Icon(Icons.public , size: 17, color: Colors.grey,),
                                  Container(
                                      margin: const EdgeInsets.only(left: 5),
                                      child: const Text("Public",style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11.99,
                                          fontWeight: FontWeight.w500
                                      ),)
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    )
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                TextFormAnnonce(
                    hintText: 'Partager votre avis. Ajouter des photos ou des hashtags',
                    controllerAnnonce: AnnonceController,
                ),
                if (file != null)
                  Container(
                    height: 180,
                    margin: const EdgeInsets.only(top: 20),
                    child: Image.file(
                      file!,
                      fit: BoxFit.cover, // Adjust the height as needed
                    ),
                  ),
                const SizedBox(height: 20),
                Container(
                    margin: const EdgeInsets.only(top: 20),
                    height: 2,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F2EF),
                    )
                ),
                Row(
                  children: [
                    Container(margin : const EdgeInsets.only(left: 5) , child: IconButton(onPressed: _pickImage, icon: const Icon(Icons.camera_alt))),
                    IconButton(onPressed: () {

                    }, icon: FaIcon(FontAwesomeIcons.hashtag , color: Colors.grey[700],)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
