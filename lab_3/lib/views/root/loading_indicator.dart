import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with TickerProviderStateMixin {
  late final AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => CircularProgressIndicator(
        valueColor: animationController.drive(ColorTween(
          begin: NeumorphicTheme.accentColor(context),
          end: NeumorphicTheme.variantColor(context),
        )),
      );

  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }
}
