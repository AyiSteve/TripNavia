import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripnavia/page/dataHandling.dart';
import 'package:tripnavia/page/subFileForHomePage/scheduleCard.dart';

class MapPage extends StatefulWidget {
   Map<String, dynamic> jsonData;
   List<Map<String, dynamic>> items;
   List<Map<String, dynamic>> information;

  MapPage({
    super.key,
    required this.jsonData,
    required this.items,
    required this.information,
  });

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  LatLng position = LatLng(36.7783, -119.4179); // Default position (California)
  List<dynamic> listOfDestination = [];
  Set<Marker> markers = {}; // Store markers here

  @override
  void initState() {
    super.initState();
    if (widget.information[0]['selectedKey'] == 'Select a Location') {
      widget.information[0]['selectedKey'] = null;
    } else {
      update(widget.information[0]['selectedKey']);
    }
  }

  void update(String selectedKey) {
    setState(() {
      widget.information[0]['selectedKey'] = selectedKey;

      try {
        widget.items = List<Map<String, dynamic>>.from(
            widget.jsonData[widget.information[0]['selectedKey']] as List);
        widget.information[0]['informationLoaded'] = 'true';
      } catch (e) {
        widget.items = [];
        widget.information[0]['informationLoaded'] = 'false';
      }

      listOfDestination = widget.items.skip(1).map((item) {
        return item['destination'] ?? 'Unknown';
      }).toList();

      createMarkers(); // Update markers when destinations change
    });

    searchLocation(selectedKey);
  }

  Future<void> createMarkers() async {
  Set<Marker> newMarkers = {};

  for (String destination in listOfDestination) {
    LatLng? pos = await getLatLngFromGeocodingAPI(destination); // Use local variable
    if (pos != null) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(destination),
          position: pos,
          infoWindow: InfoWindow(
            title: destination,
          ),
        ),
      );
    } else {
      print('Invalid position for destination: $destination');
    }
  }

    try
    {
        setState(() {

    markers = newMarkers; // Update markers in the state
      });

    } catch(e){}
}









Future<void> searchLocation(String location) async {
  try {
    if (location == widget.information[0]['selectedKey'] && listOfDestination.length < 2) {
      // Case: Single destination
      LatLng? newPosition;
      if(listOfDestination.length == 0)
      {
      newPosition = await getLatLngFromGeocodingAPI(widget.information[0]['selectedKey']);
  
      }

      else
      {
        newPosition = await getLatLngFromGeocodingAPI(listOfDestination[0]);

      }

          if (newPosition != null) {
        _controller?.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 14.0)); // Zoom closer
      } 
    } else if (location == widget.information[0]['selectedKey']) {
      // Case: Multiple destinations
      List<LatLng> positions = [];
      for (String destination in listOfDestination) {
        LatLng? pos = await getLatLngFromGeocodingAPI(destination);
        if (pos != null) {
          positions.add(pos); // Add valid positions to the list
        }
      }

      if (positions.isNotEmpty) {
        LatLngBounds bounds = _getBoundsForPositions(positions);
        _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50)); // Adjust padding
      } else {
        print('No valid positions found for multiple destinations.');
      }
    } else {
      // Case: Single location search
      print('Searching for single location search: $location');
      LatLng? newPosition = await getLatLngFromGeocodingAPI(location);
      if (newPosition != null) {
        _controller?.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 14.0)); // Zoom closer
      } else {
        print('Could not find a valid location for: $location');
      }
    }
  } catch (e) {
    print('Error searching location: $e');
  }
}


LatLngBounds _getBoundsForPositions(List<LatLng> positions) {
  double minLat = positions.first.latitude;
  double maxLat = positions.first.latitude;
  double minLng = positions.first.longitude;
  double maxLng = positions.first.longitude;

  for (LatLng position in positions) {
    if (position.latitude < minLat) minLat = position.latitude;
    if (position.latitude > maxLat) maxLat = position.latitude;
    if (position.longitude < minLng) minLng = position.longitude;
    if (position.longitude > maxLng) maxLng = position.longitude;
  }

  return LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map view
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: position,
              zoom: 10.0,
            ),
            onMapCreated: (controller) {
              _controller = controller;
            },
            markers: markers, // Use the markers from the state
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            myLocationEnabled: true,
            compassEnabled: true,
          ),

          // Top App Bar with icons
          Positioned(
            top: 40.0,
            left: 20.0,
            child: Container(
              width: 300,
              height: 50,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 224, 236, 234),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Icon(Icons.airplane_ticket),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                  value: widget.information[0]['selectedKey'],
                  hint: Text('Select/Add Here'),
                  items: widget.jsonData.keys
                      .take(widget.jsonData.keys.length - 1)
                      .map<DropdownMenuItem<String>>((String key) {
                    return DropdownMenuItem<String>(
                      value: key,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 200), // Set a max width here
                        child: Text(
                          key,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      update(newValue);
                    }
                  },
                ),

                ],
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
                padding: const EdgeInsets.only(top: 16.0, left: 100.0, right: 100.0,bottom: 25), // Top, left, and right padding
                child: Container(
                  height: 5,
                  width: 1,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 0, 0, 0), // Background color
                    borderRadius: BorderRadius.circular(8.0), // Adjust the radius as needed
                  ),
                ),
              ),


                    if (widget.information[0]['informationLoaded'] == 'true')
                      entertainmentList(items: widget.items, updateMap: searchLocation),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0, left: 14.0, right: 100.0,bottom: 0),
                      child: Text(
                        'Schedule',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    if (widget.information[0]['informationLoaded'] == 'true' && widget.items.length != 1)
                      ScheduleList(
                          items: widget.items,
                          jsonData: widget.jsonData,
                          information: widget.information,
                          onUpdateInformation: update)
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
  final Function(String) updateMap; // Callback to handle refresh

  const entertainmentList({
    super.key,
    required this.items,
    required this.updateMap,
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
                      updateMap: widget.updateMap,
                    );
                  }).toList(),
                )
              : Row(
                  children: [SizedBox(width: 14), Text('Please add a valid destination')],
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
  final Function(String) updateMap; // Callback to handle refresh

  const entertainmentCard({
    super.key,
    required this.destination,
    required this.date,
    required this.imageUrl,
    required this.updateMap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        updateMap(destination);
      },
      child: Container(
        width: 200.0,
        height: 145.0,
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
      ),
    );
  }
}
