import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courseflutter/FlutterWithDB/Authentification/GoogleAuth/GoogleOut.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/CustomAppBar/CustomAppBar.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/CustomDrawer/CustomDrawer.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/GlobalWidgetApp.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/Apropos/Apropos.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/CameraProfile.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/Description/DescriptionProfile.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/Experience/Experience.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/Formation/Formation.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/Formation/SecondFomration.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/Formation/ThirdFormation.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/Formation/plusFormation.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/Formation/plusFormationV2.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/Apropos/LayoutBuilder.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/Experience/PlusExperience.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/Experience/SecondExperience.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/Experience/plusExperienceV2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfilePage extends StatefulWidget {

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = false;
  GoogleOut googleOut = GoogleOut();
  bool isGoogleUser = false;
  String userEmail = '';
  bool isProfilePageVisible = false;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  Map<String, dynamic>? userData;
  final GlobalKey<ScaffoldState> profilePageKey = GlobalKey<ScaffoldState>();
  bool isExpandeds = false;
  final int maxLine = 2 ;
  bool _isExpanded = false; // Gère l'état de l'affichage du texte
  final int _maxLines = 2; // Nombre de lignes avant d'afficher "Voir plus"
  bool isExpanded = false; // Gère l'état de l'affichage du texte
  final int maxLines = 2; // Nombre de lignes avant d'afficher "Voir plus"


  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
  void toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }
  void toggleExpandedV2() {
    setState(() {
      isExpandeds = !isExpandeds;
    });
  }

  // Fonction pour récupérer les données utilisateur
  getData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("profiles")
          .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      }

      isLoading = false;
      setState(() {});
    } catch (e) {
      print("Erreur lors de la récupération des données: $e");
      setState(() {
        isLoading = false;
      });
    }
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
        return userData['NomComplet'] ?? 'Nom non disponible';
      }
      return 'User';
    } catch (e) {
      print("Erreur lors de la récupération du nom: $e");
      return 'Nom non disponible';
    }
  }

  @override
  void initState() {
    super.initState();
    getEmailUser();
    checkUserType();
    getUserName();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: profilePageKey, // Assurez-vous que le globalKey est défini ici
      backgroundColor: Colors.white,
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : ListView(
        children: [
          CustomAppBar(
            onDrawerOpen: () {
              profilePageKey.currentState?.openDrawer();
            },
          ),
          GlobalWidgetApp(
            imageCustom: "assets/images10.jfif",
            widget: Column(
              children: [
                const SizedBox(height: 30),
                CameraProfile(
                  widget: Container(
                    margin: const EdgeInsets.only(left: 365, top: 100),
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await Future.delayed(const Duration(seconds: 2));
                        if (mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DescriptionProfile(
                                docid: FirebaseAuth.instance.currentUser!.uid,
                              ),
                            ),
                          );
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: Icon(Icons.edit_outlined, size: 29, color: Colors.grey[600]),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                userData == null ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 17),
                          child: const Text("Description" , style: TextStyle(
                            fontFamily: "assets/Roboto-Regular.ttf",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                            padding: const EdgeInsets.only(left: 15),
                            child: Icon(Icons.add, color: Colors.blue[800])),
                        Container(
                          margin: const EdgeInsets.only(left: 3),
                          child: InkWell(
                            onTap: () async{
                              setState(() {
                                isLoading = true;
                              });
                              await Future.delayed(const Duration(seconds: 2));
                              Navigator.of(context).push(MaterialPageRoute(builder:
                                  (context) => DescriptionProfile(docid: FirebaseAuth.instance.currentUser!.uid)));
                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: Text(
                              "Description utilisateur",
                              style: TextStyle(
                                fontFamily: "assets/Roboto-Regular.ttf",
                                fontSize: 14,
                                color: Colors.blue[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ) :
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 17),
                      child: Text(userData!['NomComplet'],
                        style: const TextStyle(
                          fontFamily: "assets/Roboto-Regular.ttf",
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 17),
                      child: Text(userData!['TitreProfil'],
                        style: const TextStyle(
                          fontFamily: "assets/Roboto-Regular.ttf",
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 17),
                      child: Text(userData!['Formation'],
                        style: TextStyle(
                          fontFamily: "assets/Roboto-Regular.ttf",
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 17),
                          child: Text(userData!['LieuPays'] + ", ",
                            style: TextStyle(
                              fontFamily: "assets/Roboto-Regular.ttf",
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(userData!['Pays'],
                          style: TextStyle(
                            fontFamily: "assets/Roboto-Regular.ttf",
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F2EF),
                  )
                ),// La couleur de Fond a réutiliser
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 17),
                      child: const Text("À propos" , style: TextStyle(
                        fontFamily: "assets/Roboto-Regular.ttf",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: () async{
                          setState(() {
                            isLoading = true;
                          });
                          await Future.delayed(const Duration(seconds: 2));
                          Navigator.of(context).push(MaterialPageRoute(builder:
                              (context) => Apropos(docid: FirebaseAuth.instance.currentUser!.uid)));
                          setState(() {
                            isLoading = false;
                          });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 15),
                          child: Icon(Icons.edit_outlined,size: 29, color: Colors.grey[600])
                      ),
                    ),
                  ],
                ), // Apropos
                userData == null || userData!['Résumé'] == null ? Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                          margin: const EdgeInsets.only(right: 189),
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.add, color: Colors.blue[800])),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 230),
                      child: TextButton(
                        onPressed: () async{
                          setState(() {
                            isLoading = true;
                          });
                          await Future.delayed(const Duration(seconds: 2));
                          Navigator.of(context).push(MaterialPageRoute(builder:
                              (context) => Apropos(docid: FirebaseAuth.instance.currentUser!.uid)));
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: Text(
                          "Ajouter un résumé",
                          style: TextStyle(
                            fontFamily: "assets/Roboto-Regular.ttf",
                            fontSize: 14,
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ) :
                UserResumeLayout(resumeText: userData!['Résumé'], isExpanded: _isExpanded,
                    maxLines: _maxLines, onToggle: _toggleExpanded),
                const SizedBox(height: 10),
                Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F2EF),
                    )
                ),// La couleur de Fond a réustiliser
                const SizedBox(height: 20),
                userData == null || userData!['Entreprise'] == null ? Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 180),
                            height : 45,
                            width: 45,
                            child: Image.asset("assets/experience.png"),
                          ),
                        ],),
                      Container(
                        margin: const EdgeInsets.only(top : 7),
                        child: const Text("Plus d'expérience ?" , style: TextStyle(
                          fontFamily: "assets/Roboto-Regular.ttf",
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        padding: const EdgeInsets.only(left: 20),
                        //color: Colors.red,
                        child: Text("Ajouter vos postes précédents pour trouver de "
                            "nouvelles opportunités de cariere ou pour vous ", style: TextStyle(
                          fontFamily: "assets/Roboto-Regular.ttf",
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),),
                      ),
                      Container(child: Text( "connecter a vos anciens "
                          "collégues" , style: TextStyle(fontFamily: "assets/Roboto-Regular.ttf",
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500))),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        width: 370,
                        child: MaterialButton(
                          shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: const BorderSide(
                              color:  Colors.blue,
                            ),
                          ),
                          onPressed: () async{
                            setState(() {
                              isLoading = true;
                            });
                            await Future.delayed(const Duration(seconds: 2));
                            Navigator.of(context).push(MaterialPageRoute(builder:
                                (context) => Experience(docid: FirebaseAuth.instance.currentUser!.uid)));
                            setState(() {
                              isLoading = false;
                            });
                          },child: Text("Ajouter une expérience" , style: TextStyle(
                            color: Colors.blue[800],
                            fontFamily: "assets/Roboto-Regular.ttf",
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                        ),),),
                      )
                    ],
                  ),
                )
                    : Column(
                      children: [
                        Container(
                          child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 17),
                                child: const Text("Expérience professionnelle" , style: TextStyle(
                                  fontFamily: "assets/Roboto-Regular.ttf",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                )),
                              ),
                              Container(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(100),
                                  onTap: () async{
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await Future.delayed(const Duration(seconds: 2));
                                    Navigator.of(context).push(MaterialPageRoute(builder:
                                        (context) => Experience(docid: FirebaseAuth.instance.currentUser!.uid)));
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.only(right: 15),
                                      child: Icon(Icons.edit_outlined,size: 29, color: Colors.grey[600])
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 17),
                                child: Text( userData!['Entreprise'] + " Entreprise" , style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue[800],
                                  fontFamily: "assets/Roboto-Regular.ttf",
                                  fontWeight: FontWeight.w500,
                                ),),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 17),
                                  child: Text( userData!['Titre'] ,style: const TextStyle(
                                      fontFamily: "assets/Roboto-Regular.ttf",
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14
                                  ),),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 17),
                                  child: Text("Lieu d'entreprise : " + userData!['Lieu'] , style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: "assets/Roboto-Regular.ttf",
                                    fontWeight: FontWeight.w500,
                                  ),),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 17),
                                child: Text(userData!['Annee'] +  " . " + userData!['Mois'] , style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600]
                                    //color: Colors.green[200]
                                ),),
                              ),
                            ],
                          ),
                          UserResumeLayout(resumeText: userData!['Desc'], isExpanded: isExpanded,
                              maxLines: maxLines, onToggle: toggleExpanded)
                        ]),
                        ),
                        const SizedBox(height: 20),
                        Container(
                            height: 1,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3F2EF),
                            )
                        ),
                        const SizedBox(height: 20),
                        userData == null || userData!['SecondEntreprise'] == null ? const PlusExperience()
                            : Column(
                          children: [
                            Container(
                              child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(left: 17),
                                          child: Text( userData!['SecondEntreprise'] + " Entreprise" , style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.blue[800],
                                            fontFamily: "assets/Roboto-Regular.ttf",
                                            fontWeight: FontWeight.w500,
                                          ),),
                                        ),
                                        Container(
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(100),
                                            onTap: () async{
                                              setState(() {
                                                isLoading = true;
                                              });
                                              await Future.delayed(const Duration(seconds: 2));
                                              Navigator.of(context).push(MaterialPageRoute(builder:
                                                  (context) => SecondExperience(docid: FirebaseAuth.instance.currentUser!.uid)));
                                              setState(() {
                                                isLoading = false;
                                              });
                                            },
                                            child: Container(
                                                margin: const EdgeInsets.only(right: 15),
                                                child: Icon(Icons.edit_outlined,size: 29, color: Colors.grey[600])
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.only(left: 17),
                                            child: Text( userData!['SecondTitre'] ,style: const TextStyle(
                                                fontFamily: "assets/Roboto-Regular.ttf",
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14
                                            ),),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.only(left: 17),
                                            child: Text("Lieu d'entreprise : " + userData!['SecondLieu'] , style: const TextStyle(
                                              fontSize: 13,
                                              fontFamily: "assets/Roboto-Regular.ttf",
                                              fontWeight: FontWeight.w500,
                                            ),),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(left: 17),
                                          child: Text(userData!['SecondAnnee'] +  " . " + userData!['SecondMois'] , style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            fontWeight: FontWeight.w600
                                            //color: Colors.green[200]
                                          ),),
                                        ),
                                      ],
                                    ),
                                    UserResumeLayout(resumeText: userData!['SecondDesc'], isExpanded: isExpandeds, maxLines: maxLine, onToggle: toggleExpandedV2)
                                  ]),
                            ),
                            const SizedBox(height: 20),
                            Container(
                                height: 1,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF3F2EF),
                                )
                            ),
                            const SizedBox(height: 20),
                            const PlusExperienceV2(),
                          ],
                        )
                      ],
                    ), // C'est expérience de fin d'etudes dehors l'expérience
                const SizedBox(height: 20),
                Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F2EF),
                    )
                ),
                const SizedBox(height: 20),
                userData == null || userData!['Universite'] == null ? Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height : 50,
                              width: 50,
                              child: Image.asset("assets/formationback.png",height: 100,),
                            ),
                          ),
                        ],),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        child: const Text("Plus de formations ?" , style: TextStyle(
                          fontFamily: "assets/Roboto-Regular.ttf",
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 20),
                        //color: Colors.red,
                        child: Text("Ajouter votre diplome et votre école pour obtenir 11 fois "
                            "plus de vues sur votre profil. Connectez-vous avec vos", style: TextStyle(
                          fontFamily: "assets/Roboto-Regular.ttf",
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),),
                      ),
                      Container(child: Text( "anciens camarades", style: TextStyle(fontFamily: "assets/Roboto-Regular.ttf",
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500))),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        width: 370,
                        child: MaterialButton(
                          shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: const BorderSide(
                              color:  Colors.blue,
                            ),
                          ),
                          onPressed: () async{
                            setState(() {
                              isLoading = true;
                            });
                            await Future.delayed(const Duration(seconds: 2));
                            Navigator.of(context).push(MaterialPageRoute(builder:
                                (context) => Formation(docid: FirebaseAuth.instance.currentUser!.uid)));
                            setState(() {
                              isLoading = false;
                            });
                          },child: Text("Ajouter une formation" , style: TextStyle(
                            color: Colors.blue[800],
                            fontFamily: "assets/Roboto-Regular.ttf",
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                        ),),),
                      )
                    ],
                  ),
                ) :
                Column(
                  children: [
                    Container(
                      child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 17),
                                  child: const Text("Formation" , style: TextStyle(
                                    fontFamily: "assets/Roboto-Regular.ttf",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  )),
                                ),
                                Container(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(100),
                                    onTap: (){
                                      Navigator.of(context).push(MaterialPageRoute(builder:
                                          (context) => Formation(docid: FirebaseAuth.instance.currentUser!.uid)));
                                    },
                                    child: Container(
                                        margin: const EdgeInsets.only(right: 15),
                                        child: Icon(Icons.edit_outlined,size: 29, color: Colors.grey[600])
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 17),
                                    child: Text( userData!['Universite'], style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue[800],
                                      fontFamily: "assets/Roboto-Regular.ttf",
                                      fontWeight: FontWeight.w500,
                                    ),),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 17 , top : 5),
                                    child: Text( userData!['Diplome'] ,style: const TextStyle(
                                        fontFamily: "assets/Roboto-Regular.ttf",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14
                                    ),),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 17),
                                    child: Text( "Domaine : " + userData!['Domaine'] ,style: const TextStyle(
                                        fontFamily: "assets/Roboto-Regular.ttf",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13
                                    ),),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 17),
                                  child: Text(userData!['AnneeD'] +  " - " + userData!['AnneeF'] , style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600
                                    //color: Colors.green[200]
                                  ),),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 17),
                                  child: Text( "Résultat obtenu : " + userData!['Resultat'], style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue[800],
                                    fontFamily: "assets/Roboto-Regular.ttf",
                                    fontWeight: FontWeight.w500,
                                  ),),
                                ),
                              ],
                            ),
                          ]),
                    ),
                    const SizedBox(height: 20),
                    Container(
                        height: 1,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F2EF),
                        )
                    ),
                    const SizedBox(height: 20),
                    userData == null || userData!['SecondUniversite'] == null ? const PlusFormation()
                        : Column(
                      children: [
                        Container(
                          child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 17),
                                        child: Text( userData!['SecondUniversite'], style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue[800],
                                          fontFamily: "assets/Roboto-Regular.ttf",
                                          fontWeight: FontWeight.w500,
                                        ),),
                                      ),
                                    ),
                                    Container(
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(100),
                                        onTap: (){
                                          Navigator.of(context).push(MaterialPageRoute(builder:
                                              (context) => SecondFormation(docid: FirebaseAuth.instance.currentUser!.uid)));
                                        },
                                        child: Container(
                                            margin: const EdgeInsets.only(right: 15),
                                            child: Icon(Icons.edit_outlined,size: 29, color: Colors.grey[600])
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 17 , top : 5),
                                        child: Text( userData!['SecondDiplome'] ,style: const TextStyle(
                                            fontFamily: "assets/Roboto-Regular.ttf",
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14
                                        ),),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 17),
                                        child: Text( "Domaine : " + userData!['SecondDomaine'] ,style: const TextStyle(
                                            fontFamily: "assets/Roboto-Regular.ttf",
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13
                                        ),),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(left: 17),
                                      child: Text(userData!['SecondAnneeD'] +  " - " + userData!['SecondAnneeF'] , style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600
                                        //color: Colors.green[200]
                                      ),),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(left: 17),
                                      child: Text( "Résultat obtenu : " + userData!['SecondResultat'], style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.blue[800],
                                        fontFamily: "assets/Roboto-Regular.ttf",
                                        fontWeight: FontWeight.w500,
                                      ),),
                                    ),
                                  ],
                                ),
                              ]),
                        ),
                        const SizedBox(height: 20),
                        Container(
                            height: 1,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3F2EF),
                            )
                        ),
                        const SizedBox(height: 20),
                        userData == null || userData!['ThirdUniversite'] == null ? const PlusFormationV2() :
                         Column(
                           children: [
                             Container(
                               child: Column(
                                   children: [
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Expanded(
                                           child: Container(
                                             margin: const EdgeInsets.only(left: 17),
                                             child: Text( userData!['ThirdUniversite'], style: TextStyle(
                                               fontSize: 14,
                                               color: Colors.blue[800],
                                               fontFamily: "assets/Roboto-Regular.ttf",
                                               fontWeight: FontWeight.w500,
                                             ),),
                                           ),
                                         ),
                                         Container(
                                           child: InkWell(
                                             borderRadius: BorderRadius.circular(100),
                                             onTap: (){
                                               Navigator.of(context).push(MaterialPageRoute(builder:
                                                   (context) => ThirdFormation(docid: FirebaseAuth.instance.currentUser!.uid)));
                                             },
                                             child: Container(
                                                 margin: const EdgeInsets.only(right: 15),
                                                 child: Icon(Icons.edit_outlined,size: 29, color: Colors.grey[600])
                                             ),
                                           ),
                                         ),
                                       ],
                                     ),
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Expanded(
                                           child: Container(
                                             margin: const EdgeInsets.only(left: 17 , top : 5),
                                             child: Text( userData!['ThirdDiplome'] ,style: const TextStyle(
                                                 fontFamily: "assets/Roboto-Regular.ttf",
                                                 fontWeight: FontWeight.w500,
                                                 fontSize: 14
                                             ),),
                                           ),
                                         ),
                                       ],
                                     ),
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.start,
                                       children: [
                                         Expanded(
                                           child: Container(
                                             margin: const EdgeInsets.only(left: 17),
                                             child: Text( "Domaine : " + userData!['ThirdDomaine'] ,style: const TextStyle(
                                                 fontFamily: "assets/Roboto-Regular.ttf",
                                                 fontWeight: FontWeight.w500,
                                                 fontSize: 13
                                             ),),
                                           ),
                                         ),
                                       ],
                                     ),
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.start,
                                       children: [
                                         Container(
                                           margin: const EdgeInsets.only(left: 17),
                                           child: Text(userData!['ThirdAnneeD'] +  " - " + userData!['ThirdAnneeF'] , style: TextStyle(
                                               fontSize: 13,
                                               color: Colors.grey[600],
                                               fontWeight: FontWeight.w600
                                             //color: Colors.green[200]
                                           ),),
                                         ),
                                       ],
                                     ),
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.start,
                                       children: [
                                         Container(
                                           margin: const EdgeInsets.only(left: 17),
                                           child: Text( "Résultat obtenu : " + userData!['ThirdResultat'], style: TextStyle(
                                             fontSize: 13,
                                             color: Colors.blue[800],
                                             fontFamily: "assets/Roboto-Regular.ttf",
                                             fontWeight: FontWeight.w500,
                                           ),),
                                         ),
                                       ],
                                     ),
                                   ]),
                             ),
                           ],
                         ),
                        const SizedBox(height: 20),
                        Container(
                            height: 1,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3F2EF),
                            )
                        ),
                        const SizedBox(height: 20),
                        const PlusFormationV2()
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F2EF),
                    )
                ),
                const SizedBox(height: 15),
                Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 20),
                            child: const Text("Contacter",style : TextStyle(
                              fontFamily: "assets/Roboto-Regular.ttf",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                  margin: const EdgeInsets.only(left: 28),
                                  child: Icon(Icons.email_outlined, color: Colors.grey[600],),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 65),
                                child: const Text("E-mail",style : TextStyle(
                                  fontFamily: "assets/Roboto-Regular.ttf",
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                )),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 65,top: 23),
                                child: Text(userEmail,style : TextStyle(
                                  fontFamily: "assets/Roboto-Regular.ttf",
                                  fontSize: 13,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                )),
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F2EF),
                    )
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}