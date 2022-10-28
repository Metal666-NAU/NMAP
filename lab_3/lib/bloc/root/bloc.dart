import 'package:flutter_bloc/flutter_bloc.dart';

import 'events.dart';
import 'state.dart';

class RootBloc extends Bloc<RootEvent, RootState> {
  RootBloc() : super(const RootState());
}
