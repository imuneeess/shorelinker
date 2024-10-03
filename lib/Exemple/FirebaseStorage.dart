import 'dart:io';
import 'package:courseflutter/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FirebaseStorageEx(),
    );
  }
}

class FirebaseStorageEx extends StatefulWidget {
  const FirebaseStorageEx({super.key});

  @override
  State<FirebaseStorageEx> createState() => _FirebaseStorage();
}

class _FirebaseStorage extends State<FirebaseStorageEx> {

  File? file;
  String? url ;

  getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageGallery = await picker.pickImage(source: ImageSource.gallery);
    if (imageGallery != null) {
      file = File(imageGallery.path);

      var imagename = basename(imageGallery.path) ;

      var refStorage = FirebaseStorage.instance.ref("Images/$imagename");
      await refStorage.putFile(file!);
      url = await refStorage.getDownloadURL();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Firebase Storage"),
          backgroundColor: Colors.orange,
        ),
        body: Center(
          child: Column(
            children: [
              MaterialButton(
                color: Colors.red,
                  onPressed: () async{
                    await getImage();
                  },
                child: const Text("Get image"),
              ),
              if (url != null) Image.network(url! , width: 100, height: 100 , fit: BoxFit.contain),
            ],
          ),
        ),
    );
  }

}

