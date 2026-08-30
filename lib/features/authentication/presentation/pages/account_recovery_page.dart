import 'package:citieswalk/core/localization/localized_material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/providers/auth_controller.dart';

class AccountRecoveryPage extends StatelessWidget {
  const AccountRecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final user = controller.currentUser!;
    final deadline = user.permanentlyDeleteAt!;
    final canRecover = user.canRecoverAccount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                canRecover
                    ? Icons.restore_rounded
                    : Icons.delete_forever_outlined,
                size: 64,
                color: canRecover ? AppColors.primary : AppColors.error,
              ),
              const SizedBox(height: 20),
              Text(
                canRecover
                    ? 'Account scheduled for deletion'
                    : 'Account recovery period expired',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                canRecover
                    ? context
                          .tr(
                            'Your account will be permanently deleted on {date}. Recover it now to keep your profile and data.',
                          )
                          .replaceFirst('{date}', _date(deadline))
                    : context
                          .tr(
                            'The 30-day recovery period ended on {date}. This account is ready for permanent deletion.',
                          )
                          .replaceFirst('{date}', _date(deadline)),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          final success = canRecover
                              ? await controller.recoverAccount()
                              : await controller.finalizeAccountDeletion();
                          if (!context.mounted || success) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                controller.errorMessage ??
                                    'Unable to update this account.',
                              ),
                            ),
                          );
                        },
                  child: Text(
                    canRecover ? 'Recover my account' : 'Delete permanently',
                  ),
                ),
              ),
              if (canRecover) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: controller.isLoading ? null : controller.signOut,
                  child: const Text('Keep deletion scheduled'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _date(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}
