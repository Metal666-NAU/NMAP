import 'package:flutter/material.dart';

import 'views/root.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Music Player (lab_3)',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: const Scaffold(body: Root()),
      );
}
