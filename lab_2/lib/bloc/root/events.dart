import 'state.dart';

abstract class RootEvent {}

class AddOperationEvent extends RootEvent {
  final Operation operation;

  AddOperationEvent(this.operation);
}

class AddNumberEvent extends RootEvent {
  final num number;

  AddNumberEvent(this.number);
}

class RemoveElementEvent extends RootEvent {}

class ClearElementsEvent extends RootEvent {}
