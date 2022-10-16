import 'package:flutter_bloc/flutter_bloc.dart';

import 'events.dart';
import 'state.dart';

class RootBloc extends Bloc<RootEvent, RootState> {
  RootBloc() : super(const RootState()) {
    on<AddOperationEvent>((event, emit) => emit(state.copyWith(
          calculationElements: () => [
            ...state.calculationElements,
            OperationElement(event.operation),
          ],
        )));
    on<AddNumberEvent>((event, emit) => emit(state.copyWith(
          calculationElements: () => [
            ...state.calculationElements,
            NumberElement(event.number),
          ],
        )));
    on<RemoveElementEvent>((event, emit) => emit(state.copyWith(
          calculationElements: () => state.calculationElements
              .take(state.calculationElements.length - 1)
              .toList(),
        )));
    on<ClearElementsEvent>((event, emit) =>
        emit(state.copyWith(calculationElements: () => const [])));
  }
}
