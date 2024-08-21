import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  // Variables to hold data and control the UI state
  Map<String, dynamic> _jsonData = {};  // Loaded JSON data
  List<Map<String, dynamic>> _items = [];  // Items for the selected vacation
  bool _isLoading = true;  // Loading indicator
  String _selectedKey = 'Select a Location';  // Currently selected vacation key
  bool _informationLoaded = false;  // Controls whether the vacation details are displayed

  @override
  void initState() {
    super.initState();
    _loadData();  // Load the data when the app starts
  }

  /// Loads the JSON data from the storage file and updates the UI.
Future<void> _loadData() async {
  try {
    final String response = await rootBundle.loadString('assets/storage.json');
    if (mounted) {
      setState(() {
        _jsonData = json.decode(response);
        _isLoading = false;  // Stop the loading indicator
      });
    }
  } catch (e) {
    print('Error loading JSON: $e');
        if (mounted) {
      setState(() {
        _isLoading = false;  // Stop the loading indicator
      });
  }
}
}

  /// Saves the vacation data to the JSON file.
Future<void> _addData(String vacationName, String destination, String date, String time) async {
    try {
      final data = _jsonData;

      if (!data.containsKey(vacationName) || _items[0]["destination"] == '') {
        data.remove('+');
        data[vacationName] = [
          {'destination': destination, 'date': date, 'time': time},
        ];
        data['+'] = [
          {'destination': '', 'date': '', 'time': ''},
        ];
      }

      else
      {
        if(vacationName == _selectedKey)
        {
          data[vacationName].add (
          {'destination': destination, 'date': date, 'time': time});
        }

       
      }

      final file = File('assets/storage.json');
      await file.writeAsString(json.encode(data));

      setState(() {
        _jsonData = data;
      });

    } catch (e) {
      print('Error saving data: $e');
    }
  }

  /// Deletes a vacation entry from the JSON file.
  Future<void> _deleteData(String vacationName) async {
    try {
      final data = _jsonData;

      data.remove(vacationName);

      final file = File('assets/storage.json');
      await file.writeAsString(json.encode(data));

      setState(() {
        _jsonData = data;
      });
    } catch (e) {
      print('Error deleting data: $e');
    }
  }

  /// Loads the information for the selected vacation key.
  Future<void> _loadInformation() async {
    if (_selectedKey == 'Select a Location') return;  // Skip if no valid key is selected

    setState(() {
      _items = List<Map<String, dynamic>>.from(_jsonData[_selectedKey] ?? []);
      _informationLoaded = true;  // Indicate that information is now loaded
    });
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
          selectedTime = '${value.format(context)}'; // This includes AM/PM automatically
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
                  _addData(_selectedKey, destinationName.text, selectedDay, selectedTime);
                  setState(() {
                    _loadInformation();
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




  /// Displays a form dialog to create a new vacation.
  void _addVacationForm(BuildContext context) {
    final TextEditingController vacationName = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          title: const Icon(Icons.home),
          content: SizedBox(
            width: 200.0,
            height: 60.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: TextField(
                controller: vacationName,
                decoration: InputDecoration(
                  labelText: 'Enter Vacation Name',
                  prefixIcon: const Icon(Icons.flight),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16.0),
              ),
            ),
          ),
          actions: <Widget>[
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: FloatingActionButton(
                  onPressed: () async {
                    final vacation = vacationName.text;
                    await _addData(vacation, '', '', '');
                    setState(() {
                      _selectedKey = vacation;
                      _loadInformation();
                    });
                    Navigator.pop(context);
                  },
                  backgroundColor: Colors.yellow,
                  child: const Icon(Icons.check_box),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Handles the button press event and updates the selected key.
  void _onButtonPressed(String key) {
    setState(() {
      _selectedKey = key;
    });
    if (_selectedKey == "+") {
      _addVacationForm(context);
    } else {
      _loadInformation();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          ButtonList(
            jsonData: _jsonData,
            onButtonPressed:  _onButtonPressed,
          ),
          Expanded(
            child: _informationLoaded
                ? ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      if (_items[0]["destination"] != '') {
                        return Card(
                          key: ValueKey(_items[index]["date"]),
                          margin: const EdgeInsets.all(10),
                          color: Colors.yellow,
                          child: ListTile(
                            leading: Text(_items[index]["time"]),
                            title: Text(_items[index]["destination"]),
                            subtitle: Text(_items[index]["date"]),
                          ),
                        );
                      }
                    },
                  )
                : const Center(
                    child: Text(
                      'SELECT A VACATION',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
          //Button to delete
          _informationLoaded
              ? Center(
                
                  child: FloatingActionButton(
                    heroTag: "deleteButton",  // Assign a unique heroTag

                    onPressed: () {
                      _deleteData(_selectedKey);
                      setState(() {
                        _selectedKey = 'Select a Location';
                        _informationLoaded = false;
                      });
                    },
                    backgroundColor: const Color.fromARGB(255, 255, 249, 192),
                    child: const Icon(Icons.delete),
                  ),
                )
              : Container(),
          //Button to Add
          _informationLoaded
              ? Align(
                
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: FloatingActionButton(
                        heroTag: "addButton",  // Assign a unique heroTag

                      onPressed: () {
                       _addInformationForm(context);

                      setState(() {
                        _informationLoaded = true;
                      });
                      },

                      backgroundColor: const Color.fromARGB(255, 255, 249, 192),
                      child: const Icon(Icons.add),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}


class ADDLOCATION extends StatelessWidget {
  const ADDLOCATION({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NEW LOCATION'),
      ),
      body: const Center(
        child: Text('Add New Location'),
      ),
    );
  }
}
