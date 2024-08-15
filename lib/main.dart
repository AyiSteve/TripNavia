import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tripnavia/page/dataHandling.dart';
import 'package:tripnavia/page/HomePage.dart';

import 'package:tripnavia/page/mapPage.dart';
import 'package:tripnavia/page/searchPage/searchPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentPlace = 0;
  Map<String, dynamic> _jsonData = {};  // Loaded JSON data
  List<Map<String, dynamic>> _items = [];  // Items for the selected vacation
  List<Map<String, dynamic>> _information = [];  // Items for the selected vacation
  String _selectedKey = 'Select a Location';  // Currently selected vacation key
  bool _informationLoaded = false;  // Controls whether the vacation details are displayed

  @override
  void initState() {
    super.initState();
    _loadData();  // Load the data when the app starts

  }

  /// Loads the JSON data from the storage file and updates the UI.
  Future<void> _loadData() async {
    try {
      final String response = await rootBundle.loadString('assets/storage.json');
        setState(() {
          _jsonData = json.decode(response);
          
          _reorderJsonDataByDayAndTime();

          // Write back to the JSON file after sorting
          saveDataToFile(json.encode(_jsonData));
          // Initialize the variables
          _selectedKey = _jsonData.keys.isNotEmpty ? _jsonData.keys.first : 'Select a Location';
          _items = List<Map<String, dynamic>>.from(_jsonData[_selectedKey] ?? []);
          _informationLoaded = true;
         _information.add({'selectedKey': _jsonData.keys.isNotEmpty ? _jsonData.keys.first : 'Select a Location', 'informationLoaded': true},);
        });
    } catch (e) {
      print('Error loading JSON: $e');
    }
  }

  /// Loads the information for the selected vacation key.
  Future<void> _loadInformation() async {
    if (_selectedKey == 'Select a Location') return;  // Skip if no valid key is selected

    setState(() {
      _items = List<Map<String, dynamic>>.from(_jsonData[_selectedKey] ?? []);
      _informationLoaded = true;
    });
  }

  /// Reorders the JSON data by day and time.
  void _reorderJsonDataByDayAndTime() {
    _jsonData.forEach((vacationName, items) {
      items.sort((a, b) {
      if (a['date'] != null && b['date'] != null && a['time'] != null && b['time'] != null) 
        {
        final dateA = _parseDate(a['date']);
        final dateB = _parseDate(b['date']);
        final timeA = _parseTime(a['time']);
        final timeB = _parseTime(b['time']);

        // Compare dates first, then times if dates are the same
        if (dateA.isBefore(dateB)) return -1;
        if (dateA.isAfter(dateB)) return 1;
        if (a['date']==b['date'])
        {
        if (timeA.isBefore(timeB)) return -1;
        if (timeA.isAfter(timeB)) return 1;
        }
        }
        return 0;
      });
    });
  }

  /// Helper function to parse dates.

DateTime _parseDate(String date) {
  try {
    // Define the expected date format. Adjust the format string to match your date format.
    DateFormat format = DateFormat("MM-dd-yyyy");

    // Parse the date string
    return format.parse(date);
  } catch (e) {
    print('Error parsing date: $e');
    // Return a default date far in the past if parsing fails
    return DateTime(1900);
  }
}


  /// Helper function to parse time in "HH:mm" format.
  DateTime _parseTime(String time) {
    try {
      final parts = time.split(':');
      return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
    } catch (e) {
      print('Error parsing time: $e');
      // Handle invalid time format, returning midnight as default
      return DateTime(0, 1, 1, 0, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_jsonData.isEmpty)
    {
      return const Center(child:CircularProgressIndicator());
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFE6EAE4),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home),
            ],
          ),
        ),
        body: Center(
          child: _getBody(),  // Using a method to retrieve the body
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          ],
          backgroundColor: Color(0xFFE6EAE4),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: currentPlace,
          onTap: (int index) {
            setState(() {
              currentPlace = index;
            });
          },
        ),
      ),
    );
  }

  Widget _getBody() {
    return [
      HomePage(jsonData: _jsonData, items: _items, information: _information),
      SearchPage(),
      MapPage(jsonData: _jsonData, items: _items, information: _information),
    ][currentPlace];
  }
}
