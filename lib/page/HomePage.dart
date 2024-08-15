import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tripnavia/page/dataHandling.dart';
import 'package:tripnavia/page/scheduleCard.dart';
import 'package:tripnavia/page/addNRemove.dart';
import 'package:intl/intl.dart';  // Required for getting the current year


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

void _addVacationForm(BuildContext context) {
  final TextEditingController vacationName = TextEditingController();
  String? _startYear, _endYear;
  String? _startMonth, _endMonth;  // Set to null initially
  int _startDaysInMonth = 0, _endDaysInMonth = 0;  // To store the number of days in the selected month
  String? _startDay, _endDay;  // To store the selected day

  int currentYear = DateTime.now().year;
  List<String> years = List<String>.generate(11, (index) => (currentYear + index).toString());

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
              width: 280.0,  // Adjusted width to fit all inputs
              height: 350.0,  // Adjusted height to reduce the overall size
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),  // Adjusted padding to remove extra space
                    child: TextField(
                      controller: vacationName,
                      decoration: InputDecoration(
                        labelText: 'Enter Vacation Name',
                        prefixIcon: const Icon(Icons.flight),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color.fromARGB(255, 214, 234, 228), width: 2.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color.fromARGB(255, 112, 124, 120), width: 1.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                  ),

                  // Start Time Section
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
                                  value: _startYear,  // The current value of the DropdownButton
                                  hint: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text("Year", style: TextStyle(fontSize: 12.0)),  // Adjusted font size
                                  ),
                                  items: years.map((year) {
                                    return DropdownMenuItem<String>(
                                      value: year,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(year, style: TextStyle(fontSize: 12.0)),  // Adjusted font size
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _startYear = newValue;
                                      // Recalculate February days for leap year
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

                          // Start Month Dropdown
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
                                  value: _startMonth,  // The current value of the DropdownButton
                                  hint: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text("Month", style: TextStyle(fontSize: 12.0)),  // Adjusted font size
                                  ),
                                  items: monthDays.map((month) {
                                    String value = month.keys.first;  // Extract the key (month name) from the map
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(value, style: TextStyle(fontSize: 12.0)),  // Adjusted font size
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _startMonth = newValue!;
                                      _startDaysInMonth = monthDays.firstWhere((month) => month.keys.first == _startMonth).values.first;
                                      // Check for leap year in February
                                      if (_startMonth == "February") {
                                        _startDaysInMonth = isLeapYear(_startYear) ? 29 : 28;
                                      }
                                      _startDay = null;  // Reset the selected day
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),

                          // Start Day Dropdown
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
                                        child: Text("Day", style: TextStyle(fontSize: 12.0)),  // Adjusted font size
                                      ),
                                      items: List.generate(_startDaysInMonth, (index) {
                                        String day = (index + 1).toString();
                                        return DropdownMenuItem<String>(
                                          value: day,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Text(day, style: TextStyle(fontSize: 12.0)),  // Adjusted font size
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

                  SizedBox(height: 16.0),  // Reduced spacing between start and end time sections

                  // End Time Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("End Time"),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          // End Year Dropdown
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
                                  value: _endYear,  // The current value of the DropdownButton
                                  hint: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text("Year", style: TextStyle(fontSize: 12.0)),  // Adjusted font size
                                  ),
                                  items: years.map((year) {
                                    return DropdownMenuItem<String>(
                                      value: year,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(year, style: TextStyle(fontSize: 12.0)),  // Adjusted font size
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _endYear = newValue;
                                      // Recalculate February days for leap year
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

                          // End Month Dropdown
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
                                  value: _endMonth,  // The current value of the DropdownButton
                                  hint: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text("Month", style: TextStyle(fontSize: 12.0)),  // Adjusted font size
                                  ),
                                  items: monthDays.map((month) {
                                    String value = month.keys.first;  // Extract the key (month name) from the map
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(value, style: TextStyle(fontSize: 12.0)),  // Adjusted font size
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _endMonth = newValue!;
                                      _endDaysInMonth = monthDays.firstWhere((month) => month.keys.first == _endMonth).values.first;
                                      // Check for leap year in February
                                      if (_endMonth == "February") {
                                        _endDaysInMonth = isLeapYear(_endYear) ? 29 : 28;
                                      }
                                      _endDay = null;  // Reset the selected day
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),

                          // End Day Dropdown
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
                                        child: Text("Day", style: TextStyle(fontSize: 12.0)),  // Adjusted font size
                                      ),
                                      items: List.generate(_endDaysInMonth, (index) {
                                        String day = (index + 1).toString();
                                        return DropdownMenuItem<String>(
                                          value: day,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Text(day, style: TextStyle(fontSize: 12.0)),  // Adjusted font size
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
                ],
              ),
            );
          },
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),  // Reduced padding to remove extra space
            child: FloatingActionButton(
              onPressed: () async {
                if (_startYear == null || _startMonth == null || _startMonth == "Select A Month" || _startDay == null ||
                    _endYear == null || _endMonth == null || _endMonth == "Select A Month" || _endDay == null) {
                  // Show a message to select a valid year, month, and day
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select valid start and end dates.')),
                  );
                } else {
                  final vacation = vacationName.text;
                  addData(vacation, "","$_startMonth $_startDay $_startYear-$_endMonth $_endDay $_endYear", "", _jsonData, widget.information);
                  // Process end date similarly if needed

                  setState(() {
                    _selectedKey = vacation;
                    _informationLoaded = false;
                    _updateInformationCallback(_selectedKey);
                  });
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

void _addInformationForm(BuildContext context) {
  final TextEditingController destinationName = TextEditingController();
  String selectedDay = 'Select A Day';
  String selectedTime = 'Select A Time';

  void _showDatePicker(StateSetter setState) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 10),
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedDay = '${value.year}-${value.month}-${value.day}';
        });
      }
    });
  }



