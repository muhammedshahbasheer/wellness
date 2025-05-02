import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // for kIsWeb

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({Key? key}) : super(key: key);

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final String apiKey = '7fbf654bf4554400b89198da9c51c108'; // Replace with your valid key

  List breakfastRecipes = [];
  List lunchRecipes = [];
  List dinnerRecipes = [];
  List searchResults = [];

  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDefaultRecipes();
  }

  void _loadDefaultRecipes() {
    fetchRecipes('breakfast').then((data) {
      setState(() {
        breakfastRecipes = data;
      });
    });
    fetchRecipes('main course').then((data) {
      setState(() {
        lunchRecipes = data;
        dinnerRecipes = data;
      });
    });
  }

  Future<List> fetchRecipes(String type, {String? query}) async {
    final queryParam = query != null && query.isNotEmpty ? '&query=$query' : '';
    final url = Uri.parse(
      'https://api.spoonacular.com/recipes/complexSearch?type=$type$queryParam&number=10&addRecipeInformation=true&addRecipeNutrition=true&apiKey=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['results'];
    } else {
      print('Failed to load $type recipes: ${response.statusCode} - ${response.body}');
      return [];
    }
  }

  void _handleSearch(String query) async {
    setState(() => searchQuery = query);
    if (query.isEmpty) {
      _loadDefaultRecipes();
      setState(() => searchResults = []);
    } else {
      final results = await fetchRecipes('main course', query: query);
      setState(() => searchResults = results);
    }
  }

  void showRecipeDetails(Map recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(
          recipe['title'] ?? 'Recipe',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Text(
            recipe['summary']?.replaceAll(RegExp(r'<[^>]*>'), '') ?? 'No description available.',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget buildRecipeList(String title, List recipes, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final imageUrl = recipe['image'] ?? '';
              final imageUrlWithCors = kIsWeb ? 'https://api.allorigins.win/raw?url=$imageUrl' : imageUrl;

              return GestureDetector(
                onTap: () => showRecipeDetails(recipe),
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 6,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: imageUrl.isNotEmpty
                            ? FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: imageUrlWithCors,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                imageErrorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image, size: 100, color: Colors.grey);
                                },
                              )
                            : const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe['title'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '🕒 ${recipe['readyInMinutes']} min',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            if (recipe['nutrition']?['nutrients'] != null)
                              Text(
                                '🔥 ${_getCalories(recipe)} cal',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getCalories(Map recipe) {
    try {
      final nutrients = recipe['nutrition']['nutrients'] as List;
      final calorieEntry =
          nutrients.firstWhere((item) => item['name'] == 'Calories', orElse: () => null);
      return calorieEntry != null ? calorieEntry['amount'].round().toString() : 'N/A';
    } catch (_) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Search recipes...',
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                searchController.clear();
                _handleSearch('');
              },
            ),
          ),
          onChanged: _handleSearch,
        ),
      ),
      body: ListView(
        children: searchQuery.isNotEmpty
            ? [
                buildRecipeList("Search Results", searchResults, Icons.search),
              ]
            : [
                buildRecipeList("Breakfast", breakfastRecipes, Icons.breakfast_dining),
                buildRecipeList("Lunch", lunchRecipes, Icons.lunch_dining),
                buildRecipeList("Dinner", dinnerRecipes, Icons.dinner_dining),
              ],
      ),
    );
  }
}
