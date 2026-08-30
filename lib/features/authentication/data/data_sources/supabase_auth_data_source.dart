import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthDataSource {
  static const authRedirectUrl = 'com.citieswalk.citieswalk://login-callback/';

  final SupabaseClient _client;

  const SupabaseAuthDataSource(this._client);

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone_number': phoneNumber},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<bool> signInWithGoogle() {
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: authRedirectUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() {
    return _client.auth.signOut(scope: SignOutScope.global);
  }

  Future<void> finalizeAccountDeletion() async {
    await _client.functions.invoke('finalize-account-deletion');
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _client.auth.resetPasswordForEmail(
      email,
      redirectTo: authRedirectUrl,
    );
  }

  Future<UserResponse> updatePassword({required String password}) {
    return _client.auth.updateUser(UserAttributes(password: password));
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange;
  }

  Future<void> resendEmailVerification({required String email}) {
    return _client.auth.resend(type: OtpType.signup, email: email);
  }
}
