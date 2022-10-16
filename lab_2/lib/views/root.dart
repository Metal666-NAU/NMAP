import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import '../bloc/root/bloc.dart';
import '../bloc/root/state.dart';

class Root extends HookWidget {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController pageController = usePageController();

    return PageView(
      controller: pageController,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      children: [
        _calculatorPage(pageController),
        _resultsPage(pageController),
      ],
    );
  }

  Widget _calculatorPage(final PageController pageController) =>
      BlocBuilder<RootBloc, RootState>(
        builder: (context, state) {
          Widget actionButton({
            required String text,
            void Function()? onPressed,
            bool accent = false,
          }) =>
              Expanded(
                child: NeumorphicButton(
                  style: NeumorphicStyle(
                    color: accent ? NeumorphicTheme.accentColor(context) : null,
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
                  child: Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 25,
                        color: accent
                            ? NeumorphicTheme.of(context)
                                ?.value
                                .darkTheme
                                ?.defaultTextColor
                            : null,
                      ),
                    ),
                  ),
                ),
              );

          Widget inputButton({required int index}) => NeumorphicButton(
                style: NeumorphicStyle(
                  shape: NeumorphicShape.concave,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {},
                child: Center(
                  child: Text(
                    index.toString(),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              );

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: NeumorphicText(
                          state.calculationElements
                              .map((element) => element.toString())
                              .join(),
                          textStyle: NeumorphicTextStyle(fontSize: 48),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Expanded(
                        child: NeumorphicText(
                          "=",
                          textStyle: NeumorphicTextStyle(fontSize: 48),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Expanded(
                        child: NeumorphicText(
                          state.calculationResult?.toString() ?? "",
                          textStyle: NeumorphicTextStyle(fontSize: 48),
                          textAlign: TextAlign.end,
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
                            .map((operation) => actionButton(
                                  text: operation.textRepresentation,
                                  onPressed: () {},
                                ))
                            .toList()
                          ..add(actionButton(
                            text: "=",
                            onPressed: () {},
                            accent: true,
                          )),
                      ),
                    ),
                    _panelCard(
                      child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(20),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List<Widget>.generate(
                          9,
                          (index) => inputButton(index: index),
                        )..addAll([
                            Container(),
                            inputButton(index: 0),
                            Container(),
                          ]),
                      ),
                    ),
                  ],
                ),
              ),
              _pageSwipeButton(pageController: pageController, down: true),
            ],
          );
        },
      );

  Widget _resultsPage(final PageController pageController) =>
      BlocBuilder<RootBloc, RootState>(
        builder: (context, state) => Column(
          children: [
            const SizedBox(height: 25),
            _pageSwipeButton(pageController: pageController, down: false),
            Expanded(
              child: _panelCard(
                child: Center(
                  child: NeumorphicText(
                    state.calculationResult == null
                        ? "Немає відповіді"
                        : state.calculationResult.toString(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _panelCard({bool raised = true, Widget? child}) => Neumorphic(
        margin: const EdgeInsets.all(10),
        style: NeumorphicStyle(
          shape: NeumorphicShape.convex,
          depth: raised ? null : -4,
        ),
        child: child,
      );

  Widget _pageSwipeButton({
    required final PageController pageController,
    required final bool down,
  }) {
    const Duration duration = Duration(seconds: 1);
    const Curve curve = ElasticOutCurve(0.75);

    return NeumorphicButton(
      margin: const EdgeInsets.all(10),
      style: const NeumorphicStyle(depth: -4),
      child: Builder(
        builder: (context) => Icon(
          down ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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
    );
  }
}
