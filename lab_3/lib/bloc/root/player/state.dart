import 'dart:io';

class PlayerState {
  final List<Directory> availableStorages;
  final String? currentPath;

  const PlayerState({
    this.availableStorages = const [],
    this.currentPath,
  });

  bool currentPathWasSetOrCleared(PlayerState previousState) =>
      previousState.currentPath != currentPath &&
      (previousState.currentPath == null || currentPath == null);

  PlayerState copyWith({
    List<Directory> Function()? availableStorages,
    String? Function()? currentPath,
  }) =>
      PlayerState(
        availableStorages: availableStorages == null
            ? this.availableStorages
            : availableStorages.call(),
        currentPath:
            currentPath == null ? this.currentPath : currentPath.call(),
      );
}
