import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'util/color_extensions.dart';

import 'bloc/root/bloc.dart';
import 'views/root.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => NeumorphicApp(
        title: 'Calculator (lab_2)',
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
            create: (context) => RootBloc(),
            child: const Root(),
          ),
        ),
      );
}
