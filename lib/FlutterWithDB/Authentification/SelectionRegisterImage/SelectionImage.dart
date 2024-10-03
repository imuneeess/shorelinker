import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SelectProfileImagePage extends StatefulWidget {
  const SelectProfileImagePage({super.key});

  @override
  _SelectProfileImagePageState createState() => _SelectProfileImagePageState();
}

class _SelectProfileImagePageState extends State<SelectProfileImagePage> {
  bool isLoading = false;
  String userEmail = '';
  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> _pickProfileImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = pickedImage;
      });
      await _secureStorage.write(key: 'profile_image', value: pickedImage.path);
    }
  }

  Future<void> _completeProfileSetup() async {
    if (_profileImage != null) {
      await Future.delayed(const Duration(seconds: 2)); // Simuler un délai de chargement
      Navigator.of(context).pushReplacementNamed("/login");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une photo de profil')),
      );
    }
  }

  Future<void> getEmail() async {
    userEmail = await _secureStorage.read(key: 'Email') ?? '';
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage('assets/fondDrawer.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 120),
              Text(
                "Choisissez une photo de profil pour $userEmail",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  fontFamily: "assets/Roboto-Regular.ttf",
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              GestureDetector(
                onTap: _pickProfileImage,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(
                      File(_profileImage!.path),
                      fit: BoxFit.cover,
                      width: 200,
                      height: 200,
                    )
                        : Image.asset(
                      'assets/avatar.png',
                      fit: BoxFit.cover,
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  await _completeProfileSetup();
                  setState(() {
                    isLoading = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[300],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Compléter',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
