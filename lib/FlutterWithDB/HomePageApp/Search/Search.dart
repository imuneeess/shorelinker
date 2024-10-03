import 'package:flutter/material.dart';

class Search extends StatelessWidget {

  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search delegate", style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
        ),),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
              color: Colors.white,
              onPressed: () {
                showSearch(context: context, delegate: CustomSearch());
              },
              icon: const Icon(Icons.search)
          )
        ],
      ),
    );
  }
}

class CustomSearch extends SearchDelegate{

  List<String> names = [
    "Hamza",
    "Haytam",
    "Anas",
    "Amjad",
    "Youssef",
    "Yasser",
    "Mohammed",
    "Majed",
    "Issam",
    "Zakaria",
    "Zayd",
    "Yahya",
    "Walid",
    "Kamal",
    "Islam"
  ];
  late List FoundedElement;
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(onPressed: () {
        query = "";
      }, icon: const Icon(Icons.close)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(onPressed: () {
      close(context, null);
    }, icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if(query == ""){
      return const Text("");
    }
    else{
      FoundedElement = names.where((element) => element.startsWith(query)).toList();
      return ListView.builder(
        itemCount: FoundedElement.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              showResults(context);
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text("${FoundedElement[index]}"),
              ),
            ),
          );
        },
      );
    }
  }

}



/*@override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          elevation: 10,
          shadowColor: Colors.grey,
          backgroundColor: Colors.blue,
          toolbarHeight: 50.0,
          title: const Text("homePage Application",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        body: Container(
          child: ListView(
            children:  [
              Container(
                color: Colors.red,
                height: 270,
                child: Image.asset("assets/images.jfif" , fit: BoxFit.fill),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: const Text("Welcome to the our Home page application" , style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                )),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 150),
                margin: EdgeInsets.only(top: 10),
                child:MaterialButton(
                  color: Colors.purple,
                  elevation: 6,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed("about");
                  },
                  child: Text("Move About"),
                ),
              )
            ],
          ),
        ),
      );
  }


}*/