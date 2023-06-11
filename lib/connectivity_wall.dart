library connectivity_wall;

import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// ConnectivityWall widget
class ConnectivityWall extends StatefulWidget {
  /// We make a HEAD request to url every pingInterval
  final Uri onPingUrl;
  ///Interval in secs to check the onPingUrl
  final int pingInterval;

  /// Expect this response code from pingUrl
  final List<int> responseCode;

  /// build this when disconnected
  final Widget onDisconnectedWall;

  /// build this when connected
  final Widget onConnectedWall;

  /// Called on request Timeout
  final Function() onDisconnected;

  /// Return the ping response status code
  final Function(int statusCode) onPingResponse;

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
      required this.pingInterval,
      required this.onPingResponse});

  @override
  _ConnectivityWallState createState() => _ConnectivityWallState();
}

class _ConnectivityWallState extends State<ConnectivityWall> {
  /// Rebuild based
  bool _isConnected = true;
  Map<bool, int> _index = {false: 0, true: 1};

  StreamSubscription<ConnectivityResult>? subscription;

  Future<http.Response> requestHead(
      Uri url, Map<String, String> requestHeaders) async {
    try {
      final request = await http.Client()
          .head(url, headers: requestHeaders)
          .timeout(const Duration(seconds: 60));
      return request;
    } on TimeoutException catch (e) {
      return http.Response(e.toString(), 408);
    } on SocketException catch (e) {
      return http.Response(e.toString(), 500);
    } on Exception catch (e) {
      return http.Response(e.toString(), 500);
    }
  }

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

  Future<void> ping() async {

    final resposta = await requestHead(widget.onPingUrl, {});
    if (mounted) {
      setState(() {
        _isConnected = (widget.responseCode.contains(resposta.statusCode));
      });
      widget.onPingResponse(resposta.statusCode);
      if(!_isConnected) {
        widget.onDisconnected();
      }


    }
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
      index: _index[_isConnected],
      children: [widget.onDisconnectedWall, widget.onConnectedWall],
    );
  }
}
