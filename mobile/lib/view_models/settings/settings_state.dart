part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final String userName;
  final String userEmail;
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final String appVersion;
  final Currency selectedCurrency;

  const SettingsState({
    this.userName = 'Arthur Lima',
    this.userEmail = 'arthur@example.com',
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    this.appVersion = '1.0.0 (42)',
    this.selectedCurrency = Currency.brl,
  });

  SettingsState copyWith({
    String? userName,
    String? userEmail,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    String? appVersion,
    Currency? selectedCurrency,
  }) {
    return SettingsState(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      appVersion: appVersion ?? this.appVersion,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
    );
  }

  @override
  List<Object?> get props => [
    userName,
    userEmail,
    notificationsEnabled,
    biometricEnabled,
    appVersion,
    selectedCurrency,
  ];
}
