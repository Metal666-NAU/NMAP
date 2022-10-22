import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_expressions/math_expressions.dart';

import 'events.dart';
import 'state.dart';

class RootBloc extends Bloc<RootEvent, RootState> {
  RootBloc() : super(const RootState()) {
    on<AddOperation>((event, emit) => emit(state.copyWith(
          calculationElements: () => [
            ...state.calculationElements,
            OperationElement(event.operation),
          ],
        )));
    on<AddNumber>((event, emit) {
      List<CalculationElement> calculationElements =
          List.of(state.calculationElements);

      if (!state.hasCalculationElements() ||
          state.lastCalculationElementIsOperation()) {
        calculationElements.add(NumberElement(event.number));
      } else {
        calculationElements.last = NumberElement(BigInt.parse(
            "${(calculationElements.last as NumberElement).number}${event.number}"));
      }

      emit(state.copyWith(
        calculationElements: () => calculationElements,
      ));
    });
    on<RemoveElement>((event, emit) => emit(state.copyWith(
          calculationElements: () =>
              state.calculationElements.last is OperationElement ||
                      (state.calculationElements.last as NumberElement)
                              .number
                              .toString()
                              .length ==
                          1
                  ? (state.calculationElements
                      .take(state.calculationElements.length - 1)
                      .toList())
                  : (List.of(state.calculationElements)
                    ..last = NumberElement(BigInt.parse(
                        ((state.calculationElements.last as NumberElement)
                                .number
                                .toString()
                                .split("")
                              ..removeLast())
                            .join()))),
        )));
    on<ClearElements>((event, emit) => emit(state.copyWith(
          calculationResult: () => null,
          calculationElements: () => const [],
        )));
    on<Calculate>((event, emit) => emit(state.copyWith(
          calculationResult: () => Parser().parse(state.mathString()).evaluate(
                EvaluationType.REAL,
                ContextModel(),
              ),
        )));
  }
}
