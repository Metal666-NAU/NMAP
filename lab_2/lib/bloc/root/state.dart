class RootState {
  final double? calculationResult;
  final List<CalculationElement> calculationElements;

  const RootState({
    this.calculationResult,
    this.calculationElements = const [],
  });

  bool hasCalculationElements() => calculationElements.isNotEmpty;

  bool lastCalculationElementIsOperation() => !hasCalculationElements()
      ? false
      : calculationElements.last is OperationElement;

  RootState copyWith({
    double? Function()? calculationResult,
    List<CalculationElement> Function()? calculationElements,
  }) =>
      RootState(
        calculationResult: calculationResult == null
            ? this.calculationResult
            : calculationResult.call(),
        calculationElements: calculationElements == null
            ? this.calculationElements
            : calculationElements.call(),
      );
}

abstract class CalculationElement {
  const CalculationElement();
}

class NumberElement extends CalculationElement {
  final num number;

  const NumberElement(this.number);

  @override
  String toString() => number.toString();
}

class OperationElement extends CalculationElement {
  final Operation operation;

  const OperationElement(this.operation);

  @override
  String toString() => operation.textRepresentation;
}

enum Operation {
  add("+"),
  subtract("-"),
  multiply("×"),
  divide("/");

  final String textRepresentation;

  const Operation(this.textRepresentation);
}
