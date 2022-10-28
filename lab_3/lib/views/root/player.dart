import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import '../../bloc/root/player/bloc.dart';
import '../../bloc/root/player/state.dart';

class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) => _mainPanel(
        externalStoragePicker: (availableStorages) =>
            _externalStoragePicker(availableStorages: availableStorages),
        audioFilePicker: _audioFilePicker(),
      );

  Widget _mainPanel({
    required Widget Function(List<Directory>) externalStoragePicker,
    required Widget audioFilePicker,
  }) =>
      BlocBuilder<PlayerBloc, PlayerState>(
        buildWhen: (previous, current) =>
            current.currentPathWasSetOrCleared(previous),
        builder: (context, state) => state.currentPath == null
            ? BlocBuilder<PlayerBloc, PlayerState>(
                buildWhen: (previous, current) =>
                    previous.availableStorages != current.availableStorages,
                builder: (context, state) =>
                    externalStoragePicker(state.availableStorages),
              )
            : BlocBuilder<PlayerBloc, PlayerState>(
                builder: (context, state) => audioFilePicker),
      );

  Widget _externalStoragePicker({required List<Directory> availableStorages}) =>
      GridView.count(
        crossAxisCount: 2,
        children: availableStorages
            .map((storage) =>
                NeumorphicButton(onPressed: () {}, child: Text(storage.path)))
            .toList(),
      );

  Widget _audioFilePicker() => ListView();
}
