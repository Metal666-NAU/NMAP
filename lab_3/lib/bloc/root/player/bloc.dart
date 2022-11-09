import 'dart:developer';
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';

import 'events.dart';
import 'state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc() : super(const PlayerState()) {
    on<PlayerLoaded>((event, emit) async {
      List<Directory> availableStorages =
          (await ExternalPath.getExternalStorageDirectories())
              .map((path) => Directory(path))
              .toList();

      emit(state.copyWith(
        availableStorages: () => availableStorages.map((storage) {
          String name = storage.path.substring("/storage/".length);

          if (name == "emulated/0") {
            name = "Internal Storage";
          }

          return Storage(
            directory: storage,
            name: name,
          );
        }).toList(),
      ));
    });
    on<PickExternalStorage>((event, emit) async {
      emit(state.copyWith(loadingStorage: () => event.storage));

      List<File>? allAudioFilesInCurrentStorage = await event.storage.directory
          .list(recursive: true)
          .handleError((error) => log(error.toString()))
          .where((entity) =>
              entity is File &&
              const [
                '.3gp',
                '.mp4',
                '.m4a',
                '.aac',
                '.ts',
                '.amr',
                '.flac',
                '.mid',
                '.xmf',
                '.mxmf',
                '.rtttl',
                '.rtx',
                '.ota',
                '.imy',
                '.mp3',
                '.mkv',
                '.ogg',
                '.wav',
              ].contains(extension(entity.path)))
          .cast<File>()
          .toList();

      emit(state.copyWith(
        currentStorage: () => event.storage,
        loadingStorage: () => null,
        currentDirectory: () => event.storage.directory,
        allAudioFilesInCurrentStorage: () => allAudioFilesInCurrentStorage,
        entitiesAtCurrentPath: () => getFilesSystemEntitiesAtPath(
          event.storage.directory.path,
          allAudioFilesInCurrentStorage,
        ),
      ));
    });
    on<PickDirectory>((event, emit) {
      bool clearCurrentDirectory = state.currentStorage == null ||
          split(event.directory.path).length <
              split(state.currentStorage!.directory.path).length;

      emit(state.copyWith(
        currentStorage: clearCurrentDirectory ? () => null : null,
        currentDirectory: () => clearCurrentDirectory ? null : event.directory,
        entitiesAtCurrentPath: () => clearCurrentDirectory
            ? null
            : getFilesSystemEntitiesAtPath(
                event.directory.path,
                state.allAudioFilesInCurrentStorage,
              ),
      ));
    });
  }

  List<FileSystemEntity> getFilesSystemEntitiesAtPath(
    String path,
    List<File> allFiles,
  ) {
    allFiles = allFiles.where((file) => file.path.startsWith(path)).toList();

    return allFiles
            .where((file) => file.parent.path == path)
            .toList()
            .cast<FileSystemEntity>() +
        allFiles
            .where((file) => !allFiles
                .where((file) => file.parent.path == path)
                .toList()
                .contains(file))
            .map((file) => (split(file.path)..length = split(path).length + 1)
                .reduce((value, element) => join(value, element)))
            .toSet()
            .map((path) => Directory(path))
            .toList()
            .cast<FileSystemEntity>();
  }
}
