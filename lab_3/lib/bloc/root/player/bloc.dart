import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        availableStorages: () => availableStorages,
      ));
    });
  }
}
