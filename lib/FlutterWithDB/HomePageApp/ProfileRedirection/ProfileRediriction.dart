import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/CustomAppBar/CustomAppBar.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Messages/Discussion.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/NavigationBotton/HomeBouttomsSheets.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/Apropos/LayoutBuilder.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/ProfileRedirection/CameraProfile2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../Authentification/GoogleAuth/GoogleOut.dart';
import '../CustomDrawer/CustomDrawer.dart';
import '../GlobalWidgetApp.dart';


class RedirictionPage extends StatefulWidget {
  final String ownerId;
  final String docId;
  const RedirictionPage({super.key, required this.ownerId, required this.docId});

  @override
  State<RedirictionPage> createState() => _ProfilPageSecond();
}

class _ProfilPageSecond extends State<RedirictionPage> {
  bool isLoading = false;
  final GlobalKey<ScaffoldState> profilePageKey2 = GlobalKey<ScaffoldState>();
  bool isExpandeds = false;
  final int maxLine = 2 ;
  bool _isExpanded = false; // Gère l'état de l'affichage du texte
  final int _maxLines = 2; // Nombre de lignes avant d'afficher "Voir plus"
  bool isExpanded = false; // Gère l'état de l'affichage du texte
  final int maxLines = 2; // Nombre de lignes avant d'afficher "Voir plus"
  GoogleOut googleOut = GoogleOut();
  bool isGoogleUser = false;
  String userEmail = '';
  bool isProfilePageVisible = false;
  late Future<DocumentSnapshot> _userProfile;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

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
    checkUserType();
    getUserName();
    getEmailUser();
    if (widget.ownerId.isNotEmpty) {
      _userProfile = FirebaseFirestore.instance
          .collection('profiles')
          .doc(widget.ownerId)
          .get();
    } else {
      // Handle the error or provide a default behavior
      // For example, you can throw an error or show a message
      throw Exception('ownerId or userName is empty');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key : profilePageKey2,
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
        onProfilePressed: () async{
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomeBottomSheets(initialPage: 'profile')));
        },
        onAboutUsPressed: () {},
        onSignOutPressed: () {
          _handleSignOut();
        },
        getUserName: getUserName,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Profil non trouvé'));
          } else {
            var profileData = snapshot.data!.data() as Map<String, dynamic>;
            String NomComplet = profileData['NomComplet'] ?? '';
            String TitreProfil = profileData['TitreProfil'] ?? '';
            String Formation = profileData['Formation'] ?? '';
            String LieuPays = profileData['LieuPays'] ?? '';
            String Pays = profileData['Pays'] ?? '';
            String Resume = profileData['Résumé'] ?? '';
            String Entreprise = profileData['Entreprise'] ?? '' ;
            String Titre = profileData['Titre'] ?? "" ;
            String Lieu = profileData['Lieu'] ?? '';
            String Annee = profileData['Annee'] ?? '';
            String Mois =  profileData['Mois'] ?? '' ;
            String Desc = profileData['Desc'] ?? '' ;

            String SecondEntreprise = profileData['SecondEntreprise'] ?? '' ;
            String SecondTitre = profileData['SecondTitre'] ?? "" ;
            String SecondLieu = profileData['SecondLieu'] ?? '';
            String SecondAnnee = profileData['SecondAnnee'] ?? '';
            String SecondMois =  profileData['SecondMois'] ?? '' ;
            String SecondDesc = profileData['SecondDesc'] ?? '' ;

            String Universite = profileData['Universite'] ?? '' ;
            String Diplome = profileData['Diplome'] ?? "" ;
            String Domaine = profileData['Domaine'] ?? '';
            String AnneeD = profileData['AnneeD'] ?? '';
            String AnneeF =  profileData['AnneeF'] ?? '' ;
            String Resultat = profileData['Resultat'] ?? '' ;
            String SecondUniversite = profileData['SecondUniversite'] ?? '' ;
            String SecondDiplome = profileData['SecondDiplome'] ?? "" ;
            String SecondDomaine = profileData['SecondDomaine'] ?? '';
            String SecondAnneeD = profileData['SecondAnneeD'] ?? '';
            String SecondAnneeF =  profileData['SecondAnneeF'] ?? '' ;
            String SecondResultat = profileData['SecondResultat'] ?? '' ;

            String ThirdUniversite = profileData['ThirdUniversite'] ?? '' ;
            String ThirdDiplome = profileData['ThirdDiplome'] ?? "" ;
            String ThirdDomaine = profileData['ThirdDomaine'] ?? '';
            String ThirdAnneeD = profileData['ThirdAnneeD'] ?? '';
            String ThirdAnneeF =  profileData['ThirdAnneeF'] ?? '' ;
            String ThirdResultat = profileData['ThirdResultat'] ?? '' ;


            return ListView(
              children: [
                CustomAppBar(
                  onDrawerOpen: () {
                    profilePageKey2.currentState?.openDrawer();
                  },
                ),
                GlobalWidgetApp(
                  imageCustom: "assets/images10.jfif",
                  widget: Column(
                    children: [
                      const SizedBox(height: 30),
                      CameraProfile2(widget: Container(), profileId: widget.ownerId, docId: widget.docId),
                      const SizedBox(height: 6),
                      NomComplet != '' ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 17),
                            child: Text(NomComplet,
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
                            child: Text(TitreProfil,
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
                            child: Text(Formation,
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
                                child: Text("$LieuPays${", "}",
                                  style: TextStyle(
                                    fontFamily: "assets/Roboto-Regular.ttf",
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(Pays,
                                style: TextStyle(
                                  fontFamily: "assets/Roboto-Regular.ttf",
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 7 , left: 20),
                            child: MaterialButton(
                              color: Colors.blue[800],
                              shape: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(50),
                                ),
                              textColor: Colors.white,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => DiscussionPage(
                                    NomComplet: NomComplet,
                                    ProfileImage: profileData['ProfileImage'],
                                    UserId: profileData['id'],
                                  ),)
                                );
                            },child: const Text("Message" , style: TextStyle(
                              fontFamily: "assets/Roboto-Regular.ttf",
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),),),
                          )
                        ],
                      ) : Container(),
                      const SizedBox(height: 15),
                      Container(
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F2EF),
                          )
                      ),// La couleur de Fond a réutiliser
                      const SizedBox(height: 10),
                      Resume != '' ? Column(
                        children: [
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
                            ],
                          ), // Apropos
                          UserResumeLayout(resumeText: Resume, isExpanded: _isExpanded,
                              maxLines: _maxLines, onToggle: _toggleExpanded),
                          const SizedBox(height: 20),
                          Container(
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3F2EF),
                              )
                          ),
                        ],
                      ) : Container(),
                      Resume != '' ? const SizedBox(height: 10) : Container(),
                      Column(
                        children: [
                          Container(
                            child: Entreprise != '' ? Column(
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
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(left: 17),
                                        child: Text("$Entreprise Entreprise" , style: TextStyle(
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
                                          child: Text(Titre ,style: const TextStyle(
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
                                          child: Text("Lieu d'entreprise : $Lieu" , style: const TextStyle(
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
                                        child: Text("$Annee . $Mois" , style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[600]
                                          //color: Colors.green[200]
                                        ),),
                                      ),
                                    ],
                                  ),
                                  UserResumeLayout(resumeText: Desc, isExpanded: isExpanded,
                                      maxLines: maxLines, onToggle: toggleExpanded)
                                ]) : Container(),
                          ),
                          Entreprise != '' ? Column(
                            children: [
                              const SizedBox(height: 20),
                              Container(
                                  height: 1,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF3F2EF),
                                  )
                              ),
                              const SizedBox(height: 20),
                            ],
                          ) : Container(),
                          Column(
                            children: [
                              Container(
                                child: SecondEntreprise != '' ? Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(left: 17),
                                            child: Text("$SecondEntreprise Entreprise" , style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.blue[800],
                                              fontFamily: "assets/Roboto-Regular.ttf",
                                              fontWeight: FontWeight.w500,
                                            ),),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              margin: const EdgeInsets.only(left: 17),
                                              child: Text(SecondTitre ,style: const TextStyle(
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
                                              child: Text("Lieu d'entreprise : $SecondLieu" , style: const TextStyle(
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
                                            child: Text("$SecondAnnee . $SecondMois" , style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w600
                                              //color: Colors.green[200]
                                            ),),
                                          ),
                                        ],
                                      ),
                                      UserResumeLayout(resumeText: SecondDesc, isExpanded: isExpandeds, maxLines: maxLine, onToggle: toggleExpandedV2)
                                    ]) : Container(),
                              ),
                             SecondEntreprise != '' ? Column(
                              children: [
                                const SizedBox(height: 20),
                                Container(
                                    height: 1,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF3F2EF),
                                    )
                                ),
                                const SizedBox(height: 20),
                              ],
                             ) : Container()
                            ],
                          )
                        ],
                      ),// C'est expérience de fin d'etudes dehors l'expérience
                      SecondEntreprise != '' ?  Container(
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F2EF),
                          )
                      ) : Container(),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          Container(
                            child: Universite != '' ? Column(
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
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.only(left: 17),
                                          child: Text(Universite, style: TextStyle(
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
                                          child: Text(Diplome,style: const TextStyle(
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
                                          child: Text( "Domaine : $Domaine",style: const TextStyle(
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
                                        child: Text("$AnneeD - $AnneeF" , style: TextStyle(
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
                                        child: Text( "Résultat obtenu : $Resultat", style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.blue[800],
                                          fontFamily: "assets/Roboto-Regular.ttf",
                                          fontWeight: FontWeight.w500,
                                        ),),
                                      ),
                                    ],
                                  ),
                                ]) : Container()
                          ),
                          Universite != '' ? Column(
                            children: [
                              const SizedBox(height: 20),
                              Container(
                                  height: 1,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF3F2EF),
                                  )
                              ),
                              const SizedBox(height: 20),
                            ],
                          ) : Container(),
                          Column(
                            children: [
                              Container(
                                child:  SecondUniversite != '' ? Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              margin: const EdgeInsets.only(left: 17),
                                              child: Text(SecondUniversite, style: TextStyle(
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
                                              child: Text(SecondDiplome ,style: const TextStyle(
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
                                              child: Text( "Domaine : $SecondDomaine" ,style: const TextStyle(
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
                                            child: Text("$SecondAnneeD - $SecondAnneeF" , style: TextStyle(
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
                                            child: Text( "Résultat obtenu : $SecondResultat", style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.blue[800],
                                              fontFamily: "assets/Roboto-Regular.ttf",
                                              fontWeight: FontWeight.w500,
                                            ),),
                                          ),
                                        ],
                                      ),
                                    ]) : Container(),
                              ),
                              SecondUniversite != '' ? Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Container(
                                      height: 1,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF3F2EF),
                                      )
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ) :  Container(),
                              ThirdUniversite != '' ? Column(
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
                                                  child: Text(ThirdUniversite, style: TextStyle(
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
                                                  child: Text(ThirdDiplome,style: const TextStyle(
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
                                                  child: Text( "Domaine : $ThirdDomaine" ,style: const TextStyle(
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
                                                child: Text("$ThirdAnneeD - $ThirdAnneeF" , style: TextStyle(
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
                                                child: Text( "Résultat obtenu : $ThirdResultat", style: TextStyle(
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
                              ) : Container(),
                              ThirdUniversite != '' ? Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Container(
                                      height: 1,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF3F2EF),
                                      )
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ) : Container()
                            ],
                          ),
                        ],
                      ),
                      SecondUniversite != '' || ThirdUniversite != '' ?
                      Container(
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F2EF),
                          )
                      ) : Container(),
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
                                      child: Text(profileData['UserEmail'],style : TextStyle(
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
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}