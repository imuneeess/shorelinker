// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCMzlgcNTi0sOocwgcS2-h_qGZ06GfsVok',
    appId: '1:95332407892:android:c842a14df3c57af0ddebc1',
    messagingSenderId: '95332407892',
    projectId: 'projetfesshore',
    databaseURL: 'https://projetfesshore-default-rtdb.firebaseio.com',
    storageBucket: 'projetfesshore.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBbRMx-Q7YsqOhh1ZGz1J8rq_pqfFmkYv4',
    appId: '1:95332407892:ios:47c45287e8ff54fcddebc1',
    messagingSenderId: '95332407892',
    projectId: 'projetfesshore',
    databaseURL: 'https://projetfesshore-default-rtdb.firebaseio.com',
    storageBucket: 'projetfesshore.appspot.com',
    iosClientId: '95332407892-vqqc4fj5al9q6iphtk083tji21fig2mn.apps.googleusercontent.com',
    iosBundleId: 'com.example.courseflutter',
  );

}