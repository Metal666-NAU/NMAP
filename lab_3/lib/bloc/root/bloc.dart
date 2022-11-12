import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/settings.dart';
import 'events.dart';
import 'state.dart';

class RootBloc extends Bloc<RootEvent, RootState> {
  RootBloc() : super(const Loading()) {
    on<AppStarted>((event, emit) async {
      await Settings.init();

      Permission manageExternalStorage = Permission.manageExternalStorage;

      if (await manageExternalStorage.isGranted) {
        emit(const Home());
      } else {
        emit(const NeedsPermission());
      }
    });
    on<AskForPermissions>((event, emit) async {
      Permission manageExternalStorage = Permission.manageExternalStorage;

      if (await manageExternalStorage.isDenied) {
        await manageExternalStorage.request();
      } else if (!await openAppSettings()) {
        emit(const OpenSettingsError());
      }

      if (await manageExternalStorage.isGranted) {
        emit(const Home());
      }
    });
  }
}
