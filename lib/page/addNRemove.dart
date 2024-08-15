import 'dart:convert';
import 'dart:io';

import 'package:tripnavia/page/dataHandling.dart';

Future<void> addData(String vacationName, String destination, String date, String time,  Map<String, dynamic> jsonData,
  List<Map<String, dynamic>> information) async {
    try {
      final data = jsonData;

      if (!data.containsKey(vacationName)) {
        data[vacationName] = [
          {'isActive': "false", 'dataRange': date},
        ];
      }

      else
      {
        if(vacationName == information[0]['selectedKey'])
        {
          data[vacationName].add (
          {'destination': destination, 'date': date, 'time': time});
        }

       
      }
      jsonData.remove('+');
      saveDataToFile(json.encode(data));
      jsonData["+"] =[{'isActive':"false"}];

      jsonData = data;
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  /// Deletes a vacation entry from the JSON file.
  Future<void> _deleteData(String vacationName, Map<String, dynamic> jsonData, List<Map<String, dynamic>> items, List<Map<String, dynamic>> information) async {
    try {
      final data = jsonData;

      data.remove(vacationName);

      saveDataToFile(json.encode(jsonData));


    jsonData = data;
    } catch (e) {
      print('Error deleting data: $e');
    }
  }