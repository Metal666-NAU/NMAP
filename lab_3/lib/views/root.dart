import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import '../bloc/root/bloc.dart';
import '../bloc/root/events.dart';
import '../bloc/root/player/bloc.dart';
import '../bloc/root/player/events.dart';
import '../bloc/root/state.dart';
import 'root/loading_indicator.dart';
import 'root/player.dart';

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) => _mainPanel(
        needsPremissionsWarningPage:
            _noStoragePermissionsWarning(context: context),
        openSettingsErrorPage: _openSettingsError(context: context),
        loadingPage: _loadingCircle(),
      );

  Widget _mainPanel({
    required Widget needsPremissionsWarningPage,
    required Widget openSettingsErrorPage,
    required Widget loadingPage,
  }) =>
      BlocBuilder<RootBloc, RootState>(
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        builder: (context, state) => SafeArea(child: () {
          switch (state.runtimeType) {
            case NeedsPermission:
              return needsPremissionsWarningPage;
            case Main:
              return BlocProvider(
                create: (context) => PlayerBloc()..add(const PlayerLoaded()),
                child: const Player(),
              );
            case OpenSettingsError:
              return openSettingsErrorPage;
            default:
              return loadingPage;
          }
        }()),
      );

  Widget _noStoragePermissionsWarning({required BuildContext context}) =>
      Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Expanded(
              child: Text(
                "Storage permission is required to display all available audio files...",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            NeumorphicButton(
              onPressed: () =>
                  context.read<RootBloc>().add(AskForPermissions()),
              child: LayoutBuilder(
                builder: (context, constraints) => SizedBox.square(
                  dimension: constraints.biggest.shortestSide / 1.5,
                  child: FittedBox(
                    child: Text(
                      "Go to\nsettings\n-->",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _openSettingsError({required BuildContext context}) => Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            "Something went wrong when opening settings...",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      );

  Widget _loadingCircle() => Center(
        child: LayoutBuilder(
          builder: (context, constraints) => SizedBox.square(
            dimension: constraints.biggest.shortestSide / 2,
            child: const LoadingIndicator(),
          ),
        ),
      );
}
