import 'dart:io';

import 'state.dart';

abstract class HomeEvent {
  const HomeEvent();
}

class HomeLoaded extends HomeEvent {
  const HomeLoaded();
}

class PickExternalStorage extends HomeEvent {
  final Storage storage;

  const PickExternalStorage(this.storage);
}

class PickDirectory extends HomeEvent {
  final Directory directory;

  const PickDirectory(this.directory);
}

class PlayFile extends HomeEvent {
  final File file;

  const PlayFile(this.file);
}

class UpdatePlaybackProgress extends HomeEvent {
  final double? progress;

  const UpdatePlaybackProgress([this.progress]);
}

class StartSeeking extends HomeEvent {
  const StartSeeking();
}

class Seeking extends HomeEvent {
  final double position;

  const Seeking(this.position);
}

class FinishSeeking extends HomeEvent {
  final double position;

  const FinishSeeking(this.position);
}

class TogglePlayback extends HomeEvent {
  const TogglePlayback();
}

class FinishedPlayback extends HomeEvent {
  const FinishedPlayback();
}
