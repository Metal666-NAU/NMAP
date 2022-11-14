import 'dart:io';

import 'package:metadata_god/metadata_god.dart';

class HomeState {
  final List<Storage> availableStorages;
  final Storage? currentStorage;
  final Storage? loadingStorage;
  final Directory? currentDirectory;
  final List<File> allAudioFilesInCurrentStorage;
  final List<FileSystemEntity>? entitiesAtCurrentPath;
  final AudioFile? currentAudioFile;
  final bool isPlayerExpanded;

  const HomeState({
    this.availableStorages = const [],
    this.currentStorage,
    this.loadingStorage,
    this.currentDirectory,
    this.allAudioFilesInCurrentStorage = const [],
    this.entitiesAtCurrentPath = const [],
    this.currentAudioFile,
    this.isPlayerExpanded = false,
  });

  bool currentStorageWasSetOrCleared(HomeState previousState) =>
      previousState.currentStorage != currentStorage &&
      (previousState.currentStorage == null || currentStorage == null);

  HomeState copyWith({
    List<Storage> Function()? availableStorages,
    Storage? Function()? currentStorage,
    Storage? Function()? loadingStorage,
    Directory? Function()? currentDirectory,
    List<File> Function()? allAudioFilesInCurrentStorage,
    List<FileSystemEntity>? Function()? entitiesAtCurrentPath,
    AudioFile? Function()? currentAudioFile,
    bool Function()? isPlayerExpanded,
  }) =>
      HomeState(
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
        currentAudioFile: currentAudioFile == null
            ? this.currentAudioFile
            : currentAudioFile.call(),
        isPlayerExpanded: isPlayerExpanded == null
            ? this.isPlayerExpanded
            : isPlayerExpanded.call(),
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

class AudioFile {
  final String path;
  final AudioFileMetadata? metadata;
  final double? progress;
  final Duration? duration;
  final bool isPlaying;
  final bool isSeeking;

  AudioFile({
    required this.path,
    this.metadata,
    this.progress,
    this.duration,
    this.isPlaying = false,
    this.isSeeking = false,
  });

  AudioFile copyWith({
    String Function()? path,
    AudioFileMetadata? Function()? metadata,
    double? Function()? progress,
    Duration? Function()? duration,
    bool Function()? isPlaying,
    bool Function()? isSeeking,
  }) =>
      AudioFile(
        path: path == null ? this.path : path.call(),
        metadata: metadata == null ? this.metadata : metadata.call(),
        progress: progress == null ? this.progress : progress.call(),
        duration: duration == null ? this.duration : duration.call(),
        isPlaying: isPlaying == null ? this.isPlaying : isPlaying.call(),
        isSeeking: isSeeking == null ? this.isSeeking : isSeeking.call(),
      );
}

class AudioFileMetadata {
  final String? title;
  final String? artist;
  final String? album;
  final Image? albumArt;

  const AudioFileMetadata({
    this.title,
    this.artist,
    this.album,
    this.albumArt,
  });
}