void _showTimePicker(StateSetter setState) {
  showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    initialEntryMode: TimePickerEntryMode.input,
  ).then((value) {
    if (value != null) {
      setState(() {
        // Format the time in 24-hour format
          final now = DateTime.now();
        final dt = DateTime(now.year, now.month, now.day, value.hour, value.minute);
        final format = DateFormat.Hm();  // Use 'Hm' for 24-hour format without seconds
        selectedTime = format.format(dt);
      });
    }
  });
}
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Icon(
              Icons.home,
              size: 48.0, // Adjust size as needed
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Destination TextField
                TextField(
                  controller: destinationName,
                  decoration: InputDecoration(
                    labelText: 'Enter Destination',
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Day Selection Button Bar
                TextButton(
                  onPressed: () => _showDatePicker(setState),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.black,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            selectedDay,
                            style: const TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                  TextButton(
                  onPressed: () => _showTimePicker(setState),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.black,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            selectedTime,
                            style: const TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await addData(_selectedKey, destinationName.text, selectedDay, selectedTime,_jsonData, widget.information);
                  setState(() {
                    _updateInformationCallback(_selectedKey);
                  });
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
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
              dayRange: entry.value[0]['dataRange'],
              information: widget.information,
              onUpdateInformation: _updateInformationCallback, // Pass the callback function
            );
          }
          else
          {
            return FloatingActionButton(
              onPressed: (){_addVacationForm(context);},
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
    _informationLoaded = true; // Ensure information is marked as loaded

    // Cast the list to the correct type
    _items = List<Map<String, dynamic>>.from(_jsonData[selectedKey] as List);
        _reorderJsonDataByDayAndTime();

    _updateTripCards(); // Refresh the trip cards whenever the information is updated
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6EAE4),
      floatingActionButton: _informationLoaded
      ? FloatingActionButton(
          heroTag: "addButton",  // Assign a unique heroTag
          onPressed: () {
            _addInformationForm(context);
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
                        _informationLoaded = false;
                        _updateTripCards();
                      });
                    },
                  ),
                  TabButton(
                    title: 'Upcoming Trip',
                    isActive: _activeTab == 'Upcoming Trip',
                    onTap: () {
                      setState(() {
                        _activeTab = 'Upcoming Trip';
                        _informationLoaded = false;
                        _updateTripCards();
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
              if (_informationLoaded) ScheduleList(items: _items)
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
  final ValueChanged<String> onUpdateInformation; // Callback to handle refresh

  const TripCard({
    super.key,
    required this.vacationName,
    required this.dayRange,
    required this.information,
    required this.onUpdateInformation,
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
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey[300],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vacationName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      dayRange,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                    size: 24,
                  ),
                  onPressed: () {
                    // Define your onPressed action here
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
