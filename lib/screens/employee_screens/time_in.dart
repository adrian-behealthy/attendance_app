import 'dart:async';

import 'package:attendance_app/models/user.dart';
import 'package:attendance_app/services/log_db_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:provider/provider.dart';
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
  Timer getLocationTimer;
  bool _isLocationEnable = false;
  static GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  bool _isMockLocation = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  /// initialize state.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    requestLocationPermission();
//    _checkGPSEnabled();
    executeGetLocation();
  }

  /// calling get location every 5 seconds.
  void executeGetLocation() {
    getLocationTimer =
        Timer.periodic(Duration(seconds: 5), (Timer t) => _getLocation());
  }

  /// get location method, use a try/catch PlatformException.
  Future<bool> _getLocation() async {
    LatLongPosition position;
    bool isMockLocation = false;
    try {
      _isLocationEnable = await _checkGPSEnabled();
      if (!_isLocationEnable) {
        setState(() {
          _longitude = null;
          _latitude = null;
          _isMockLocation = true;
        });
        return false;
      }

      /// query the current location.
      position = await TrustLocation.getLatLong;

      /// check mock location.
      isMockLocation = await TrustLocation.isMockLocation;
    } on PlatformException catch (e) {
      print('PlatformException $e');
      setState(() {
        _isLocationEnable = false;
      });
      return false;
    }
    if (this.mounted) {
      setState(() {
        _isMockLocation = isMockLocation;
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    }
    return true;
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
    getLocationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Time-in / Time-out'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text(
                  "Time-in",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  final bool result = await _getLocation();
                  if (result && !_isMockLocation) {
                    _showLogDialog(user, true);
                  } else {
                    _scaffoldKey.currentState.removeCurrentSnackBar();
                    _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          "Make sure the GPS is enabled and location is available",
                          textAlign: TextAlign.center,
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
                color: Theme.of(context).primaryColor,
              ),
              RaisedButton(
                child: Text(
                  "Time-out",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  final bool result = await _getLocation();
                  if (result && !_isMockLocation) {
                    _showLogDialog(user, false);
                  } else {
                    _scaffoldKey.currentState.removeCurrentSnackBar();
                    _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          "Make sure the GPS is enabled and location is available",
                          textAlign: TextAlign.center,
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
                color: Colors.blue,
              ),
              (_isLocationEnable && _longitude != null && _latitude != null)
                  ? Column(
                      children: <Widget>[
                        Text('The locatiion is available.'),
                        Text('Lat: $_latitude, Lng: $_longitude'),
                      ],
                    )
                  : Text(
                      "The location is not available",
                      style: TextStyle(color: Colors.red),
                    ),
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
    );
  }

  _showLogDialog(User user, bool isTimeIn) {
    return showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          title: Text(isTimeIn ? "Time-in" : "Time-out"),
          content: Wrap(
            children: <Widget>[
              FormBuilder(
                key: _fbKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      FormBuilderTextField(
                        attribute: "project_name",
                        keyboardType: TextInputType.text,
                        maxLength: 70,
                        decoration: InputDecoration(labelText: "Project name"),
                        validators: [
                          FormBuilderValidators.required(),
                          FormBuilderValidators.maxLength(70),
                        ],
                      ),
                      FormBuilderTextField(
                        attribute: "comment",
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        maxLength: 240,
                        decoration: InputDecoration(
                          labelText: "Comment",
                          alignLabelWithHint: true,
                        ),
                        validators: [
                          FormBuilderValidators.maxLength(240),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  MaterialButton(
                    color: Colors.grey,
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  MaterialButton(
                    color: Theme.of(context).accentColor,
                    child: Text(
                      isTimeIn ? "Time-in" : "Time-out",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      _fbKey.currentState.save();

                      if (_fbKey.currentState.validate()) {
                        print(_fbKey.currentState.value);
                        String comment =
                            _fbKey.currentState.value['comment'] ?? '';
                        String projectName =
                            _fbKey.currentState.value['project_name'] ?? '';
                        final result = await LogDbService(uid: user.uid)
                            .addData(
                                isIn: isTimeIn,
                                lat: double.tryParse(_latitude),
                                lng: double.tryParse(_longitude),
                                comment: comment,
                                projectName: projectName);
                        Navigator.pop(context);
                      } else {
                        print("validation failed");
                      }
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _checkGPSEnabled() async {
    try {
      ServiceStatus serviceStatus =
          await LocationPermissions().checkServiceStatus();
      return serviceStatus == ServiceStatus.enabled;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
