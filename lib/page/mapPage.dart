import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripnavia/page/scheduleCard.dart';

class MapPage extends StatefulWidget {
  final Map<String, dynamic> jsonData;
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> information;

  const MapPage({
    Key? key,
    required this.jsonData,
    required this.items,
    required this.information,
  }) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  final LatLng _initialPosition = LatLng(36.7783, -119.4179); // California coordinates

  late Map<String, dynamic> _jsonData;
  late List<Map<String, dynamic>> _items;
  bool _isLoading = true;
  String _selectedKey = 'Select a Location';
  bool _informationLoaded = false;

  @override
  void initState() {
    super.initState();
    _jsonData = widget.jsonData;
    _items = widget.items;
  }

  void update()
  {
    setState(() {
    _jsonData = widget.jsonData;
    _items = widget.items;
    _informationLoaded = widget.information[0]['informationLoaded'];
    _selectedKey = widget.information[0]['selectedKey'];
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map view
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 15.0,
            ),
            onMapCreated: (controller) {
              _controller = controller;
            },
          ),

          // Top App Bar with icons
          Positioned(
            top: 40.0,
            left: 20.0,
            right: 20.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.flight, size: 28),
              ],
            ),
          ),

          // Draggable bottom sheet for Entertainment and Schedule
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Color(0xFFEFEFEF), // Light green background color
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Entertainment',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (widget.information[0]['informationLoaded'])
                      entertainmentList(items: widget.items),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Schedule',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                                  SizedBox(height: 16),
                      //if (widget.information[0]['informationLoaded'])
                      //ScheduleList(items: widget.items),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class entertainmentList extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  const entertainmentList({
    super.key,
    required this.items,
  });

  @override
  _entertainmentListState createState() => _entertainmentListState();
}

class _entertainmentListState extends State<entertainmentList> {

  @override
  Widget build(BuildContext context) {

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
          SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: Row (
              children: widget.items.map((item) {
              return entertainmentCard(
                destination: item['destination'] ?? 'Unknown',
                date: item['date'] ?? 'Unknown',
              );
            }).toList() ?? [],
          ),
          ),
        ],
      ),
    );
  }
}

class entertainmentCard extends StatelessWidget {
  final String destination;
  final String date;

  const entertainmentCard({
    Key? key,
    required this.destination,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.0,
      height: 100.0,
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20.0), // Rounded corners
      // image: DecorationImage(
      //    image: AssetImage('assets/your_image.png'), // Replace with your image asset
       //   fit: BoxFit.cover,
      //  ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey[200], // Background color for the text
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                destination,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
              ),
              SizedBox(height: 2.0),
            ],
          ),
        ),
      ),
    );
  }
}


