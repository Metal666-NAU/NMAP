import 'dart:io';

class PlayerState {
  final List<Storage> availableStorages;
  final Storage? currentStorage;
  final Storage? loadingStorage;
  final Directory? currentDirectory;
  final List<File> allAudioFilesInCurrentStorage;
  final List<FileSystemEntity>? entitiesAtCurrentPath;

  const PlayerState({
    this.availableStorages = const [],
    this.currentStorage,
    this.loadingStorage,
    this.currentDirectory,
    this.allAudioFilesInCurrentStorage = const [],
    this.entitiesAtCurrentPath = const [],
  });

  bool currentStorageWasSetOrCleared(PlayerState previousState) =>
      previousState.currentStorage != currentStorage &&
      (previousState.currentStorage == null || currentStorage == null);

  PlayerState copyWith({
    List<Storage> Function()? availableStorages,
    Storage? Function()? currentStorage,
    Storage? Function()? loadingStorage,
    Directory? Function()? currentDirectory,
    List<File> Function()? allAudioFilesInCurrentStorage,
    List<FileSystemEntity>? Function()? entitiesAtCurrentPath,
  }) =>
      PlayerState(
        availableStorages: availableStorages == null
            ? this.availableStorages
            : availableStorages.call(),
        currentStorage: currentStorage == null
            ? this.currentStorage
            : currentStorage.call(),
        loadingStorage: loadingStorage == null
            ? this.loadingStorage
            : loadingStorage.call(),
        currentDirectory: currentDirectory == null
            ? this.currentDirectory
            : currentDirectory.call(),
        allAudioFilesInCurrentStorage: allAudioFilesInCurrentStorage == null
            ? this.allAudioFilesInCurrentStorage
            : allAudioFilesInCurrentStorage.call(),
        entitiesAtCurrentPath: entitiesAtCurrentPath == null
            ? this.entitiesAtCurrentPath
            : entitiesAtCurrentPath.call(),
      );
}

class Storage {
  final Directory directory;
  final String name;

  const Storage({
    required this.directory,
    required this.name,
  });
}
