import 'package:courseflutter/FlutterWithDB/Authentification/LoginStripe.dart';
import 'package:courseflutter/FlutterWithDB/Authentification/RegisterStripe.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Annonces/Annonce.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/NavigationBotton/HomeBouttomsSheets.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/Profile/ProfilePage.dart';
import 'package:courseflutter/FlutterWithDB/HomeUI/HomePageUI.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courseflutter/FlutterWithDB/Service/AuthService.dart';
import 'package:courseflutter/FlutterWithDB/Provider/AuthProvider.dart' as custom;
import '../../firebase_options.dart';


void main() async{
  final authService = AuthService(baseUrl: 'http://192.168.1.105:3000');
  //*********************** Cafeeeee *******************************
  //final authService = AuthService(baseUrl: 'http://192.168.3.67:3000');
  WidgetsFlutterBinding.ensureInitialized();
  /*await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCc9kF34E31epvQyTNppEK-FlX_mSt0cDo',
        appId: '1:330558914048:android:7a4145ace3dd13baf162e5',
        messagingSenderId: '',
        projectId: 'courseflutter-aa72b',
        storageBucket: 'courseflutter-aa72b.appspot.com',
      )
  );*/
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await FirebaseAppCheck.instance.activate();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<custom.AuthProvider>(
          create: (_) => custom.AuthProvider(authService: authService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget{
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {

  getTokenApp()async {
    String? mytoken = await FirebaseMessaging.instance.getToken();
    print("==============> ${mytoken!}");
  }


  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('======================= User is currently signed out!');
      } else {
        print('======================= User is signed in!');
      }
    });

    super.initState();
    //getTokenApp();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: (FirebaseAuth.instance.currentUser != null
          && FirebaseAuth.instance.currentUser!.emailVerified) ? const HomeBottomSheets() : const HomePageUI(),
      routes: {
        "/register" : (context) => const RegisterStripe(),
        "/login" : (context) =>  const LoginStripe(),
        "/homepage" : (context) => const HomeBottomSheets(),
        "/profile" : (context) => const ProfilePage(),
        "/HomeUI" : (context) => const HomePageUI(),
        "/Annonce" : (context) => const PublicationPage(),
      },
    );
  }

}