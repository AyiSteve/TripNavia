import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tripnavia/page/addVacation.dart';
import 'package:tripnavia/page/dataHandling.dart';
import 'package:tripnavia/page/scheduleCard.dart';
import 'package:tripnavia/page/addNRemove.dart';
import 'package:intl/intl.dart';  // Required for getting the current year
import 'package:http/http.dart' as http;


class HomePage extends StatefulWidget {
   Map<String, dynamic> jsonData;
   List<Map<String, dynamic>> items;
   List<Map<String, dynamic>> information;

   HomePage({
    super.key,
    required this.jsonData,
    required this.items,
    required this.information,
  });

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>  {
  List<Widget> _tripCards = [];
  String _activeTab = 'Active'; // Track which tab is active

  @override
  void initState() {
    super.initState();
    if (widget.information[0]['selectedKey'] == null)
    {
      widget.information[0]['selectedKey'] = 'Select a Location';
    }
    _updateInformationCallback(widget.information[0]['selectedKey']);
    widget.jsonData["+"] =[{'isActive':"false"}];

    
    if(widget.information[0]['selectedKey'] != 'Select a Location')
    {
      if(widget.items[0]['isActive'] == 'false')
      _activeTab = 'Upcoming Trip';
    }

        // Automatically load the Active tab's trips when the page is initialized
    _updateTripCards();
  }

  void _updateTripCards() {
    setState(() {
      _tripCards = widget.jsonData.entries
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
              jsonData: widget.jsonData,
              items: widget.items,
            );
          }
          else
          {
            return FloatingActionButton(
              onPressed: (){addVacationForm(context, widget.jsonData, widget.information, _updateInformationCallback,false, widget.items);},
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
    widget.jsonData.forEach((vacationName, items) {
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
    widget.information[0]['selectedKey'] = selectedKey;
    widget.information[0]['informationLoaded'] = true; 

    _reorderJsonDataByDayAndTime();
    try{
    widget.items = List<Map<String, dynamic>>.from(widget.jsonData[selectedKey] as List);
    }catch (e) 
    {
      widget.items = [];
      widget.information[0]['informationLoaded'] = false;
    }
    
    if (widget.items.length < 2)
    {
      widget.information[0]['informationLoaded'] = false;

    }

    widget.information[0]['informationLoaded'] = widget.information[0]['informationLoaded'].toString();

    _updateTripCards(); // Refresh the trip cards whenever the information is updated
      });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: Color(0xFFE6EAE4),
      floatingActionButton: widget.items.isNotEmpty
      ? FloatingActionButton(
          heroTag: "addButton",  // Assign a unique heroTag
          onPressed: () {
    addInformationForm(context, null,widget.information[0]['selectedKey'], widget.jsonData, widget.information, _updateInformationCallback);
            setState(() {
              widget.information[0]['informationLoaded'] = false;
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
              if (widget.information[0]['informationLoaded'] == 'true') ScheduleList(items: widget.items,jsonData:widget.jsonData,information: widget.information, onUpdateInformation: _updateInformationCallback)
              else if(widget.items.length == 1) Center(child: Text("Please add valid destination"))
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





