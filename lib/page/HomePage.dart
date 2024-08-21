import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tripnavia/page/dataHandling.dart';
import 'package:tripnavia/page/scheduleCard.dart';
import 'package:tripnavia/page/addNRemove.dart';
import 'package:intl/intl.dart';  // Required for getting the current year
import 'package:http/http.dart' as http;


class HomePage extends StatefulWidget {
  final Map<String, dynamic> jsonData;
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> information;

  const HomePage({
    super.key,
    required this.jsonData,
    required this.items,
    required this.information,
  });

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Map<String, dynamic> _jsonData;
  late List<Map<String, dynamic>> _items;
  late String _selectedKey;
  late bool _informationLoaded;
  List<Widget> _tripCards = [];
  String _activeTab = 'Active'; // Track which tab is active

  @override
  void initState() {
    super.initState();
        widget.jsonData["+"] =[{'isActive':"false"}];
    _jsonData = widget.jsonData;
    _items = widget.items;
    _informationLoaded = widget.information.isNotEmpty && widget.information[0]['informationLoaded'] ?? false;
    _selectedKey = widget.information.isNotEmpty ? widget.information[0]['selectedKey'] : 'Select a Location';
    // Automatically load the Active tab's trips when the page is initialized
    _updateTripCards();
  }

  void _updateTripCards() {
    setState(() {
      _tripCards = _jsonData.entries
          .where((entry) {
            if (_activeTab == 'Active') {
              return entry.value[0]['isActive'] == "true";
            } else {
              return entry.value[0]['isActive'] == "false";
            }
          })
          .map((entry) {
            if (entry.key != "+")
            {
            return TripCard(
              vacationName: entry.key,
              dayRange: entry.value[0]['dateRange'],
              information: widget.information,
              onUpdateInformation: _updateInformationCallback, // Pass the callback function
              jsonData: _jsonData,
              items: widget.items,
            );
          }
          else
          {
            return FloatingActionButton(
              onPressed: (){addVacationForm(context, _jsonData, widget.information, _updateInformationCallback,false, widget.items);},
              child: Icon(Icons.add), // You can set any icon or text here
              backgroundColor: Color(0xFFB0C1BC),
            );
          }
          })
          .toList();

    });
  }

    /// Helper function to parse dates.
 DateTime _parseDate(String date) {
  try {
    // Define the expected date format. Adjust the format string to match your date format.
    DateFormat format = DateFormat("MM-dd-yyyy");

    // Parse the date string
    return format.parse(date);
  } catch (e) {
    print('Error parsing date: $e');
    // Return a default date far in the past if parsing fails
    return DateTime(1900);
  }
}

  /// Helper function to parse time in "HH:mm" format.
  DateTime _parseTime(String time) {
    try {
      final parts = time.split(':');
      return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
    } catch (e) {
      print('Error parsing time: $e');
      // Handle invalid time format, returning midnight as default
      return DateTime(0, 1, 1, 0, 0);
    }
  }

    void _reorderJsonDataByDayAndTime() {
    _jsonData.forEach((vacationName, items) {
      items.sort((a, b) {
      if (a['date'] != null && b['date'] != null && a['time'] != null && b['time'] != null) 
        {
        final dateA = _parseDate(a['date']);
        final dateB = _parseDate(b['date']);
        final timeA = _parseTime(a['time']);
        final timeB = _parseTime(b['time']);

        // Compare dates first, then times if dates are the same
        if (dateA.isBefore(dateB)) return -1;
        if (dateA.isAfter(dateB)) return 1;

        if (a['date']==b['date'])
        {
        if (timeA.isBefore(timeB)) return -1;
        if (timeA.isAfter(timeB)) return 1;
        }
        }
        return 0;
      });
    });
  }

 void _updateInformationCallback(String selectedKey) {
  setState(() {
    _selectedKey = selectedKey;
    widget.information[0]['selectedKey'] = selectedKey;
    _informationLoaded = true; 

    _reorderJsonDataByDayAndTime();
    try{
    _items = List<Map<String, dynamic>>.from(_jsonData[selectedKey] as List);
    }catch (e) 
    {
      _items = [];
      _informationLoaded = false;
    }
    
    if (_items.length < 2)
    {
      _informationLoaded = false;

    }

    _updateTripCards(); // Refresh the trip cards whenever the information is updated
      });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: Color(0xFFE6EAE4),
      floatingActionButton: _items.isNotEmpty
      ? FloatingActionButton(
          heroTag: "addButton",  // Assign a unique heroTag
          onPressed: () {
    addInformationForm(context, null,_selectedKey, _jsonData, widget.information, _updateInformationCallback);
            setState(() {
              _informationLoaded = false;
            });
          },
          backgroundColor: const Color(0xFF93A8A2),
          child: const Icon(Icons.add),
        )
      : null, // No button when information is not loaded

  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,  // Bottom right of the screen
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Text(
                'Hi\nName!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TabButton(
                    title: 'Active',
                    isActive: _activeTab == 'Active',
                    onTap: () {
                      setState(() {
                        _activeTab = 'Active';
                        _updateInformationCallback('Select a Location');
                      });
                    },
                  ),
                  TabButton(
                    title: 'Upcoming Trip',
                    isActive: _activeTab == 'Upcoming Trip',
                    onTap: () {
                      setState(() {
                        _activeTab = 'Upcoming Trip';
                        _updateInformationCallback('Select a Location');
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _tripCards, // Display the trip cards in a row for horizontal scrolling
                ),
              ),
              SizedBox(height: 16),
              SizedBox(height: 24),
              Text(
                'Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              if (_informationLoaded) ScheduleList(items: _items,jsonData:_jsonData,information: widget.information, onUpdateInformation: _updateInformationCallback)
              else if(_items.length == 1) Center(child: Text("Please add valid destination"))
              else Center(child: Text("Please Select A Schedule")),
              SizedBox(height: 32),
            ],
          ),
          
        ),
        
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final String vacationName;
  final String dayRange;
  final List<Map<String, dynamic>> information;
  final Function(String) onUpdateInformation; // Callback to handle refresh
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
        onUpdateInformation(vacationName); // Use callback to update and refresh
      },
      child: Container(
        width: 350, // Set a fixed width to make horizontal scrolling effective
        height: 240,
        margin: const EdgeInsets.only(right: 16.0), // Add spacing between cards
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vacationName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                    child: TextField(
                      controller: vacationName,
                      
                      decoration: InputDecoration(
                        labelText: 'Enter Vacation Name',
                        floatingLabelStyle: TextStyle(color: Colors.black), 

                        prefixIcon: const Icon(Icons.flight),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)
                        ),
                      ),
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
                                        child: Text(value, style: TextStyle(fontSize: 12.0)),
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
                                        child: Text(value, style: TextStyle(fontSize: 12.0)),
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
                  updateInformationCallback(information[0]['selectedKey']);
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


