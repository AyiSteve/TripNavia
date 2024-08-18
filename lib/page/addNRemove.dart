import 'dart:convert';
import 'dart:io';

import 'package:tripnavia/page/dataHandling.dart';

Future<void> addData(
  String vacationName,
  String destination,
  String date,
  String time,
  Map<String, dynamic> jsonData,
  List<Map<String, dynamic>> information,
) async {
  try {
    final data = jsonData;

    if (!data.containsKey(vacationName)) {
      // If vacationName doesn't exist, create a new entry
      data[vacationName] = [
        {'isActive': "false", 'dateRange': date},
      ];
    } else {
      if (vacationName == information[0]['selectedKey']) {
        bool found = false;

        if (!found) {
          // If no matching entry was found, add a new one
          data[vacationName].add({
            'destination': destination,
            'date': date,
            'time': time,
          });
        }
      }
    }

    // Remove the "+" key and reset it afterward
    jsonData.remove('+');
    saveDataToFile(json.encode(data));
    jsonData["+"] = [{'isActive': "false"}];

    jsonData = data;
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
    final data = jsonData;
      var tempStorage = jsonData[information[0]['selectedKey']];
      // If vacationName doesn't exist, create a new entry
      data.remove(information[0]['selectedKey']);
      data[vacationName] = tempStorage;

      data[vacationName][0]['dateRange']=date;
      data[vacationName][0]['isActive']=isActive.toString();

    jsonData.remove('+');
    saveDataToFile(json.encode(data));
    jsonData["+"] = [{'isActive': "false"}];
    
    jsonData = data;
  } catch (e) {
    print('Error saving data: $e');
  }
}

  /// Deletes a vacation entry from the JSON file.
  Future<void> deleteData(String vacationName, Map<String, dynamic> jsonData, List<Map<String, dynamic>> items, List<Map<String, dynamic>> information) async {
    try {
      final data = jsonData;

      data.remove(vacationName);

      saveDataToFile(json.encode(jsonData));


    jsonData = data;
    } catch (e) {
      print('Error deleting data: $e');
    }
  }