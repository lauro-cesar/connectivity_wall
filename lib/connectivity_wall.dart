library connectivity_wall;

import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity/connectivity.dart';

class ConnectivityWall extends StatefulWidget {
  /// We make a HEAD request to url every pingInterval
  final Uri onPingUrl;

  ///Interval in secs to check the onPingUrl
  final int pingInterval;

  /// Expect this response code from pingUrl
  final int responseCode;

  /// build this when disconnected
  final Widget onDisconnectedWall;

  /// build this when connected
  final Widget onConnectedWall;

  /// Called on request Timeout
  final Function() onDisconnected;

  /// Called when user change networks (Wifi,mobile,etc)
  final Function(ConnectivityResult result) onConnectivityChanged;

  /// Constructor
  ConnectivityWall(
      {required this.onPingUrl,
      required this.responseCode,
      required this.onDisconnectedWall,
      required this.onConnectedWall,
      required this.onDisconnected,
      required this.onConnectivityChanged,
      required this.pingInterval});

  @override
  _ConnectivityWallState createState() => _ConnectivityWallState();
}

class _ConnectivityWallState extends State<ConnectivityWall> {
  /// Rebuild based
  bool _isConnected = false;
  Map<bool, int> _index = {false: 0, true: 1};

  final httpClient = http.Client();

  StreamSubscription<ConnectivityResult>? subscription;

  /// Call widget onConnectivityChanged
  void onChanged(ConnectivityResult result) {
    widget.onConnectivityChanged(result);

    /// Check connection
    ping();
  }

  /// Ping loop, every  pingInterval
  void pingLoop() {
    if (mounted) {
      ping();
      Future.delayed(
          Duration(seconds: widget.pingInterval),
          () => {
                pingLoop(),
              });
    }
  }

  void ping() {
    httpClient
        .head(widget.onPingUrl)
        .timeout(Duration(seconds: 30))
        .then((response) => {
              setState(() {
                _isConnected = (response.statusCode == widget.responseCode);
              })
            })
        .catchError((error) {
      setState(() {
        _isConnected = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    Connectivity()
        .checkConnectivity()
        .then((result) => {
              /// Call onConnectivityChanged
              onChanged(result),

              /// Subscribe to listen changes
              subscription =
                  Connectivity().onConnectivityChanged.listen(onChanged),
            })
        .then((_) => {
              /// Lets start pinging
              pingLoop(),
            });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      key: Key("_${_isConnected.toString()}"),
      index: _index[_isConnected],
      children: [widget.onDisconnectedWall, widget.onConnectedWall],
    );
  }
}
