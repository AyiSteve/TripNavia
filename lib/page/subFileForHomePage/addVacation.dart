import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tripnavia/page/addNRemove.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:tripnavia/page/dataHandling.dart';
import 'package:http/http.dart' as http;

final apiKeyPlaces = dotenv.env['places_API_KEY'];

class TripCard extends StatelessWidget {
  final String vacationName;
  final String dayRange;
  final List<Map<String, dynamic>> information;
  final Function(String) onUpdateInformation; 
  final Map<String, dynamic> jsonData;
  final List<Map<String, dynamic>> items;

  const TripCard({
    super.key,
    required this.vacationName,
    required this.dayRange,
    required this.information,
    required this.onUpdateInformation, required this.jsonData, required this.items
  });

  
  @override
  Widget build(BuildContext context) {
   return GestureDetector(
  onTap: () {
    information[0]['selectedKey'] = vacationName;
    onUpdateInformation(vacationName); 
  },
  child: Container(
    width: 350,
    height: 240,
    margin: const EdgeInsets.only(right: 16.0), 
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Color(0xFFB0C1BC),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: NetworkImage(jsonData[vacationName][0]['imageUrl']),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vacationName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 4),
                  Text(
                    dayRange,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.black,
                size: 24,
              ),
              onPressed: () {
                information[0]['selectedKey'] = vacationName;
                addVacationForm(context, jsonData, information, onUpdateInformation, true, items);
              },
            ),
          ],
        ),
      ],
    ),
  ),
);

  }
}





