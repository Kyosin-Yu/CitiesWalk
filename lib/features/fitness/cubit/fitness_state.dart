class FitnessState {
  const FitnessState({this.notificationsEnabled = true});

  final bool notificationsEnabled;

  FitnessState copyWith({bool? notificationsEnabled}) => FitnessState(
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
  );
}
