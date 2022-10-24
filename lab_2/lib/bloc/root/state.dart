class RootState {
  final double? calculationResult;
  final List<CalculationElement> calculationElements;

  const RootState({
    this.calculationResult,
    this.calculationElements = const [],
  });

  bool hasCalculationElements() => calculationElements.isNotEmpty;

  bool lastCalculationElementIsOperation() =>
      hasCalculationElements() && calculationElements.last is OperationElement;

  String mathString() =>
      calculationElements.map((element) => element.toMathString()).join();

  String calculationResultFormatted(String resultIfNull) =>
      calculationResult == null
          ? resultIfNull
          : RegExp(r'^(\d+(?:\.\d*?[1-9](?=0|\b))?)\.?0*$')
                  .firstMatch(calculationResult.toString())
                  ?.group(1) ??
              resultIfNull;

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

  String toMathString();
}

class NumberElement extends CalculationElement {
  final BigInt number;

  const NumberElement(this.number);

  @override
  String toString() => number.toString();

  @override
  String toMathString() => number.toString();
}

class OperationElement extends CalculationElement {
  final Operation operation;

  const OperationElement(this.operation);

  @override
  String toString() => operation.textRepresentation;

  @override
  String toMathString() => operation.mathRepresentation;
}

enum Operation {
  add("+", "+"),
  subtract("-", "-"),
  multiply("×", "*"),
  divide("/", "/");

  final String textRepresentation;
  final String mathRepresentation;

  const Operation(
    this.textRepresentation,
    this.mathRepresentation,
  );
}
