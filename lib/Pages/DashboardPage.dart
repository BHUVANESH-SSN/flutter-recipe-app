import 'package:flutter/material.dart';

import 'Mealplanner.dart';

class UserDashboardPage extends StatelessWidget {
  final String userName;
  final List<String> addedRecipes;
  final List<String> favoriteRecipes;
  final List<String> updatedRecipes;

  const UserDashboardPage({
    super.key,
    required this.userName,
    required this.addedRecipes,
    required this.favoriteRecipes,
    required this.updatedRecipes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text('👤 $userName\'s Dashboard'),
          centerTitle: true,
          backgroundColor: Colors.deepOrangeAccent,
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month_rounded),
              tooltip: 'Go to Meal Planner',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MealPlanner(),
                  ),
                );
              },
            ),
          ],
        ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard('📌 Recipes You Added', addedRecipes),
            const SizedBox(height: 20),
            _buildSectionCard('❤️ Favorite Recipes', favoriteRecipes),
            const SizedBox(height: 20),
            _buildSectionCard('🛠️ Recently Updated Recipes', updatedRecipes),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<String> items) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: items.isEmpty
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("No items yet.", style: TextStyle(color: Colors.grey)),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...items.map(
                  (recipe) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                leading: const Icon(Icons.restaurant_menu_rounded,
                    color: Colors.deepOrange),
                title: Text(recipe,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
