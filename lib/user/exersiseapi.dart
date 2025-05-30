import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExerciseListScreen extends StatefulWidget {
  @override
  _ExerciseListScreenState createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  List exercises = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
  final url = Uri.parse('https://exercisedb.p.rapidapi.com/exercises');
  try {
    final response = await http.get(
      url,
      headers: {
        'X-RapidAPI-Key': '89b9e20778msh30ea497d98b475cp1f6808jsn4cad6e0ea278',  // Replace with your key
        'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
      },
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      print('Total exercises fetched: ${data.length}');
      setState(() {
        exercises = data.take(20).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to load exercises. Status: ${response.statusCode}');
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print('Exception occurred: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise List'),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];

                final String name = exercise['name'] ?? 'No name';
                final String bodyPart = exercise['bodyPart'] ?? 'Unknown body part';
                final String target = exercise['target'] ?? 'Unknown target';
                final String equipment = exercise['equipment'] ?? 'No equipment';
                final String gifUrl = exercise['gifUrl'] ?? '';

                return Card(
  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  child: ListTile(
    contentPadding: EdgeInsets.all(8),
    leading: gifUrl.isNotEmpty
        ? Image.network(gifUrl, width: 80, fit: BoxFit.cover)
        : null,
    title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5),
        Text('Body Part: $bodyPart'),
        Text('Target Muscle: $target'),
        Text('Equipment: $equipment'),
      ],
    ),
    onTap: () {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (gifUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(gifUrl, height: 200),
                    ),
                  SizedBox(height: 10),
                  Text(name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Body Part: $bodyPart'),
                  Text('Target Muscle: $target'),
                  Text('Equipment: $equipment'),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'),
                  )
                ],
              ),
            ),
          );
        },
      );
    },
  ),
);

              },
            ),
    );
  }
}
