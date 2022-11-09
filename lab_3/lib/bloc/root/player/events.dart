import 'dart:io';

import 'state.dart';

abstract class PlayerEvent {
  const PlayerEvent();
}

class PlayerLoaded extends PlayerEvent {
  const PlayerLoaded();
}

class PickExternalStorage extends PlayerEvent {
  final Storage storage;

  const PickExternalStorage(this.storage);
}

class PickDirectory extends PlayerEvent {
  final Directory directory;

  const PickDirectory(this.directory);
}
