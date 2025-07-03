import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:image/image.dart' as img;

import '../services/database.dart';


class AddRecipe extends StatefulWidget {
  const AddRecipe({super.key});

  @override
  State<AddRecipe> createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {

  List<String> recipeCategories = [
    "Indian",
    "Chinese",
    "Korean",
    "Japanese",
    "French",
    "Mexican",
    "American"

  ];
  String? selectedCategory;
  File? selectedImage;
  Uint8List? webImage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();


  Future<void> getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        print("Web Image Picked: ${bytes.length} bytes");
        setState(() {
          webImage = bytes;
          selectedImage = null;
        });
      } else {
        print("Mobile Image Picked: ${image.path}");
        setState(() {
          selectedImage = File(image.path);
          webImage = null;
        });
      }
    } else {
      print("No image selected");
    }
  }


  Future<Uint8List> compressImage(Uint8List imageBytes) async {
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;


    img.Image resized = img.copyResize(image, width: 500);


    return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
  }


  Future<void> uploadItem() async {
    if (_nameController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&  selectedCategory != null
    ) {
      try {
        String addId = randomAlphaNumeric(10);
        String? base64Image;

        if ((selectedImage != null || webImage != null)) {
          if (kIsWeb) {
            Uint8List compressed = await compressImage(webImage!);
            base64Image = base64Encode(compressed);
          } else {
            List<int> imageBytes = await selectedImage!.readAsBytes();
            Uint8List compressed = await compressImage(
                Uint8List.fromList(imageBytes));
            base64Image = base64Encode(compressed);
          }
        }


        Map<String, dynamic> addrecipe = {
          "Name": _nameController.text,
          "Description": _descriptionController.text,
          "Category": selectedCategory,
          if (base64Image != null) "Image": base64Image,
        };

        DatabaseMethods databaseMethods = DatabaseMethods();
        await databaseMethods.Addrecipe(addrecipe);
        Fluttertoast.showToast(
            msg: "Recipe uploaded successfully!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        // Reset UI
        setState(() {
          _nameController.clear();
          _descriptionController.clear();
          selectedImage = null;
          webImage = null;
          selectedCategory = null;
        });

        print("Recipe Uploaded Successfully!");
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Error uploading recipe: $e",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );

        print("Error uploading recipe: $e");
      }
    } else {
      String missingFields = "Please fill in the following:\n";
      if (_nameController.text.isEmpty) missingFields += "- Recipe Name\n";
      if (_descriptionController.text.isEmpty) missingFields += "- Recipe Description\n";
      if (selectedCategory == null) missingFields += "- Recipe Category\n";

      Fluttertoast.showToast(
        msg: missingFields.trim(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      print(missingFields);
    }
  }

/*
  Future<void> uploadItem() async {
    if (_nameController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      try {
        String addId = randomAlphaNumeric(10);

        // Only upload Name and Description (NO IMAGE)
        Map<String, dynamic> addrecipe = {
          "Name": _nameController.text,
          "Description": _descriptionController.text,
        };

        await FirebaseFirestore.instance.collection("recipes").doc(addId).set(addrecipe);

        // Reset UI
        setState(() {
          _nameController.clear();
          _descriptionController.clear();
          selectedImage = null;
          webImage = null;
        });

        print("Recipe Uploaded Successfully!");
      } catch (e) {
        print("Error uploading recipe: $e");
      }
    } else {
      print("Please enter both name and description.");
    }
  }
*/


  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Recipe", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black, // Set AppBar color
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // White back icon
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Add Recipe",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20.0),

                // Image Picker UI
                GestureDetector(
                  onTap: getImage,
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: selectedImage != null
                            ? Image.file(selectedImage!, fit: BoxFit.cover)
                            : webImage != null
                            ? Image.memory(webImage!, fit: BoxFit.cover)
                            : const Icon(Icons.add_a_photo,
                            color: Colors.black, size: 50),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20.0),
                Text("Recipe Name", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10.0),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20.0),

                // Category Dropdown
                Text("Recipe Category",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCategory,
                    hint: Text("Select Category"),
                    items: recipeCategories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                      print("Selected Category: $selectedCategory");
                    },
                    underline: SizedBox(), // Remove default underline
                  ),
                ),

                const SizedBox(height: 20.0),
                Text("Recipe Description",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10.0),
                TextField(
                  controller: _descriptionController,
                  maxLines: 8,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),

                const SizedBox(height: 30.0),

                GestureDetector(
                  onTap: uploadItem,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: const Center(
                      child: Text(
                        "SAVE",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
