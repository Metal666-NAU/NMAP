abstract class RootEvent {}

class AddOperationEvent extends RootEvent {
  final String operation;

  AddOperationEvent(this.operation);
}

class RemoveOperationEvent extends RootEvent {}
