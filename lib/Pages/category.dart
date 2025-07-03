import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/Pages/recipe.dart';

class Category extends StatefulWidget {
  final String category;
  Category({required this.category});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  Stream<QuerySnapshot>? categoryStream;

  @override
  void initState() {
    super.initState();
    categoryStream = FirebaseFirestore.instance
        .collection("Recipe")
        .where("Category", isEqualTo: widget.category)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: categoryStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No recipes found in this category"));
          }

          var recipes = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: GridView.builder(
              itemCount: recipes.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1, // Adjust height
              ),
              itemBuilder: (context, index) {
                var recipe = recipes[index].data() as Map<String, dynamic>;
                return _buildRecipeCard(recipe);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Recipe(
                image: recipe["Image"] ?? "",
                foodname: recipe["Name"] ?? "Unknown Recipe",
                recipe: recipe["Description"] ?? "No Description available",
              ),
            ),
          );
        },
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: recipe["Image"] != null && recipe["Image"].isNotEmpty
                  ? Image.memory(
                base64Decode(recipe["Image"]),
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                "images/a.jpg",
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                recipe["Name"] ?? "Unknown Recipe",
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