void addVacationForm(
  BuildContext context,
  Map<String, dynamic> jsonData,
  List<Map<String, dynamic>> information,
  Function(String) updateInformationCallback,
  bool isAdjustment,
   List<Map<String, dynamic>> items
) {
  TextEditingController vacationName = TextEditingController();
  String? _startYear, _endYear;
  String? _startMonth, _endMonth;
  int _startDaysInMonth = 0, _endDaysInMonth = 0;
  String? _startDay, _endDay;
  int currentYear = DateTime.now().year;
  List<String> years = List<String>.generate(11, (index) => (currentYear + index).toString());
  Map<String, String> data;
  bool isSwitched = false;
  bool oldSwitches = false;

    List<Map<String, int>> monthDays = [
    {"January": 31},
    {"February": 28},  // 29 in a leap year
    {"March": 31},
    {"April": 30},
    {"May": 31},
    {"June": 30},
    {"July": 31},
    {"August": 31},
    {"September": 30},
    {"October": 31},
    {"November": 30},
    {"December": 31}
  ];


  if (isAdjustment)
  {
    data = breakDownDateRange(jsonData[information[0]['selectedKey']][0]['dateRange']);
    _startYear = data['startYear'];
    _endYear = data['endYear'];
    _startMonth = data['startMonth'];
    _endMonth = data['endMonth'];
    _startDay = data['startDay'];
    _endDay = data['endDay'];
     vacationName = TextEditingController(text: information[0]['selectedKey']);
    _startDaysInMonth = monthDays.firstWhere((month) => month.keys.first == _startMonth).values.first;
    if (_startMonth == "February") {
      _startDaysInMonth = isLeapYear(_startYear) ? 29 : 28;
    }

    _endDaysInMonth = monthDays.firstWhere((month) => month.keys.first == _endMonth).values.first;
    if (_endMonth == "February") {
      _endDaysInMonth = isLeapYear(_endYear) ? 29 : 28;
    }

    if (jsonData[information[0]['selectedKey']][0]['isActive'] == 'true')
      isSwitched = true;

    else
      isSwitched = false;

    oldSwitches = isSwitched;
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

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xFFB0C1BC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        title: const Icon(Icons.home),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              width: 280.0,
              height: 350.0,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: TypeAheadField<String>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: vacationName,  
                      decoration: InputDecoration(
                        hintText: 'Input Vacation',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black, 
                            ),
                          ),
                        prefixIcon: Icon(Icons.flight),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      if (pattern.isEmpty) {
                        return [];
                      }
                      return await fetchPlaceSuggestions(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        leading: Icon(Icons.location_on),
                        title: Text(suggestion),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      vacationName.text = suggestion;
                    },
                  ),
                  
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Start Time"),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          // Start Year Dropdown
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _startYear,
                                  hint: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text("Year", style: TextStyle(fontSize: 12.0)),
                                  ),
                                  items: years.map((year) {
                                    return DropdownMenuItem<String>(
                                      value: year,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(year, style: TextStyle(fontSize: 12.0)),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _startYear = newValue;
                                      if (_startMonth == "February") {
                                        _startDaysInMonth = isLeapYear(_startYear) ? 29 : 28;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _startMonth,
                                  hint: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text("Month", style: TextStyle(fontSize: 12.0)),
                                  ),
                                  items: monthDays.map((month) {
                                    String value = month.keys.first;
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(value, style: TextStyle(fontSize: 12.0), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _startMonth = newValue!;
                                      _startDaysInMonth = monthDays.firstWhere((month) => month.keys.first == _startMonth).values.first;
                                      if (_startMonth == "February") {
                                        _startDaysInMonth = isLeapYear(_startYear) ? 29 : 28;
                                      }
                                      _startDay = null;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: _startMonth != null
                                ? Container(
                                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: _startDay,
                                        hint: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(_startDay??'Day', style: TextStyle(fontSize: 12.0)),
                                        ),
                                        items: List.generate(_startDaysInMonth, (index) {
                                          String day = (index + 1).toString();
                                          return DropdownMenuItem<String>(
                                            value: day,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Text(day, style: TextStyle(fontSize: 12.0)),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _startDay = newValue!;
                                          });
                                        },
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("End Time"),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _endYear,
                                  hint: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text("Year", style: TextStyle(fontSize: 12.0)),
                                  ),
                                  items: years.map((year) {
                                    return DropdownMenuItem<String>(
                                      value: year,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(year, style: TextStyle(fontSize: 12.0)),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _endYear = newValue;
                                      if (_endMonth == "February") {
                                        _endDaysInMonth = isLeapYear(_endYear) ? 29 : 28;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _endMonth,
                                  hint: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text("Month", style: TextStyle(fontSize: 12.0)),
                                  ),
                                  items: monthDays.map((month) {
                                    String value = month.keys.first;
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(value, style: TextStyle(fontSize: 12.0), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _endMonth = newValue!;
                                      _endDaysInMonth = monthDays.firstWhere((month) => month.keys.first == _endMonth).values.first;
                                      if (_endMonth == "February") {
                                        _endDaysInMonth = isLeapYear(_endYear) ? 29 : 28;
                                      }
                                      _endDay = null;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: _endMonth != null
                                ? Container(
                                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey, width: 1.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: _endDay,
                                        hint: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(_endDay??'Day', style: TextStyle(fontSize: 12.0)),
                                        ),
                                        items: List.generate(_endDaysInMonth, (index) {
                                          String day = (index + 1).toString();
                                          return DropdownMenuItem<String>(
                                            value: day,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Text(day, style: TextStyle(fontSize: 12.0)),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _endDay = newValue!;
                                          });
                                        },
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ),

                        ],
                      ),

                      
                    ],
                    
                  ),
            SizedBox(height: 10.0),

           Row(
          children: [
            isAdjustment 
              ? Expanded(child: Text('isActive?')) 
              : SizedBox.shrink(),
              
            isAdjustment 
              ? Expanded(
                  child: Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      setState(() {
                        isSwitched = value;
                      });
            },
          ),
        ) 
      : SizedBox.shrink(),
  ],
)

                ],
                
              ),
            );
          },
        ),
        actions: <Widget>[
            isAdjustment ? Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
              child: FloatingActionButton(
                onPressed: () {
                  deleteVacation(vacationName.text, jsonData, items, information);
                  updateInformationCallback('Select a Location');
                  Navigator.pop(context); // For example, close the dialog
                },
                backgroundColor: Colors.red,
                child: const Icon(Icons.close),
              ),
            ):SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
              child: FloatingActionButton(
                onPressed: () async {
                  if (vacationName.text.isEmpty || _startDay == null || _startMonth == null || _startDay == null ||
                      _endYear == null || _endMonth == null || _endDay == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please input valid information.')),
                    );
                  } else if(isAdjustment){
                    final vacation = vacationName.text;
                    await adjustVacation(vacation, "$_startMonth $_startDay $_startYear-$_endMonth $_endDay $_endYear", jsonData, information,isSwitched);
                    
                    if(isSwitched != oldSwitches)
                    {
                       updateInformationCallback('Select A Location');
                    }
                    else
                    {
                       updateInformationCallback(vacation);

                    }
                    Navigator.pop(context);
                  }
                  else {
                    final vacation = vacationName.text;
                    await addData(vacation, "", "$_startMonth $_startDay $_startYear-$_endMonth $_endDay $_endYear", "", jsonData, information,null);
                     updateInformationCallback(vacation);
                    Navigator.pop(context);
                  }
                },
                backgroundColor: Color(0xFFB0C1BC),
                child: const Icon(Icons.add),
              ),
            ),
],

      );
    },
  );
}