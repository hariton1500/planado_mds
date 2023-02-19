//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:planado_mds/Helpers/epsg3395.dart';
import 'package:planado_mds/Helpers/functions.dart';
import 'package:planado_mds/Helpers/map.dart';
import 'package:planado_mds/Services/api.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key, required this.api, required this.payload})
      : super(key: key);
  final PlanadoAPI api;
  final Map<String, Map<String, dynamic>> payload;
  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  LatLng centerMap = LatLng(45.200834, 33.351089);
  MapSource mapSource = MapSource.openstreet;
  final MapController _mapController = MapController();
  var data = {};

  @override
  void initState() {
    //data = jsonDecode(widget.payload);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('map entered');
    //print(widget.payload['jobs']?['jobs']);
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<MapSource>(
              onSelected: (value) {
                mapSource = value;
              },
              itemBuilder: (context) => MapSource.values
                  .map((e) => PopupMenuItem<MapSource>(
                        child: Text(e.name),
                        onTap: () {
                          setState(() {
                            mapSource = e;
                          });
                        },
                      ))
                  .toList())
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          zoom: 15,
          maxZoom: 18,
          crs: mapSource == MapSource.yandexsat
              ? const Epsg3395()
              : const Epsg3857(),
          center: centerMap,
        ),
        layers: [
          layerMap(mapSource),
          MarkerLayerOptions(
            markers: (widget.payload['jobs']?['jobs'] as List).map((job) {
              bool isGeoPresent = job['address']['geolocation'] != null;
              //print(job['address']['geolocation'].runtimeType);
              return Marker(
                width: 100,
                point: LatLng(isGeoPresent ? job['address']['geolocation']['latitude'] : 0, isGeoPresent ? job['address']['geolocation']['longitude'] : 0),
                builder: (context) {
                  return Card(
                    child: Text(getJobPeriod(job['scheduled_at'].toString(), 0)),
                  );
                }
              );}).toList()
          )
        ],
      ),
    );
  }
}
