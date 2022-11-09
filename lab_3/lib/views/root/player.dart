import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:path/path.dart';

import '../../bloc/root/player/bloc.dart';
import '../../bloc/root/player/events.dart';
import '../../bloc/root/player/state.dart';
import 'loading_indicator.dart';

class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) => _mainPanel(
        externalStoragePicker: (
          context,
          availableStorages,
          loadingStorage,
        ) =>
            _externalStoragePicker(
          context: context,
          availableStorages: availableStorages,
          loadingStorage: loadingStorage,
          externalStorageButton: _externalStorageButton,
        ),
        filePicker: (
          context,
          currentStorage,
          currentDirectory,
          availableItems,
        ) =>
            _filePicker(
          breadCrumbRow: _breadCrumbRow(
            context: context,
            currentStorage: currentStorage,
            currentDirectory: currentDirectory,
            pathBreadCrumb: _pathBreadCrumb,
          ),
          fileList: _fileList(
            context: context,
            currentDirectory: currentDirectory,
            availableItems: availableItems,
            directoryUpItem: _directoryUpItem,
            fileSystemItem: _fileSystemItem,
          ),
        ),
      );

  Widget _mainPanel({
    required Widget Function(
      BuildContext context,
      List<Storage> availableStorages,
      Storage? loadingStorage,
    )
        externalStoragePicker,
    required Widget Function(
      BuildContext context,
      Storage currentStorage,
      Directory currentDirectory,
      List<FileSystemEntity> availableItems,
    )
        filePicker,
  }) =>
      BlocBuilder<PlayerBloc, PlayerState>(
        buildWhen: (previous, current) =>
            current.currentStorageWasSetOrCleared(previous) ||
            previous.availableStorages != current.availableStorages ||
            previous.loadingStorage != current.loadingStorage ||
            previous.currentDirectory != current.currentDirectory,
        builder: (context, state) => state.currentStorage == null
            ? externalStoragePicker(
                context,
                state.availableStorages,
                state.loadingStorage,
              )
            : filePicker(
                context,
                state.currentStorage!,
                state.currentDirectory!,
                state.entitiesAtCurrentPath ?? [],
              ),
      );

  Widget _externalStoragePicker({
    required BuildContext context,
    required List<Storage> availableStorages,
    required Storage? loadingStorage,
    required Widget Function(
      BuildContext context,
      Storage storage,
      Storage? loadingStorage,
    )
        externalStorageButton,
  }) =>
      GridView.count(
        crossAxisCount: 2,
        children: availableStorages
            .map((storage) => externalStorageButton(
                  context,
                  storage,
                  loadingStorage,
                ))
            .toList(),
      );

  Widget _externalStorageButton(
    BuildContext context,
    Storage storage,
    Storage? loadingStorage,
  ) =>
      NeumorphicButton(
        onPressed: loadingStorage != null
            ? null
            : () =>
                context.read<PlayerBloc>().add(PickExternalStorage(storage)),
        child: storage == loadingStorage
            ? const LoadingIndicator()
            : Text(storage.name),
      );

  Widget _filePicker({
    required Widget breadCrumbRow,
    required Widget fileList,
  }) =>
      Column(
        children: [
          breadCrumbRow,
          Expanded(
            child: fileList,
          ),
        ],
      );

  BreadCrumb _breadCrumbRow({
    required BuildContext context,
    required Storage currentStorage,
    required Directory currentDirectory,
    required BreadCrumbItem Function(
      BuildContext context,
      Directory directory,
      String? contentOverride,
    )
        pathBreadCrumb,
  }) =>
      BreadCrumb(
        items: [
          pathBreadCrumb(
            context,
            currentStorage.directory,
            currentStorage.name,
          ),
          ...() {
            Directory directory = currentDirectory;
            List<Directory> directories = [];

            while (directory.path != currentStorage.directory.path) {
              directories.insert(0, directory);

              directory = directory.parent;
            }

            return directories;
          }()
              .map((directory) => pathBreadCrumb(
                    context,
                    directory,
                    null,
                  )),
        ],
        divider: Icon(
          Icons.chevron_right,
          color: NeumorphicTheme.defaultTextColor(context),
        ),
      );

  BreadCrumbItem _pathBreadCrumb(
    BuildContext context,
    Directory directory,
    String? contentOverride,
  ) =>
      BreadCrumbItem(
        onTap: () => context.read<PlayerBloc>().add(PickDirectory(directory)),
        content: Text(contentOverride ?? split(directory.path).last),
      );

  Widget _fileList({
    required BuildContext context,
    required Directory currentDirectory,
    required List<FileSystemEntity> availableItems,
    required Widget Function(
      BuildContext context,
      Directory directory,
    )
        directoryUpItem,
    required Widget Function(
      BuildContext context,
      FileSystemEntity entity,
    )
        fileSystemItem,
  }) =>
      ListView(
        children: [
          directoryUpItem(context, currentDirectory.parent),
          ...(availableItems
                  .whereType<Directory>()
                  .cast<FileSystemEntity>()
                  .toList()
                ..sort(
                  (item1, item2) => basename(item1.path)
                      .toLowerCase()
                      .compareTo(basename(item2.path).toLowerCase()),
                ))
              .followedBy(availableItems
                  .whereType<File>()
                  .cast<FileSystemEntity>()
                  .toList()
                ..sort(
                  (item1, item2) => basename(item1.path)
                      .toLowerCase()
                      .compareTo(basename(item2.path).toLowerCase()),
                ))
              .map((item) => fileSystemItem(context, item))
              .toList(),
        ],
      );

  Widget _directoryUpItem(
    BuildContext context,
    Directory directory,
  ) =>
      ListTile(
        title: Icon(
          Icons.undo_sharp,
          color: NeumorphicTheme.defaultTextColor(context),
        ),
        onTap: () => context.read<PlayerBloc>().add(PickDirectory(directory)),
      );

  Widget _fileSystemItem(
    BuildContext context,
    FileSystemEntity entity,
  ) =>
      ListTile(
        leading: Icon(
          entity is Directory
              ? Icons.folder
              : entity is File
                  ? Icons.audiotrack
                  : Icons.question_mark,
          color: NeumorphicTheme.defaultTextColor(context),
        ),
        title: Text(basename(entity.path)),
        onTap: () {
          if (entity is Directory) {
            context.read<PlayerBloc>().add(PickDirectory(entity));
          }
          if (entity is File) {
            //context.read<PlayerBloc>().add(PickDirectory(entity));
          }
        },
      );
}
