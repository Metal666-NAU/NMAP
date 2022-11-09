abstract class RootState {
  const RootState();
}

class Loading extends RootState {
  const Loading();
}

class NeedsPermission extends RootState {
  const NeedsPermission();
}

class OpenSettingsError extends RootState {
  const OpenSettingsError();
}

class Main extends RootState {
  const Main();
}
