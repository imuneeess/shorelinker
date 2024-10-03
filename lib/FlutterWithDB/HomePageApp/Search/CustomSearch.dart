import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:courseflutter/FlutterWithDB/HomePageApp/NavigationBotton/HomeBouttomsSheets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomSearch extends SearchDelegate {

  Future<Map<String, Map<String, String>>> _getAllUserNamesWithImages() async {
    final snapshot = await FirebaseFirestore.instance.collection('profiles').get();
    final userNamesWithDetails = <String, Map<String, String>>{};

    for (var doc in snapshot.docs) {
      final userId = doc['id'];//j'ai pris le document qui fait référence au user
      final userName = doc['NomComplet'] as String;
      final titreProfil = doc['TitreProfil'] as String;
      final ProfileImage = doc['ProfileImage'] as String ;

      userNamesWithDetails[userName] = {
        'imageUrl': ProfileImage,
        'titreProfil': titreProfil,
        'userId': userId, // Ajoutez l'ownerId ici
      };
    }

    return userNamesWithDetails;
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return; // Assurez-vous que l'utilisateur est connecté

    await prefs.remove('recent_searches_$userId');
  }


  Future<void> _addRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return; // Assurez-vous que l'utilisateur est connecté

    List<String>? recentSearches = prefs.getStringList('recent_searches_$userId') ?? [];

    // Ajouter la recherche si elle n'est pas déjà dans la liste
    if (!recentSearches.contains(query)) {
      recentSearches.add(query);
      // Limiter à un certain nombre de recherches récentes
      if (recentSearches.length > 6) {
        recentSearches.removeAt(0);
      }
      await prefs.setStringList('recent_searches_$userId', recentSearches);
    }
  }


  Future<List<String>> _getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return []; // Assurez-vous que l'utilisateur est connecté

    return prefs.getStringList('recent_searches_$userId') ?? [];
  }


  @override
  String get searchFieldLabel => 'Rechercher des utilisateurs...';

  @override
  TextStyle? get searchFieldStyle => const TextStyle(fontSize: 14, color: Colors.black);

  @override
  InputDecorationTheme get searchFieldDecorationTheme => InputDecorationTheme(
    contentPadding: const EdgeInsets.only(left: 15),
    filled: true,
    fillColor: Colors.white70,
    hintStyle: const TextStyle(color: Colors.grey),
    isDense: false,
    border: const OutlineInputBorder(
        borderSide: BorderSide(
            color: Colors.black38
        )
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Color.fromRGBO(24, 143, 212, 0.25),
        width: 3,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
  );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.close, color: Colors.blue),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back, color: Colors.blue),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Container(
          child: Text("This a page for $query"),
        )
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun utilisateur trouvé'));
          }

          final results = snapshot.data!;
          final userNamesWithDetails = results['user_data'] as Map<String, Map<String, String>>;
          final recentSearches = results['recent_data'] as List<String>;

          final filteredEntries = query.isEmpty
              ? recentSearches
              : userNamesWithDetails.keys
              .where((key) => key.toLowerCase().startsWith(query.toLowerCase()))
              .toList();

          return Column(
            children: [
              if (recentSearches.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 20, top: 10),
                      child: const Text("Recherches récentes", style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: "assets/Roboto-Regular.ttf",
                      )),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 15,right: 10),
                      child: TextButton(
                        onPressed: () async {
                          await _clearRecentSearches();
                          Navigator.of(context).pop(); // Ferme le SearchDelegate
                          showSearch(
                            context: context,
                            delegate: CustomSearch(), // Rouvre le SearchDelegate
                          );
                        }, child: Text("Effacer",style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600
                      ),),
                      ),
                    ),
                  ],
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredEntries.length,
                  itemBuilder: (context, index) {
                    final userName = filteredEntries[index];
                    final details = userNamesWithDetails[userName] ?? {};
                    final imageUrl = details['imageUrl'] ?? '';
                    final titreProfil = details['titreProfil'] ?? '';
                    final userId = details['userId'] ?? '';

                    return Column(
                      children: [
                        Container(
                          child: ListTile(
                            leading: Container(
                              margin: const EdgeInsets.only(left: 20),
                              height: 38,
                              width: 38,
                              child: InkWell(
                                child: imageUrl.startsWith('http')
                                    ? CircleAvatar(
                                  backgroundImage: NetworkImage(imageUrl),
                                )
                                    : CircleAvatar(
                                  backgroundImage: FileImage(File(imageUrl)),
                                  child: imageUrl.isEmpty
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "assets/Roboto-Regular.ttf",
                                  ),
                                ),
                                const SizedBox(width: 7), // Espacement entre le nom et le titre
                                Expanded(
                                  child: Text(
                                    " - $titreProfil",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily: "assets/Roboto-Regular.ttf",
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              query = userName;
                              _addRecentSearch(userName); // Ajouter à la liste des recherches récentes
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    HomeBottomSheets(initialPage: 'SearchingProfile', ownerId: userId)));
                            },
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: 1,
                          color: const Color(0xFFF3F2EF),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final userNamesWithDetails = await _getAllUserNamesWithImages();
    final recentSearches = await _getRecentSearches();

    return {
      'user_data': userNamesWithDetails,
      'recent_data': recentSearches,
    };
  }


}
