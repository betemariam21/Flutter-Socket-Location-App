import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
class Location_Map extends StatefulWidget {
  const Location_Map({Key? key}) : super(key: key);

  @override
  _Location_MapState createState() => _Location_MapState();
}

class _Location_MapState extends State<Location_Map> {
  late IO.Socket socket;
  late Map<MarkerId, Marker> _markers;
  Completer <GoogleMapController> _contoller = Completer();
  static const CameraPosition _cameraPosition= CameraPosition(target: LatLng(8.988314, 38.768219),
  zoom: 14,);


  @override
  void initState(){
    super.initState();
    _markers = <MarkerId, Marker>{};
    _markers.clear();
    initSocket();
  }
  Future<void> initSocket() async{
    try {
      socket = IO.io(
        "http://192.168.0.109:3700",<String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': true
      });
      socket.connect();
      socket.onConnect((data) => {print('Connect------: ${socket.id}')});
      socket.on("position-change",(data) async{
        var latlng = jsonDecode(data);
        final GoogleMapController controller = await _contoller.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(latlng["lat"],latlng["lng"]),
              zoom: 19,
            ),
          ),
        );
        var image = await BitmapDescriptor.fromAssetImage(ImageConfiguration() , "assets/destination_map_marker.png");
        Marker marker = Marker(
            markerId: MarkerId("ID"),
            icon: image,
            position: LatLng(
              latlng["lat"],
              latlng["lng"],
            )
        );
        setState(() {
          _markers[MarkerId("ID")] = marker;
        });

      });
    }
    catch(e){
    print(e.toString());
    print("________-------------------------------______________----------");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: GoogleMap(
       initialCameraPosition: _cameraPosition,
       mapType: MapType.normal,
       onMapCreated: (GoogleMapController controller){
         _contoller.complete(controller);
       },
       markers: Set<Marker>.of(_markers.values),
     ),
    );
  }
}
