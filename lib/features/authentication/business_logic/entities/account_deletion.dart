class AccountDeletion {
  const AccountDeletion({
    required this.requestedAt,
    required this.permanentlyDeleteAt,
  });

  final DateTime requestedAt;
  final DateTime permanentlyDeleteAt;

  bool get canRecover => permanentlyDeleteAt.isAfter(DateTime.now());
}
