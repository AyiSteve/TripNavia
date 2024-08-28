import 'dart:convert';

import 'package:tripnavia/page/dataHandling.dart';


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
        jsonData[vacationName].add({
          'destination': destination,
          'date': date,
          'time': time,
          'imageUrl': await getUrl(destination),
        });
      } else {
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

    jsonData.remove('+');
    await saveDataToFile(json.encode(jsonData));
    jsonData["+"] = [
      {'isActive': "false"}
    ];

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
    var tempStorage = jsonData[information[0]['selectedKey']];

    jsonData.remove(information[0]['selectedKey']);

    jsonData[vacationName] = tempStorage;

    jsonData[vacationName][0]['dateRange'] = date;
    jsonData[vacationName][0]['isActive'] = isActive.toString();

    jsonData.remove('+');
    await saveDataToFile(json.encode(jsonData));
    jsonData["+"] = [
      {'isActive': "false"}
    ];

    jsonData = Map<String, dynamic>.from(jsonData);
  } catch (e) {
    print('Error saving data: $e');
  }
}

Future<void> deleteVacation(
  String vacationName,
  Map<String, dynamic> jsonData,
  List<Map<String, dynamic>> items,
  List<Map<String, dynamic>> information,
) async {
  try {
    jsonData.remove(vacationName);

    await saveDataToFile(json.encode(jsonData));

    print('Vacation "$vacationName" deleted successfully.');
  } catch (e) {
    print('Error deleting data: $e');
  }
}


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