import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:lab_3/bloc/root/events.dart';

import 'bloc/root/bloc.dart';
import 'util/color_extensions.dart';
import 'views/root.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => NeumorphicApp(
        title: 'Music Player (lab_3)',
        theme: NeumorphicThemeData(
          accentColor: Colors.deepPurple.shade400,
          variantColor: Colors.red,
          disabledColor: NeumorphicColors.background.darken(5),
        ),
        darkTheme: NeumorphicThemeData.dark(
          accentColor: Colors.deepPurple.shade400,
          variantColor: Colors.red,
          disabledColor: NeumorphicColors.darkBackground.lighten(15),
          shadowLightColor: Colors.black87,
          shadowLightColorEmboss: Colors.black87,
        ),
        home: Scaffold(
          body: BlocProvider(
            create: (context) => RootBloc()..add(AppStarted()),
            child: const Root(),
          ),
        ),
      );
}
