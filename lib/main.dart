import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tripnavia/page/dataHandling.dart';
import 'package:tripnavia/page/HomePage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tripnavia/page/mapPage.dart';
import 'package:tripnavia/page/searchPage/searchPage.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentPlace = 0;
  Map<String, dynamic> _jsonData = {}; 
  List<Map<String, dynamic>> _items = [];  
  List<Map<String, dynamic>> _information = []; 
  String _selectedKey = 'Select a Location';  

  @override
  void initState() {
    super.initState();
    _loadData();  
  }



Future<void> _loadData() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/storage.json';
    final file = File(path);
    if (await file.exists()) {
      final String response = await file.readAsString();

      setState(() {
        _jsonData = json.decode(response);

        _jsonData["+"] = [{'isActive': "false"}];

        _reorderJsonDataByDayAndTime();

        _items = [];

        _information.add({
          'selectedKey': 'Select a Location',
          'informationLoaded': false,
        });

        saveDataToFile(json.encode(_jsonData));
      });
    } else {
      print('Storage file not found, using default values.');
      setState(() {
        _jsonData = {};
        _jsonData["+"] = [{'isActive': "false"}];
        _items = [];
        _information.add({
          'selectedKey': 'Select a Location',
          'informationLoaded': false,
        });
      });
    }
  } catch (e) {
    print('Error loading JSON: $e');
  }
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
    DateFormat format = DateFormat("MM-dd-yyyy");

    return format.parse(date);
  } catch (e) {
    print('Error parsing date: $e');
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
          child: _getBody(),  
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
