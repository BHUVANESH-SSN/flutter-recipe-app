import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class Recipe extends StatefulWidget {
  final String image, foodname, recipe;
  Recipe({required this.image, required this.foodname, required this.recipe});

  @override
  State<Recipe> createState() => _RecipeState();
}

class _RecipeState extends State<Recipe> {
  double userRating = 0; // Store user's rating

  ImageProvider _getImageProvider(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      return AssetImage("images/a.jpg");
    }
    return MemoryImage(base64Decode(base64Image));
  }

  void _shareRecipe() {
    final String text = "Try this amazing recipe: ${widget.foodname}\n\n${widget.recipe}";
    Share.share(text); // Share recipe text
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipe Description", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange, // Set AppBar color
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // White back icon
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            width: MediaQuery.of(context).size.width,
            height: 300,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _getImageProvider(widget.image),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3), BlendMode.darken,
                ),
              ),
            ),
          ),

          // Scrollable Recipe Content
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 240),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.foodname, // Dynamic Food Name
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.share, color: Colors.black), // Share button
                            onPressed: _shareRecipe,
                          ),
                        ],
                      ),
                      Divider(thickness: 2, color: Colors.orangeAccent),
                      SizedBox(height: 10),

                      // About Recipe
                      Text(
                        "About Recipe",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10),

                      // Recipe Instructions
                      Text(
                        "Recipe:",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.recipe, // Dynamic Recipe Steps
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Rating Section
                      Text(
                        "Rate this Recipe:",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < userRating ? Icons.star : Icons.star_border,
                              color: Colors.orange,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                userRating = index + 1.0; // Update rating
                              });
                            },
                          );
                        }),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Your Rating: ${userRating.toStringAsFixed(1)} ⭐",
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),

                      SizedBox(height: 20),

                      // Enjoy Text
                      Center(
                        child: Text(
                          "Enjoy Your Meal! 🍝",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
