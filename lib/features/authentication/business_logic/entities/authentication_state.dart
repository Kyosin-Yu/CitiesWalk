import 'app_user.dart';

enum AuthenticationEvent { sessionChanged, passwordRecovery }

class AuthenticationState {
  final AppUser? user;
  final AuthenticationEvent event;

  const AuthenticationState({
    required this.user,
    this.event = AuthenticationEvent.sessionChanged,
  });

  bool get isPasswordRecovery => event == AuthenticationEvent.passwordRecovery;
}
