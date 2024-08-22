import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;


Future<void> saveDataToFile(String jsonData) async {
  final directory = await getApplicationDocumentsDirectory();  // Get the app's documents directory
  final path = '/Users/stevegwy/Project/TripNavia/tripnavia/assets/storage.json';  // Define the path for the file

  final file = File(path);
  await file.writeAsString(jsonData);  // Write the JSON data to the file
}

bool isLeapYear(year)
{
  int number =0;
      try {
         number = int.parse(year);
      } catch (e) {
        print("Error: $e");
      }

    if (number % 4 != 0)
    {
        return false; 
    }
    else if (number % 100 != 0)
    {
        return true;
    }
    else if (number % 400 != 0)
    {
        return false;
    }
    else
    {
        return true;
    }
}

Map<String, String> breakDownDateRange(String dateRange) {
  // Split the date range into start and end parts
  List<String> parts = dateRange.split('-');

  if (parts.length != 2) {
  return {
    'startMonth': 'Month',
    'startDay': 'Day',
    'startYear': 'Year',
    'endMonth': 'Month',
    'endDay': 'Day',
    'endYear': 'Year',
  };  }

  // Extract start and end date parts
  String startDate = parts[0].trim(); 
  String endDate = parts[1].trim(); 

  // Split the start date into month, day, and year
  List<String> startDateParts = startDate.split(' ');
  String startMonth = startDateParts[0];
  String startDay = startDateParts[1];
  String startYear = startDateParts[2];

  // Split the end date into month, day, and year
  List<String> endDateParts = endDate.split(' ');
  String endMonth = endDateParts[0];
  String endDay = endDateParts[1];
  String endYear = endDateParts[2];

  // Return a map containing the extracted components
  return {
    'startMonth': startMonth,
    'startDay': startDay,
    'startYear': startYear,
    'endMonth': endMonth,
    'endDay': endDay,
    'endYear': endYear,
  };
}


Future<String> getUrl (String name)
async {
const String apiKey = 'TsEh7T77K3BRAhpADlCoi55NqfslDWVOO5SWhcALXWqg3NiVcTeyFYSS';


    final url = Uri.parse('https://api.pexels.com/v1/search?query=$name&per_page=1');

    final response = await http.get(
      url,
      headers: {
        'Authorization': apiKey, // Add your Pexels API key here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
        return data['photos'][0]['src']['large'];
    } else {
      throw Exception('Failed to load images');
    }
}