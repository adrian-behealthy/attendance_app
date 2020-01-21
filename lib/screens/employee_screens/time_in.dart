import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:trust_location/trust_location.dart';

import 'package:flutter/services.dart';

//import 'package:location_permissions/location_permissions.dart';

class TimeIn extends StatefulWidget {
  @override
  _TimeInState createState() => _TimeInState();
}

class _TimeInState extends State<TimeIn> with WidgetsBindingObserver {
  String _latitude;
  String _longitude;
  bool _isMockLocation = false;
  Timer getLocationTimer;

  /// initialize state.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    requestLocationPermission();
    executeGetLocation();
  }

  /// calling get location every 5 seconds.
  void executeGetLocation() {
    getLocationTimer =
        Timer.periodic(Duration(seconds: 5), (Timer t) => _getLocation());
  }

  /// get location method, use a try/catch PlatformException.
  Future<void> _getLocation() async {
    LatLongPosition position;
    bool isMockLocation;
    try {
      /// query the current location.
      position = await TrustLocation.getLatLong;

      /// check mock location.
      isMockLocation = await TrustLocation.isMockLocation;
    } on PlatformException catch (e) {
      print('PlatformException $e');
    }
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _isMockLocation = isMockLocation;
    });
  }

  /// request location permission at runtime.
  void requestLocationPermission() async {
    PermissionStatus permission =
        await LocationPermissions().requestPermissions();
    print('permissions: $permission');
  }

  /// check app state resume or inactive.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      executeGetLocation();
    }
    if (state == AppLifecycleState.inactive) {
      getLocationTimer.cancel();
    }
  }

  /// unregister the WidgetsBindingObserver.
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Trust Location Plugin'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text("Time-in"),
                  onPressed: (){},
                  color: Theme.of(context).primaryColor,
                ),
                RaisedButton(
                  child: Text("Time-out"),
                  onPressed: (){},
                  color: Colors.blue,
                ),
                _isMockLocation
                    ? Text(
                        'Mock Location is used!',
                        style: TextStyle(color: Colors.red),
                      )
                    : Container(),
                _isMockLocation
                    ? Text(
                        "Please use the real GPS.",
                        style: TextStyle(color: Colors.red),
                      )
                    : Container(),
                !_isMockLocation
                    ? Text('Latitude: $_latitude, Longitude: $_longitude')
                    : Container(),
                Expanded(
                  child: ListView.builder(
                    itemCount: 0,
                    itemBuilder: (context, index) {
                      return ListTile();
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
