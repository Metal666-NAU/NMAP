import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
          Widget inputButton({required int index}) => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {},
                child: Text(index.toString()),
              );

          Widget actionButton({
            required String text,
            void Function()? onPressed,
            bool accent = false,
          }) =>
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      accent ? Theme.of(context).colorScheme.secondary : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onPressed,
                child: Text(text),
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
                        child: Text(
                          state.calculationElements
                              .map((element) => element.toString())
                              .join(),
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "=",
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          state.calculationResult?.toString() ?? "",
                          style: Theme.of(context).textTheme.displaySmall,
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
                    _panelCard(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            _pageSwipeButton(pageController: pageController, down: false),
            Expanded(
              child: _panelCard(
                child: Center(
                  child: Text(
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

  Widget _panelCard({Widget? child}) => Card(
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: child,
      );

  Widget _pageSwipeButton({
    required final PageController pageController,
    required final bool down,
  }) {
    const Duration duration = Duration(seconds: 1);
    const Curve curve = ElasticOutCurve(0.75);

    return IconButton(
      icon: Icon(down ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
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
