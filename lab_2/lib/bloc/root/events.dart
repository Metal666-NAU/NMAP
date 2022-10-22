import 'state.dart';

abstract class RootEvent {}

class AddOperation extends RootEvent {
  final Operation operation;

  AddOperation(this.operation);
}

class AddNumber extends RootEvent {
  final BigInt number;

  AddNumber(this.number);
}

class RemoveElement extends RootEvent {}

class ClearElements extends RootEvent {}

class Calculate extends RootEvent {}
