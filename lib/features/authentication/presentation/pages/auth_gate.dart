import 'package:citieswalk/core/localization/localized_material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_shell.dart';
import '../../../../core/di/service_locator.dart';
import '../../business_logic/providers/auth_controller.dart';
import 'login_page.dart';
import 'reset_password_page.dart';
import 'account_recovery_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();

    _authController = sl<AuthController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authController.checkCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        if (authController.isLoading) {
          return const _AuthLoadingScreen();
        }

        if (authController.isPasswordRecovery) {
          return const ResetPasswordPage();
        }

        if (authController.currentUser?.isPendingDeletion ?? false) {
          return const AccountRecoveryPage();
        }

        if (authController.isAuthenticated) {
          return const AppShell();
        }

        return const LoginPage();
      },
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
