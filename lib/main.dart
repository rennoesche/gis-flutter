import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Provinsi di Indonesia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Peta Ibukota Provinsi di Indonesia'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Marker> markers = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore.collection('locations').get();
    setState(() {
      markers.addAll(querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Marker(
          point: LatLng(data['latitude'], data['longitude']),
          builder: (ctx) => const Icon(Icons.location_on, color: Colors.red),
        );
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton:
          ElevatedButton(onPressed: addLocations, child: Text('Tambah data')),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(-2.548926, 118.0148634), // Pusat Indonesia
          zoom: 5.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            maxZoom: 15.0,
          ),
          MarkerLayer(
            markers: markers,
          )
        ],
      ),
    );
  }
}

void addLocations() async {
  final locations = [
    {
      'province': 'DKI Jakarta',
      'capital': 'Jakarta',
      'latitude': -6.208763,
      'longitude': 106.845599,
    },
    {
      'province': 'Jawa Barat',
      'capital': 'Bandung',
      'latitude': -6.917464,
      'longitude': 107.619123,
    },
    {
      'province': 'Jawa Timur',
      'capital': 'Surabaya',
      'latitude': -7.257472,
      'longitude': 112.752088,
    },
    {
      'province': 'Jawa Tengah',
      'capital': 'Semarang',
      'latitude': -6.993236,
      'longitude': 110.420363,
    },
    {
      'province': 'Yogyakarta',
      'capital': 'Yogyakarta',
      'latitude': -7.795580,
      'longitude': 110.369489,
    },
  ];

  final firestore = FirebaseFirestore.instance;

  for (var location in locations) {
    await firestore.collection('locations').add(location);
  }
}
