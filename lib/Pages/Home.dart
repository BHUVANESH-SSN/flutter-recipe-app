import 'dart:convert';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/Pages/recipe.dart';

import 'DashboardPage.dart';
import 'add_recipe.dart';
import 'category.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream<QuerySnapshot>? categoryStream;
  Stream<QuerySnapshot>? recipeStream;
  bool search = false;
  var queryResult = [];
  var tempSearchStore = [];

  @override
  void initState() {
    super.initState();
    categoryStream = FirebaseFirestore.instance.collection("Category").snapshots();
    recipeStream = FirebaseFirestore.instance.collection("Recipe").snapshots();
  }
  void initiatedSearch(String value) {
    if (value.isEmpty) {
      setState(() {
        queryResult = [];
        tempSearchStore = [];
        search = false;
      });
      return;
    }

    setState(() {
      search = true;
    });


    String capitalizedQuery = value[0].toUpperCase() + value.substring(1);

    FirebaseFirestore.instance.collection("Recipe")
        .where("Name", isGreaterThanOrEqualTo: capitalizedQuery) // Start range
        .where("Name", isLessThan: capitalizedQuery + 'z') // End range
        .get()
        .then((QuerySnapshot snapshot) {
      setState(() {
        queryResult = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        tempSearchStore = queryResult;
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecipe()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          margin: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20.0),
              _buildSearchBar(),
              SizedBox(height: 20.0),
              _buildSectionTitle("Categories"),
              SizedBox(height: 10.0),
              _buildCategoryList(),
              SizedBox(height: 20.0),
              _buildSectionTitle("Recipes"),
              SizedBox(height: 10.0),
              search ? _buildSearchResults() : _buildRecipeList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Looking for your\nfavourite meal",
              style: TextStyle(
                color: Colors.black,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDashboardPage(
                      userName: "Saravanan",
                      addedRecipes: ["Paneer Butter Masala", "Tomato Rice"],
                      favoriteRecipes: ["Pizza", "Chocolate Cake"],
                      updatedRecipes: ["Tomato Rice", "Pizza"],
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset(
                  "images/Saravanan.jpg",
                  height: 85,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.only(left: 10.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 223, 219, 227),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      child: TextField(
        onChanged: (value) {
          initiatedSearch(value);
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          suffixIcon: Icon(Icons.search_outlined),
          hintText: "Search Your Recipe...",
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCategoryList() {
    return StreamBuilder<QuerySnapshot>(
      stream: categoryStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No Categories Available"));
        }

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var category = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              String image = category["Image"] ?? "";
              String title = category["Category"] ?? "Unknown Category";

              return Padding(
                padding: EdgeInsets.only(right: 10.0), // Adjust the spacing as needed
                child: _buildCategoryCard(image, title),
              );

            },
          ),
        );
      },
    );
  }

  Widget _buildRecipeList() {
    return StreamBuilder<QuerySnapshot>(
      stream: recipeStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No Recipes Available"));
        }

        var recipes = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

        return _buildRecipeGrid(recipes);
      },
    );
  }

  Widget _buildSearchResults() {
    if (tempSearchStore.isEmpty) {
      return Center(child: Text("No matching recipes found."));
    }
    return _buildRecipeGrid(tempSearchStore.cast<Map<String, dynamic>>());
  }

  Widget _buildRecipeGrid(List<Map<String, dynamic>> recipes) {
    return GridView.builder(
      itemCount: recipes.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        var recipe = recipes[index];

        String image = recipe["Image"] ?? "";
        String title = recipe["Name"] ?? "Unknown Recipe";
        String details = recipe["Description"] ?? "No details available.";

        return _buildRecipeCard(image, title, details);
      },
    );
  }

  Widget _buildCategoryCard(String base64Image, String title) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Category(category: title),
          ),
        );
      },
      child: Container(
        width: 200,

        margin: EdgeInsets.only(right: 10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            ClipRRect(

              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: base64Image.isNotEmpty
                  ? Image.memory(base64Decode(base64Image), height: 120, width: double.infinity, fit: BoxFit.cover)
                  : Image.asset("images/a.jpg", height: 120, width: double.infinity, fit: BoxFit.cover),
            ),
      Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
      child: Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis,
      ),
      ),
          ],
        ),
      ),
    );
  }
  Widget _buildRecipeCard(String base64Image, String title, String details) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Recipe(image: base64Image, foodname: title, recipe: details),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: base64Image.isNotEmpty
                    ? Image.memory(
                  base64Decode(base64Image),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  "images/a.jpg",
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



