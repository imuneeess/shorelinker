import 'package:courseflutter/Auth/login.dart';
import 'package:courseflutter/Auth/register.dart';
import 'package:courseflutter/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCc9kF34E31epvQyTNppEK-FlX_mSt0cDo',
        appId: '1:330558914048:android:7a4145ace3dd13baf162e5',
        messagingSenderId: '',
        projectId: 'courseflutter-aa72b',
        storageBucket: 'courseflutter-aa72b.appspot.com',
      )
  );
  //await FirebaseAppCheck.instance.activate();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget{
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {

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
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Colors.orange,
          elevation: 3,
          shadowColor: Colors.grey,
          titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
          fontSize: 20)
        )
      ),
      home: (FirebaseAuth.instance.currentUser != null &&
          FirebaseAuth.instance.currentUser!.emailVerified) ? const HomePage() : const Login(),
      routes: {
        "/login" : (context) => const Login(),
        "/register" : (context) => const Register(),
        "/homepage" : (context) => const HomePage(),
      },
    );
  }

}