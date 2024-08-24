

import 'package:flutter/material.dart';
import 'package:tripnavia/page/subFileForHomePage/addVacation.dart';
import 'package:tripnavia/page/subFileForHomePage/scheduleCard.dart';
import 'package:intl/intl.dart';  


// ignore: must_be_immutable
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
      if(widget.items[0]['isActive'] == 'false' )
      // ignore: curly_braces_in_flow_control_structures
      _activeTab = 'Upcoming Trip';
    }
    if (widget.jsonData.length < 1)
    {
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
              backgroundColor: const Color(0xFFB0C1BC),
              child: const Icon(Icons.add),
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
    // ignore: avoid_print
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
      // ignore: avoid_print
      print('Error parsing time: $e');

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
      
      backgroundColor: const Color(0xFFE6EAE4),
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
      : null, 

  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,  
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Hi\nName!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _tripCards, // Display the trip cards in a row for horizontal scrolling
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Schedule',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (widget.information[0]['informationLoaded'] == 'true') ScheduleList(items: widget.items,jsonData:widget.jsonData,information: widget.information, onUpdateInformation: _updateInformationCallback)
              else if(widget.items.length == 1) const Center(child: Text("Please add valid destination"))
              else const Center(child: Text("Please Select A Schedule")),
              const SizedBox(height: 32),
            ],
          ),
          
        ),
        
      ),
    );
  }
  
}


