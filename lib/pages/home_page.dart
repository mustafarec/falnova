import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _checkFirebase();
  }

  Future<void> _checkFirebase() async {
    await _firebaseService.checkFirebaseStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkFirebase,
          ),
        ],
      ),
      body: const Center(
        child: Text('Ana Sayfa İçeriği'),
      ),
    );
  }
}
