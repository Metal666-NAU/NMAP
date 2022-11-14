import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:metadata_god/metadata_god.dart' as metadata_god;
import 'package:path/path.dart';

import '../../bloc/root/home/bloc.dart';
import '../../bloc/root/home/events.dart';
import '../../bloc/root/home/state.dart';
import '../../util/color_extensions.dart';
import 'loading_indicator.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) => _mainPanel(
        externalStoragePicker: (
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
        player: (maxHeight) => _player(
          maxHeight: maxHeight,
          progressBar: (context, progress) => _progressBar(
            context,
            progress,
          ),
          albumArtImage: (context, albumArt) => _albumArtImage(
            context,
            albumArt,
          ),
          playButton: (
            context,
            isPlaying,
            isBig,
          ) =>
              _playButton(
            context,
            isPlaying,
            isBig,
          ),
        ),
      );

  Widget _mainPanel({
    required Widget Function(
      List<Storage> availableStorages,
      Storage? loadingStorage,
    )
        externalStoragePicker,
    required Widget Function(
      Storage currentStorage,
      Directory currentDirectory,
      List<FileSystemEntity> availableItems,
    )
        filePicker,
    required Widget Function(double maxHeight) player,
  }) =>
      LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            Expanded(
              child: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (previous, current) =>
                    current.currentStorageWasSetOrCleared(previous) ||
                    previous.availableStorages != current.availableStorages ||
                    previous.loadingStorage != current.loadingStorage ||
                    previous.currentDirectory != current.currentDirectory,
                builder: (context, state) => state.currentStorage == null
                    ? externalStoragePicker(
                        state.availableStorages,
                        state.loadingStorage,
                      )
                    : filePicker(
                        state.currentStorage!,
                        state.currentDirectory!,
                        state.entitiesAtCurrentPath ?? [],
                      ),
              ),
            ),
            player(constraints.maxHeight),
          ],
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
            : () => context.read<HomeBloc>().add(PickExternalStorage(storage)),
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
        onTap: () => context.read<HomeBloc>().add(PickDirectory(directory)),
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
        onTap: () => context.read<HomeBloc>().add(PickDirectory(directory)),
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
            context.read<HomeBloc>().add(PickDirectory(entity));
          }
          if (entity is File) {
            context.read<HomeBloc>().add(PlayFile(entity));
          }
        },
      );

  Widget _player({
    required double maxHeight,
    required Widget Function(
      BuildContext context,
      double? progress,
    )
        progressBar,
    required Widget Function(
      BuildContext context,
      metadata_god.Image? albumArt,
    )
        albumArtImage,
    required Widget Function(
      BuildContext context,
      bool? isPlaying,
      bool isBig,
    )
        playButton,
  }) =>
      BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) =>
            previous.currentAudioFile != current.currentAudioFile ||
            previous.isPlayerExpanded != current.isPlayerExpanded,
        builder: (context, state) => state.currentAudioFile == null
            ? const SizedBox()
            : AnimatedContainer(
                curve: Curves.easeInOutQuint,
                height: state.isPlayerExpanded ? maxHeight * 0.75 : 80,
                duration: const Duration(milliseconds: 400),
                child: NeumorphicButton(
                  padding: EdgeInsets.zero,
                  style: const NeumorphicStyle(depth: -6),
                  onPressed: () => context
                      .read<HomeBloc>()
                      .add(const ToggleExpandedPlayer()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.isPlayerExpanded)
                        Expanded(
                          child: Neumorphic(
                            style: const NeumorphicStyle(depth: -6),
                            child: Padding(
                              padding: const EdgeInsets.all(70),
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: albumArtImage(
                                  context,
                                  state.currentAudioFile?.metadata?.albumArt,
                                ),
                              ),
                            ),
                          ),
                        ),
                      progressBar(
                        context,
                        state.currentAudioFile?.progress,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!state.isPlayerExpanded)
                              albumArtImage(
                                context,
                                state.currentAudioFile?.metadata?.albumArt,
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: state.isPlayerExpanded
                                    ? CrossAxisAlignment.center
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.currentAudioFile?.metadata?.title !=
                                            null
                                        ? state
                                            .currentAudioFile!.metadata!.title!
                                        : state.currentAudioFile?.metadata ==
                                                null
                                            ? "Loading title..."
                                            : state.currentAudioFile!.path,
                                    style: TextStyle(
                                        fontSize:
                                            state.isPlayerExpanded ? 30 : 20),
                                  ),
                                  if (state
                                          .currentAudioFile?.metadata?.artist !=
                                      null)
                                    Row(
                                      mainAxisAlignment: state.isPlayerExpanded
                                          ? MainAxisAlignment.center
                                          : MainAxisAlignment.start,
                                      children: [
                                        if (state.isPlayerExpanded)
                                          Text(
                                            "by ",
                                            style: TextStyle(
                                              fontSize: 22,
                                              color: NeumorphicTheme
                                                      .defaultTextColor(context)
                                                  .darken(60),
                                            ),
                                          ),
                                        Text(
                                          state.currentAudioFile!.metadata!
                                              .artist!,
                                          style: TextStyle(
                                            fontSize: state.isPlayerExpanded
                                                ? 22
                                                : 16,
                                            color: NeumorphicTheme
                                                    .defaultTextColor(context)
                                                .darken(20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (state.isPlayerExpanded &&
                                      state.currentAudioFile?.metadata?.album !=
                                          null)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "from ",
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: NeumorphicTheme
                                                    .defaultTextColor(context)
                                                .darken(60),
                                          ),
                                        ),
                                        Text(
                                          state.currentAudioFile!.metadata!
                                              .album!,
                                          style: TextStyle(
                                            fontSize: state.isPlayerExpanded
                                                ? 22
                                                : 16,
                                            color: NeumorphicTheme
                                                    .defaultTextColor(context)
                                                .darken(20),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            if (!state.isPlayerExpanded)
                              playButton(
                                context,
                                state.currentAudioFile?.progress == null
                                    ? null
                                    : state.currentAudioFile!.isPlaying,
                                false,
                              ),
                          ],
                        ),
                      ),
                      if (state.isPlayerExpanded)
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: playButton(
                              context,
                              state.currentAudioFile?.progress == null
                                  ? null
                                  : state.currentAudioFile!.isPlaying,
                              true,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      );

  Widget _progressBar(
    BuildContext context,
    double? progress,
  ) =>
      progress != null
          ? NeumorphicSlider(
              max: 1,
              value: progress,
              onChangeStart: (percent) =>
                  context.read<HomeBloc>().add(const StartSeeking()),
              onChanged: (percent) =>
                  context.read<HomeBloc>().add(Seeking(percent)),
              onChangeEnd: (percent) =>
                  context.read<HomeBloc>().add(FinishSeeking(percent)),
              style: const SliderStyle(
                depth: -6,
                borderRadius: BorderRadius.vertical(
                  top: Radius.zero,
                  bottom: Radius.circular(10),
                ),
              ),
              thumb: Neumorphic(
                style: NeumorphicStyle(
                  depth: 4,
                  shape: NeumorphicShape.concave,
                  boxShape: NeumorphicBoxShape.roundRect(
                    const BorderRadius.vertical(
                      top: Radius.zero,
                      bottom: Radius.circular(10),
                    ),
                  ),
                  color: NeumorphicTheme.accentColor(context),
                ),
                child: const SizedBox(
                  height: 26,
                  width: 22,
                ),
              ),
            )
          : const NeumorphicProgressIndeterminate();

  Widget _albumArtImage(
    BuildContext context,
    metadata_god.Image? albumArt,
  ) =>
      albumArt != null
          ? Image.memory(albumArt.data)
          : ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 40),
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: NeumorphicIcon(
                  Icons.album,
                  style: const NeumorphicStyle(
                    shape: NeumorphicShape.convex,
                  ),
                ),
              ),
            );

  Widget _playButton(
    BuildContext context,
    bool? isPlaying,
    bool isBig,
  ) {
    void onPressed() => isPlaying == null
        ? null
        : context.read<HomeBloc>().add(const TogglePlayback());

    Icon icon([double? size]) => Icon(
          isPlaying == true ? Icons.pause : Icons.play_arrow,
          size: size,
          color: NeumorphicTheme.defaultTextColor(context),
        );

    return isBig
        ? NeumorphicButton(
            onPressed: onPressed,
            child: icon(32),
          )
        : IconButton(
            iconSize: 26,
            onPressed: onPressed,
            icon: icon(),
          );
  }
}
