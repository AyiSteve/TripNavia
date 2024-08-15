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

