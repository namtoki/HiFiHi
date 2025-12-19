import 'package:flutter/material.dart';
import 'screens/broadcast_list_screen.dart';

void main() {
  runApp(const AuracastHubApp());
}

class AuracastHubApp extends StatelessWidget {
  const AuracastHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auracast Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BroadcastListScreen(),
    );
  }
}
