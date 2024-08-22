import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripnavia/page/subFileForHomePage/scheduleCard.dart';

class MapPage extends StatefulWidget {
   Map<String, dynamic> jsonData;
   List<Map<String, dynamic>> items;
   List<Map<String, dynamic>> information;

   MapPage({
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


  @override
  void initState() {
    super.initState();
    if (widget.information[0]['selectedKey'] == 'Select a Location')
    {
    widget.information[0]['selectedKey'] = null;
    }

    else
    {
      update(widget.information[0]['selectedKey']);
    }
  }

  void update(String selectedKey)
  {
    setState(() {
          widget.information[0]['selectedKey'] = selectedKey;

    try{
    widget.items = List<Map<String, dynamic>>.from(widget.jsonData[widget.information[0]['selectedKey']]as List);
    widget.information[0]['informationLoaded'] = 'true';
    }catch (e) 
    {
      widget.items = [];
      widget.information[0]['informationLoaded'] = 'false';
    }
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
            child: Container(
              width: 200,
              height:50,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 224, 236, 234),
                  borderRadius: BorderRadius.circular(20),
              
              ),
                child: Row(

                  children:[
                    SizedBox(width: 10),
                    Icon(Icons.airplane_ticket),
                    SizedBox(width: 10),
                   DropdownButton<String>(
                      value: widget.information[0]['selectedKey'], 
                      hint: Text('Select/Add Here'),

                      items: widget.jsonData.keys.take(widget.jsonData.keys.length - 1).map<DropdownMenuItem<String>>((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(key), // Display the key as the dropdown item
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                  
                          update(newValue);

                        }
                      },
                    ),

                  ]
                  
                ),
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
                  color: Color.fromARGB(255, 224, 236, 234), // Light green background color
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
                    if (widget.information[0]['informationLoaded'] == 'true')
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
                                  SizedBox(height: 12),
                     if (widget.information[0]['informationLoaded'] == 'true')
                    ScheduleList(items: widget.items,jsonData:widget.jsonData,information: widget.information, onUpdateInformation: update)
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

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: widget.items.length > 1
              ? Row(
                  children: widget.items.skip(1).map((item) {
                    return entertainmentCard(
                      destination: item['destination'] ?? 'Unknown',
                      date: item['date'] ?? 'Unknown',
                      imageUrl: item['imageUrl'] ?? 'Unknown',
                    );
                  }).toList(),
                )
              : Center(
                  child: Text('Please add a valid destination'),
                ),

          ),
        ],
      );
    
  }
}

class entertainmentCard extends StatelessWidget {
  final String destination;
  final String date;
  final String imageUrl;
  
  const entertainmentCard({
    Key? key,
    required this.destination,
    required this.date, required this.imageUrl,
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
      image: DecorationImage(
                image: NetworkImage(imageUrl), 
                fit: BoxFit.cover, 
              ),
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
