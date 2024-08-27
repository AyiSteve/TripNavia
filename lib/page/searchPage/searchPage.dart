import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tripnavia/page/dataHandling.dart';

final apiKey = dotenv.env['OPENAI_API_KEY'];

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _attractions = [];
  bool _isLoading = false;

  Future<void> _searchAttractions(String location) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant that provides lists of attractions.'
            },
            {
              'role': 'user',
              'content': 'List 10 public sites, attractions, or places to go in $location. Provide only the names(dont number those name), separated by commas.'
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        setState(() {
          _attractions = content.split(',').map((e) => e.trim()).toList();

          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch attractions');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch attractions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFFE6EAE4),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter a location',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      _searchAttractions(_searchController.text);
                    }
                  },
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _searchAttractions(value);
                }
              },
            ),
          ),
         Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 5 / 6,
            ),
            shrinkWrap: true, // This will make the grid view take up the space of its content
            itemCount: _attractions.length,
            itemBuilder: (context, index) {
              return SearchTripCard(
                attraction: _attractions[index],
              );
            },
          ),
        )




        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class SearchTripCard extends StatelessWidget {
  final String attraction;

  const SearchTripCard({
    super.key,
    required this.attraction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding
    (
            padding: const EdgeInsets.all(0.0),
      child: Container(
      width: 350,
      height: 240,
      margin: const EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        color: Color(0xFFB0C1BC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: getUrl(attraction), // Await the URL asynchronously
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()), // Show loading indicator while waiting
                );
              } else if (snapshot.hasError) {
                return Container(
                  height: 150,
                  color: Colors.grey,
                  child: Center(child: Text('Error loading image')), // Handle errors
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  height: 150,
                  color: Colors.grey,
                  child: Center(child: Text('No image available')), // Handle no data
                );
              } else {
                return Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(snapshot.data!), // Use the fetched URL
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
            },
          ),
          SizedBox(height: 7),
          Padding(padding: EdgeInsets.only(top:5, left: 8),
          child: Text(
            attraction,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,

            overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows

          ),
          
          )

        ],
      ),
    ),
    );
  }
}

