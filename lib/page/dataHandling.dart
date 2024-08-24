import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

final apiKeyPicture = dotenv.env['Picture_API_KEY'];

final apiKeyPlaces = dotenv.env['places_API_KEY'];


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
    final url = Uri.parse('https://api.pexels.com/v1/search?query=$name&per_page=1');

    final response = await http.get(
      url,
      headers: {
        'Authorization': '$apiKeyPicture', 
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
        return data['photos'][0]['src']['large'];
    } else {
      throw Exception('Failed to load images');
    }
}

  Future<List<String>> fetchPlaceSuggestions(String input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKeyPlaces';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final suggestions = data['predictions'] as List;
      return suggestions.map((suggestion) => suggestion['description'] as String).toList();
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }

  Future<LatLng?> getLatLngFromGeocodingAPI(String address) async {
  final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKeyPlaces');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final location = data['results'][0]['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];

        print('Geocoded address $address to: $lat, $lng');
        return LatLng(lat, lng);
      } else {
        print('Geocoding API error: ${data['status']}');
        return null;
      }
    } else {
      print('Failed to connect to the API: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error during geocoding: $e');
    return null;
  }
}