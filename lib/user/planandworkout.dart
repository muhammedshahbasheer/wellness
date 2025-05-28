import 'package:flutter/material.dart';
import 'package:wellness/user/plans.dart';
import 'package:wellness/user/userworkoutplan.dart';

class PlansAndRecipesLauncher extends StatelessWidget {
  const PlansAndRecipesLauncher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wellness'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Plans'),
              Tab(text: 'Recipes'),
            ],
          ),
          backgroundColor: Colors.black,
        
automaticallyImplyLeading: false
        ),
        body: const TabBarView(
          children: [
            UserWorkoutPlanPage(),
            RecipeScreen(),
          ],
        ),
        backgroundColor: Colors.black,
      ),
    );
  }
}

