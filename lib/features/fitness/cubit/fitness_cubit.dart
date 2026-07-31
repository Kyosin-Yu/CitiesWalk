import 'package:flutter_bloc/flutter_bloc.dart';

import 'fitness_state.dart';

class FitnessCubit extends Cubit<FitnessState> {
  FitnessCubit() : super(const FitnessState());

  void toggleNotifications() => emit(
        state.copyWith(notificationsEnabled: !state.notificationsEnabled),
      );
}
