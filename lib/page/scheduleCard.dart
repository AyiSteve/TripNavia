import 'package:flutter/material.dart';

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
    return Container(
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
