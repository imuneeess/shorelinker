import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CameraProfile extends StatefulWidget {
  final Widget widget;

  const CameraProfile({super.key, required this.widget});

  @override
  _CameraProfileState createState() => _CameraProfileState();
}

class _CameraProfileState extends State<CameraProfile> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool isGoogleUser = false;

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
    /*String? userType = await storage.read(key: 'userType');
    if (userType == 'google') {
      setState(() {
        isGoogleUser = true;
      });
    } else {
      setState(() {
        isGoogleUser = false;
      });
    }*/
  }

  Future<String?> getProfileImageUrl() async {
    if (isGoogleUser) {
      return await storage.read(key: 'userProfileImageUrl');
    } else {
      return await storage.read(key: 'profile_image');
    }
  }

  @override
  void initState() {
    checkUserType();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.white,
            ),
            height: 145,
            width: 140,
            margin: const EdgeInsets.only(left: 15),
            padding: const EdgeInsets.all(4),
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
                        child: Material(
                          color: Colors.transparent,
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
                      )
                  );
                }
              },
            ),
          ),
          Container(
            child: widget.widget,
          ),
        ],
      ),
    );
  }
}
