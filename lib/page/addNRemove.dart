import 'dart:convert';
import 'dart:io';

import 'package:tripnavia/page/dataHandling.dart';
import 'package:http/http.dart' as http;


Future<void> addData(
  String vacationName,
  String destination,
  String date,
  String time,
  Map<String, dynamic> jsonData,
  List<Map<String, dynamic>> information,
  Map<String, dynamic>? OldItem,

) async {
  bool found = true;



    
  

  try {
    final data = jsonData;

    if (!data.containsKey(vacationName)) {
        
  

      // If vacationName doesn't exist, create a new entry
      data[vacationName] = [
        {'isActive': "false", 'dateRange': date, 'imageUrl':await getUrl(vacationName)},
      ];
    } else {

        if (OldItem == null) {
          // If no matching entry was found, add a new one
          data[vacationName].add({
            'destination': destination,
            'date': date,
            'time': time,
            'imageUrl':await getUrl(destination)
          });
        }

        else
        {
          data[information[0]['selectedKey']].removeWhere((item) => item["destination"] == OldItem?['destination']);
            data[vacationName].add({
            'destination': destination,
            'date': date,
            'time': time,
            'imageUrl':await getUrl(destination)
          });
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
  Future<void> deleteVacation(String vacationName, Map<String, dynamic> jsonData, List<Map<String, dynamic>> items, List<Map<String, dynamic>> information) async {
    try {
      final data = jsonData;

      data.remove(vacationName);

      saveDataToFile(json.encode(jsonData));


    jsonData = data;
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