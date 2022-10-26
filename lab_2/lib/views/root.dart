import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/root/bloc.dart';
import '../bloc/root/events.dart';
import '../bloc/root/state.dart';

class Root extends HookWidget {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController pageController = usePageController();

    return SafeArea(
      child: PageView(
        controller: pageController,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        children: [
          _calculatorPage(pageController),
          _resultsPage(pageController),
          _otherPage(pageController),
        ],
      ),
    );
  }

  Widget _calculatorPage(final PageController pageController) =>
      BlocBuilder<RootBloc, RootState>(
        builder: (context, state) {
          Widget smallButton({
            required String text,
            void Function()? onPressed,
            bool accent = false,
          }) =>
              Expanded(
                child: NeumorphicButton(
                  style: NeumorphicStyle(
                    color: onPressed == null
                        ? NeumorphicTheme.disabledColor(context)
                        : accent
                            ? NeumorphicTheme.accentColor(context)
                            : null,
                    shape: NeumorphicShape.flat,
                    depth: accent ? -6 : null,
                    boxShape: const NeumorphicBoxShape.stadium(),
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 14,
                  ),
                  onPressed: onPressed,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w200,
                      color: accent
                          ? NeumorphicTheme.of(context)
                              ?.value
                              .darkTheme
                              ?.defaultTextColor
                          : null,
                    ),
                  ),
                ),
              );

          Widget bigButton({
            void Function()? onPressed,
            int? index,
            String? text,
            IconData? icon,
          }) =>
              NeumorphicButton(
                style: NeumorphicStyle(
                  color: onPressed == null
                      ? NeumorphicTheme.disabledColor(context)
                      : index == null
                          ? NeumorphicTheme.accentColor(context)
                          : null,
                  shape: NeumorphicShape.concave,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(30),
                  ),
                ),
                onPressed: onPressed,
                child: Center(
                  child: Builder(builder: (context) {
                    if (index != null) {
                      return Text(
                        index.toString(),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w200,
                        ),
                      );
                    }
                    if (text != null) {
                      return Text(
                        text,
                        style: TextStyle(
                          color: NeumorphicTheme.of(context)
                              ?.value
                              .darkTheme
                              ?.defaultTextColor,
                          fontSize: 30,
                          fontWeight: FontWeight.w200,
                        ),
                      );
                    }
                    if (icon != null) {
                      return Icon(
                        icon,
                        color: NeumorphicTheme.of(context)
                            ?.value
                            .darkTheme
                            ?.defaultTextColor,
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ),
              );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          state.calculationElements.join(),
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                      const Text(
                        "=",
                        style: TextStyle(fontSize: 48, height: 0.7),
                      ),
                      Expanded(
                        child: FittedBox(
                          child: Text(
                            state.calculationResultFormatted(" "),
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onVerticalDragUpdate: (details) {},
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: Operation.values
                            .map((operation) => smallButton(
                                  text: operation.textRepresentation,
                                  onPressed: !state.hasCalculationElements() ||
                                          state
                                              .lastCalculationElementIsOperation()
                                      ? null
                                      : () => context
                                          .read<RootBloc>()
                                          .add(AddOperation(operation)),
                                ))
                            .toList()
                          ..add(smallButton(
                            text: "=",
                            onPressed: !state.hasCalculationElements() ||
                                    state.lastCalculationElementIsOperation()
                                ? null
                                : () =>
                                    context.read<RootBloc>().add(Calculate()),
                            accent: true,
                          )),
                      ),
                    ),
                    _panelCard(
                      padding: 20,
                      child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List<Widget>.generate(
                          9,
                          (index) => bigButton(
                            onPressed: () => context
                                .read<RootBloc>()
                                .add(AddNumber(BigInt.from(index + 1))),
                            index: index + 1,
                          ),
                        )..addAll([
                            bigButton(
                              onPressed: !state.hasCalculationElements()
                                  ? null
                                  : () => context
                                      .read<RootBloc>()
                                      .add(ClearElements()),
                              text: "C",
                            ),
                            bigButton(
                              onPressed: () => context
                                  .read<RootBloc>()
                                  .add(AddNumber(BigInt.from(0))),
                              index: 0,
                            ),
                            bigButton(
                              onPressed: !state.hasCalculationElements()
                                  ? null
                                  : () => context
                                      .read<RootBloc>()
                                      .add(RemoveElement()),
                              icon: Icons.backspace,
                            ),
                          ]),
                      ),
                    ),
                  ],
                ),
              ),
              _pageSwipeButton(
                pageController: pageController,
                down: true,
              ),
            ],
          );
        },
      );

  Widget _resultsPage(final PageController pageController) =>
      BlocBuilder<RootBloc, RootState>(
        builder: (context, state) => Column(
          children: [
            _pageSwipeButton(
              pageController: pageController,
              down: false,
            ),
            Expanded(
              child: _panelCard(
                padding: 16,
                child: Center(
                  child: FittedBox(
                    child: Text(
                      state.calculationResultFormatted("Немає відповіді"),
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 6,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _pageSwipeButton(
              pageController: pageController,
              down: true,
            ),
          ],
        ),
      );

  Widget _otherPage(final PageController pageController) {
    Widget bigText(
      String text,
      BuildContext context,
    ) =>
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 36, fontFeatures: [FontFeature.enable('smcp')]),
        );

    Widget link(
      String name,
      String url,
      BuildContext context,
    ) =>
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 2,
            horizontal: 0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              NeumorphicButton(
                style: const NeumorphicStyle(depth: -4),
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 16,
                ),
                onPressed: () async => await launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication),
                child: Icon(
                  Icons.arrow_forward,
                  color: NeumorphicTheme.defaultTextColor(context),
                ),
              ),
            ],
          ),
        );

    Widget separator() => const SizedBox(height: 6);

    return Builder(
        builder: (context) => Column(
              children: [
                _pageSwipeButton(
                  pageController: pageController,
                  down: false,
                ),
                Expanded(
                  child: _panelCard(
                    padding: 16,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          bigText(
                            'project home',
                            context,
                          ),
                          link(
                            "lab_2",
                            "https://github.com/Metal666-NAU/NMAP/tree/main/lab_2",
                            context,
                          ),
                          separator(),
                          bigText(
                            'used libraries',
                            context,
                          ),
                          link(
                            "auto_size_text",
                            "https://pub.dev/packages/auto_size_text",
                            context,
                          ),
                          link(
                            "flutter_bloc",
                            "https://pub.dev/packages/flutter_bloc",
                            context,
                          ),
                          link(
                            "flutter_hooks",
                            "https://pub.dev/packages/flutter_hooks",
                            context,
                          ),
                          link(
                            "flutter_neumorphic",
                            "https://pub.dev/packages/flutter_neumorphic",
                            context,
                          ),
                          link(
                            "line_icons",
                            "https://pub.dev/packages/line_icons",
                            context,
                          ),
                          link(
                            "math_expressions",
                            "https://pub.dev/packages/math_expressions",
                            context,
                          ),
                          link(
                            "url_launcher",
                            "https://pub.dev/packages/url_launcher",
                            context,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ));
  }

  Widget _panelCard({
    bool raised = true,
    double padding = 0,
    Widget? child,
  }) =>
      Neumorphic(
        margin: const EdgeInsets.all(10),
        style: NeumorphicStyle(
          shape: NeumorphicShape.convex,
          depth: raised ? null : -4,
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: child,
        ),
      );

  Widget _pageSwipeButton({
    required final PageController pageController,
    required final bool down,
  }) {
    const Duration duration = Duration(seconds: 1);
    const Curve curve = ElasticOutCurve(0.75);

    return Center(
      child: NeumorphicButton(
        margin: const EdgeInsets.all(10),
        style: const NeumorphicStyle(depth: -4),
        child: Builder(
          builder: (context) => Icon(
            down ? LineIcons.angleUp : LineIcons.angleDown,
            size: 25,
            color: NeumorphicTheme.defaultTextColor(context),
          ),
        ),
        onPressed: () => down
            ? pageController.nextPage(
                duration: duration,
                curve: curve,
              )
            : pageController.previousPage(
                duration: duration,
                curve: curve,
              ),
      ),
    );
  }
}
