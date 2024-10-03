import 'dart:io';

import 'package:courseflutter/FlutterWithDB/HomePageApp/Search/SearchHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Search/CustomSearch.dart';


class CustomAppBar extends StatefulWidget {
  final VoidCallback? onDrawerOpen; // Fonction pour ouvrir le drawer
  const CustomAppBar({super.key, this.onDrawerOpen});
  @override
  State<CustomAppBar> createState() => _CustomAppBar();
}

class _CustomAppBar extends State<CustomAppBar>  {
  bool isGoogleUser = false;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

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
    return AppBar(
      backgroundColor: Colors.white,
      leading: Container(
        padding: const EdgeInsets.all(10),
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
                onTap: widget.onDrawerOpen,
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
      actions: [
        Expanded(
            child: Container(
              height: 35,
              margin: const EdgeInsets.only(left: 58),
              child: TextFormApp(hintedText: 'Rechercher...', validator: (p0) => p0, onTap: () {
                showSearch(context: context, delegate: CustomSearch());
              },),
            )),
        IconButton(
          onPressed: () {
            showSearch(context: context, delegate: CustomSearch());
          },
          icon: Container(
            margin: const EdgeInsets.only(right: 10),
            child: const Icon(Icons.search, color: Colors.black54, size: 35),
          ),
        ),
      ],
    );
  }

}
