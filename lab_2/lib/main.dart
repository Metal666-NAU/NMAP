import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/root/bloc.dart';
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
          colorScheme: const ColorScheme.dark(
            primary: Colors.deepPurple,
            onPrimary: Colors.white,
            secondary: Colors.red,
          ),
        ),
        home: Scaffold(
          body: BlocProvider(
            create: (context) => RootBloc(),
            child: const Root(),
          ),
        ),
      );
}
