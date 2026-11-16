import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'אפליקציית מתכונים',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const RecipeHomeScreen(),
    );
  }
}

class RecipeHomeScreen extends StatefulWidget {
  const RecipeHomeScreen({super.key});

  @override
  State<RecipeHomeScreen> createState() => _RecipeHomeScreenState();
}

class _RecipeHomeScreenState extends State<RecipeHomeScreen> {
  List<dynamic> _recipes = [];
  bool _isLoading = false;
  String _currentSearch = 'chicken';

  @override
  void initState() {
    super.initState();
    _fetchRecipes(_currentSearch);
  }

  Future<void> _fetchRecipes(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/search.php?s=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _recipes = data['meals'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ספר המתכונים שלי',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange[600],
        elevation: 10,
        shadowColor: Colors.orange.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
      ),
      body: Column(
        children: [
          // אזור הכפתורים
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            width: double.infinity,
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              alignment: WrapAlignment.center,
              children: [
                _buildCategoryButton('עוף', 'chicken', Icons.local_dining),
                _buildCategoryButton('בשר', 'meat', Icons.restaurant),
                _buildCategoryButton('דגים', 'fish', Icons.restaurant_menu),
              ],
            ),
          ),
          // רשימת המתכונים
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Colors.orange[600]))
                : _recipes.isEmpty
                    ? const Center(
                        child: Text('לא נמצאו מתכונים.',
                            style: TextStyle(fontSize: 18)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _recipes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 24),
                            elevation: 8,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: SizedBox(
                              height: 280,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    recipe['strMealThumb'],
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    height: 120,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.9),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    right: 16,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recipe['strMeal'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                  blurRadius: 4,
                                                  color: Colors.black)
                                            ],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                color: Colors.white70,
                                                size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              recipe['strArea'] ?? '',
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14),
                                            ),
                                            const SizedBox(width: 16),
                                            const Icon(Icons.category,
                                                color: Colors.white70,
                                                size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              recipe['strCategory'] ?? '',
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String label, String query, IconData icon) {
    final isSelected = _currentSearch == query;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _currentSearch = query;
          });
          _fetchRecipes(query);
        },
        icon: Icon(icon, size: 24), // הוגדל מ-20 ל-24
        label: Text(label,
            style: const TextStyle(
                fontSize: 18, // הוגדל מ-16 ל-18
                fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.orange[600] : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.grey[800],
          elevation: isSelected ? 6 : 2,
          shadowColor:
              isSelected ? Colors.orange.withOpacity(0.5) : Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 16), // הריווח הפנימי הוגדל
        ),
      ),
    );
  }
}
