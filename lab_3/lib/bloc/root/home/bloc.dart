import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart';

import 'events.dart';
import 'state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  HomeBloc() : super(const HomeState()) {
    _audioPlayer.onPositionChanged.listen((event) async {
      if (state.currentAudioFile?.isSeeking == true) {
        return;
      }

      if (state.currentAudioFile?.duration == null) {
        add(const UpdatePlaybackProgress());

        return;
      }

      add(UpdatePlaybackProgress(event.inMilliseconds /
          state.currentAudioFile!.duration!.inMilliseconds));
    });

    _audioPlayer.onPlayerComplete.listen(
      (event) => add(const FinishedPlayback()),
    );

    on<HomeLoaded>((event, emit) async {
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

      List<AudioFileSystemEntity> entities =
          await getAudioFilesSystemEntitiesAtPath(
        event.storage.directory.path,
        allAudioFilesInCurrentStorage,
      );

      emit(state.copyWith(
        currentStorage: () => event.storage,
        loadingStorage: () => null,
        currentDirectory: () => event.storage.directory,
        allAudioFilesInCurrentStorage: () => allAudioFilesInCurrentStorage,
        entitiesAtCurrentPath: () => entities,
      ));
    });
    on<PickDirectory>((event, emit) async {
      bool clearCurrentDirectory = state.currentStorage == null ||
          split(event.directory.path).length <
              split(state.currentStorage!.directory.path).length;

      List<AudioFileSystemEntity>? entities = clearCurrentDirectory
          ? null
          : await getAudioFilesSystemEntitiesAtPath(
              event.directory.path,
              state.allAudioFilesInCurrentStorage,
            );

      emit(state.copyWith(
        currentStorage: clearCurrentDirectory ? () => null : null,
        currentDirectory: () => clearCurrentDirectory ? null : event.directory,
        entitiesAtCurrentPath: () => entities,
      ));
    });
    on<PlayFile>((event, emit) async {
      if (event.file.path == state.currentAudioFile?.path) {
        await _audioPlayer.seek(Duration.zero);

        return;
      }

      emit(state.copyWith(
        currentAudioFile: () => PlayingAudioFile(path: event.file.path),
      ));

      AudioFileMetadata? audioFileMetadata;

      if ([
        ".mp3",
        ".m4a",
        ".mp4",
        ".flac",
      ].contains(extension(event.file.path))) {
        final Metadata? metadata =
            await MetadataGod.getMetadata(event.file.path)
                .catchError((_) => null);

        if (metadata != null) {
          audioFileMetadata = AudioFileMetadata(
            title: metadata.title,
            artist: metadata.artist,
            album: metadata.album,
            albumArt: metadata.picture,
          );
        }
      }

      emit(state.copyWith(
        currentAudioFile: () => state.currentAudioFile?.copyWith(
            metadata: () => audioFileMetadata ?? const AudioFileMetadata()),
      ));

      await _audioPlayer.play(DeviceFileSource(event.file.path));

      Duration? duration = await _audioPlayer.getDuration();

      emit(state.copyWith(
        currentAudioFile: () => state.currentAudioFile?.copyWith(
          duration: () => duration,
          isPlaying: () => true,
        ),
      ));
    });
    on<UpdatePlaybackProgress>((event, emit) => emit(state.copyWith(
          currentAudioFile: () =>
              state.currentAudioFile?.copyWith(progress: () => event.progress),
        )));
    on<StartSeeking>((event, emit) => emit(state.copyWith(
        currentAudioFile: () =>
            state.currentAudioFile?.copyWith(isSeeking: () => true))));
    on<Seeking>((event, emit) => emit(state.copyWith(
        currentAudioFile: () =>
            state.currentAudioFile?.copyWith(progress: () => event.position))));
    on<FinishSeeking>((event, emit) {
      _audioPlayer.seek(
          (state.currentAudioFile?.duration ?? Duration.zero) * event.position);

      emit(state.copyWith(
          currentAudioFile: () =>
              state.currentAudioFile?.copyWith(isSeeking: () => false)));
    });
    on<TogglePlayback>(
      (event, emit) async {
        await (_audioPlayer.state == PlayerState.paused
            ? _audioPlayer.resume()
            : _audioPlayer.pause());

        emit(state.copyWith(
            currentAudioFile: () => state.currentAudioFile?.copyWith(
                isPlaying: (() => _audioPlayer.state == PlayerState.playing))));
      },
    );
    on<FinishedPlayback>((event, emit) async {
      await _audioPlayer.release();

      emit(state.copyWith(
        currentAudioFile: () => null,
        isPlayerExpanded: () => false,
      ));
    });
    on<ToggleExpandedPlayer>((event, emit) =>
        emit(state.copyWith(isPlayerExpanded: () => !state.isPlayerExpanded)));
  }

  Future<List<AudioFileSystemEntity>> getAudioFilesSystemEntitiesAtPath(
    String path,
    List<File> allFiles,
  ) async {
    allFiles = allFiles.where((file) => file.path.startsWith(path)).toList();

    return (await Future.wait(allFiles
                .where((file) => file.parent.path == path)
                .map((file) async => AudioFile(
                      file,
                      (await file.stat()).size,
                    ))
                .toList()))
            .cast<AudioFileSystemEntity>() +
        allFiles
            .where((file) => !allFiles
                .where((file) => file.parent.path == path)
                .toList()
                .contains(file))
            .map((file) => (split(file.path)..length = split(path).length + 1)
                .reduce((value, element) => join(value, element)))
            .toSet()
            .map((path) => AudioDirectory(
                  Directory(path),
                  allFiles.where((file) => file.path.startsWith(path)).length,
                ))
            .toList()
            .cast<AudioFileSystemEntity>();
  }
}
