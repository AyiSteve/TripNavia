import 'dart:io';

import 'package:path_provider/path_provider.dart';

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
  String startDate = parts[0].trim(); // "March 7 2025"
  String endDate = parts[1].trim(); // "March 9 2026"

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
