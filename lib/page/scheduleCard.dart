import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripnavia/page/addNRemove.dart';

class ScheduleList extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  const ScheduleList({
    super.key,
    required this.items,
  });

  @override
  _ScheduleListState createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  String _activeDay = 'Day 1';

  @override
  Widget build(BuildContext context) {
    final daysMap = _organizeByDays(widget.items);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFFB0C1BC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: daysMap.keys.map((day) {
              return TabButton(
                title: day,
                isActive: day == _activeDay,
                onTap: () {
                  setState(() {
                    _activeDay = day;
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          Column(
            children: daysMap[_activeDay]?.map((item) {
              return ScheduleCard(
                destination: item['destination'] ?? 'Unknown',
                date: item['date'] ?? 'Unknown',
                time: item['time'] ?? 'Unknown',
              );
            }).toList() ?? [],
          ),
        ],
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final String destination;
  final String date;
  final String time;

  const ScheduleCard({
    super.key,
    required this.destination,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        
      },
      child: Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFF93A8A2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            destination,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '$time ($date)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    ),
    );
  }
}

Map<String, List<Map<String, dynamic>>> _organizeByDays(List<Map<String, dynamic>> items) {
  final Map<String, List<Map<String, dynamic>>> daysMap = {};

  if (items.length < 2) return daysMap;

  var numOfDay = 1;
  var day = 'Day $numOfDay';
  daysMap[day] = [items[1]];

  for (var i = 2; i < items.length; i++) {
    if (items[i]['date'] != items[i-1]['date']) {
      numOfDay++;
      day = 'Day $numOfDay';
      daysMap[day] = [];
    }
    daysMap[day]!.add(items[i]);
  }

  return daysMap;
}


class TabButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const TabButton({
    super.key,
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 24.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }
}


void addInformationForm(
  BuildContext context,
  String selectedKey,
  Map<String, dynamic> jsonData,
  List<Map<String, dynamic>> information,
  Function(String) updateInformationCallback,
) {
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
              size: 48.0,
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
                // Day Selection Button
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
                // Time Selection Button
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
                        Icons.access_time,
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
                  await addData(selectedKey, destinationName.text, selectedDay, selectedTime, jsonData, information);
                  updateInformationCallback(selectedKey);
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
