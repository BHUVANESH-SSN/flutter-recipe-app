import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealPlanner extends StatefulWidget {
  @override
  _MealPlannerState createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

  final Map<String, Map<String, String>> mealPlan = {};
  final Map<String, bool> isEditing = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = "saravanan"; // Use FirebaseAuth UID in real apps

  @override
  void initState() {
    super.initState();
    for (String day in daysOfWeek) {
      mealPlan[day] = {"Breakfast": "", "Lunch": "", "Dinner": ""};
      isEditing[day] = false;
    }
    _loadMealPlanFromFirebase();
  }

  Future<void> _loadMealPlanFromFirebase() async {
    DocumentSnapshot snapshot =
    await _firestore.collection('mealPlans').doc(userId).get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        for (String day in daysOfWeek) {
          if (data[day] != null) {
            mealPlan[day] = Map<String, String>.from(data[day]);
          }
        }
      });
    }
  }

  Future<void> _saveMealToFirebase(String day) async {
    await _firestore.collection('mealPlans').doc(userId).set({
      day: mealPlan[day],
    }, SetOptions(merge: true));
  }

  Widget _buildMealField(String day, String mealType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            "$mealType 🍽️:",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          SizedBox(width: 10),
          Expanded(
            child: isEditing[day]!
                ? TextField(
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: "Enter your $mealType",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (value) {
                mealPlan[day]![mealType] = value;
              },
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: mealPlan[day]![mealType] ?? '',
                  selection: TextSelection.collapsed(
                      offset: mealPlan[day]![mealType]?.length ?? 0),
                ),
              ),
            )
                : Text(
              mealPlan[day]![mealType]?.isNotEmpty ?? false
                  ? mealPlan[day]![mealType]!
                  : "No meal added",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(String day) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "🍽️ $day",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    isEditing[day]! ? Icons.save : Icons.edit,
                    color: Colors.black,
                  ),
                  tooltip: isEditing[day]!
                      ? 'Save this day\'s meals'
                      : 'Edit this day\'s meals',
                  onPressed: () async {
                    setState(() {
                      isEditing[day] = !isEditing[day]!;
                    });

                    if (!isEditing[day]!) {
                      await _saveMealToFirebase(day);
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            for (String mealType in mealTypes) _buildMealField(day, mealType),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Meal Planner 🍴',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: ListView(
        children: [
          SizedBox(height: 16),
          for (String day in daysOfWeek) _buildDayCard(day),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

