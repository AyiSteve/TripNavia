import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:tripnavia/page/dataHandling.dart';
import 'package:http/http.dart' as http;


Future<void> addData(
  String vacationName,
  String destination,
  String date,
  String time,
  Map<String, dynamic> jsonData,
  List<Map<String, dynamic>> information,
  Map<String, dynamic>? oldItem,
) async {
  try {
    // If vacationName doesn't exist, create a new entry
    if (!jsonData.containsKey(vacationName)) {
      jsonData[vacationName] = [
        {
          'isActive': "false",
          'dateRange': date,
          'imageUrl': await getUrl(vacationName),
        },
      ];
    } else {
      if (oldItem == null) {
        // If no matching entry was found, add a new one
        jsonData[vacationName].add({
          'destination': destination,
          'date': date,
          'time': time,
          'imageUrl': await getUrl(destination),
        });
      } else {
        // Update the existing entry by removing the old one and adding the new one
        jsonData[information[0]['selectedKey']]
            .removeWhere((item) => item['destination'] == oldItem['destination']);
        jsonData[vacationName].add({
          'destination': destination,
          'date': date,
          'time': time,
          'imageUrl': await getUrl(destination),
        });
      }
    }

    // Remove the "+" key and reset it afterward
    jsonData.remove('+');
    await saveDataToFile(json.encode(jsonData));
    jsonData["+"] = [
      {'isActive': "false"}
    ];

    // Update the jsonData with the new data
    jsonData = Map<String, dynamic>.from(jsonData);
  } catch (e) {
    print('Error saving data: $e');
  }
}

Future<void> adjustVacation(
  String vacationName,
  String date,
  Map<String, dynamic> jsonData,
  List<Map<String, dynamic>> information,
  bool isActive,
) async {
  try {
    // Retrieve the data associated with the selected vacation
    var tempStorage = jsonData[information[0]['selectedKey']];

    // Remove the old vacation entry from the data
    jsonData.remove(information[0]['selectedKey']);

    // Add the vacation data under the new vacationName
    jsonData[vacationName] = tempStorage;

    // Update the dateRange and isActive fields
    jsonData[vacationName][0]['dateRange'] = date;
    jsonData[vacationName][0]['isActive'] = isActive.toString();

    // Remove the "+" key and reset it afterward
    jsonData.remove('+');
    await saveDataToFile(json.encode(jsonData));
    jsonData["+"] = [
      {'isActive': "false"}
    ];

    // Update jsonData with the new data
    jsonData = Map<String, dynamic>.from(jsonData);
  } catch (e) {
    print('Error saving data: $e');
  }
}

/// Deletes a vacation entry from the JSON file.
Future<void> deleteVacation(
  String vacationName,
  Map<String, dynamic> jsonData,
  List<Map<String, dynamic>> items,
  List<Map<String, dynamic>> information,
) async {
  try {
    // Remove the vacation entry from the data
    jsonData.remove(vacationName);

    // Save the updated data to the file
    await saveDataToFile(json.encode(jsonData));

    print('Vacation "$vacationName" deleted successfully.');
  } catch (e) {
    print('Error deleting data: $e');
  }
}


   /// Deletes a vacation entry from the JSON file.
  Future<void> deleteInformation(String vacationName, Map<String, dynamic> jsonData, String destination) async {
    try {
      final data = jsonData;

      data[vacationName].removeWhere((item) => item["destination"] == destination);

      saveDataToFile(json.encode(jsonData));


    jsonData = data;
    } catch (e) {
      print('Error deleting data: $e');
    }
  }