# connectivity_wall

A Connectivity wall monitor

## Getting Started

Connectivity wall redirect user to a widget when offline and another if online


```
import 'package:flutter/material.dart';
import 'package:connectivity_wall/connectivity_wall.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ConnectivityWall(
          pingInterval: 120,
          responseCode: 200,
          onPingUrl: Uri.parse("https://pub.dev/"),

          /// Connectedwall
          onConnectedWall: OnlineState(),
          /// User changed from wifi to data or else
          onConnectivityChanged: (result) {
            // ConnectivityResult.mobile
            // ConnectivityResult.wifi
            // ConnectivityResult.none
            print(result);
          },

          /// Disconnected callback
          onDisconnected: () {
            print("Offline, do something");
          },

          /// Disconnected Widget wall
          onDisconnectedWall: OfflineState(),
        ));
  }
}

class OfflineState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Center(
          child: Text("Not connected to internet"),
        ),
      ),
    );
  }
}


class OnlineState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Center(
          child: Text("Connected "),
        ),
      ),
    );
  }
}


```