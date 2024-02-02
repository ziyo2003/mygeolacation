import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Location Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  final double latitude2 = 48.8584;
  final double longitude2 = 2.2945;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position? firstPosition;
  Position? secondPosition;
  double? distanceInMeters;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    final position = await Geolocator.getCurrentPosition();
    return position;
  }

  void _calculateDistance() {
    if (firstPosition != null && secondPosition != null) {
      distanceInMeters = Geolocator.distanceBetween(
        firstPosition!.latitude,
        firstPosition!.longitude,
        secondPosition!.latitude,
        secondPosition!.longitude,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'First Position: ${firstPosition?.latitude}, ${firstPosition?.longitude}\n'
                  'Second Position: ${secondPosition?.latitude}, ${secondPosition?.longitude}\n'
                  'Distance: ${distanceInMeters?.toStringAsFixed(2)} meters',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: () async {
                final position = await _determinePosition();
                setState(() {
                  firstPosition = position;
                });
              },
              child: const Text('Set First Position'),
            ),
            ElevatedButton(
              onPressed: () async {
                final position = await _determinePosition();
                setState(() {
                  secondPosition = position;
                  if (firstPosition != null) {
                    _calculateDistance();
                  }
                });
              },
              child: const Text('Set Second Position'),
            ),
          ],
        ),
      ),
    );
  }
}
