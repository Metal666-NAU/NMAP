import 'package:flutter/material.dart';

import 'views/root.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Calculator (lab_2)',
        theme: ThemeData(
          primarySwatch: Colors.purple,
        ),
        home: const Scaffold(body: Root()),
      );
}
