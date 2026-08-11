class AppVersionEntity {
  final String id;
  final String platform;
  final String versionName;
  final int buildNumber;
  final int minSupportedBuild;
  final String? storeAppId;
  final bool isMaintenance;
  final Map<String, String>? maintenanceMessage;

  const AppVersionEntity({
    required this.id,
    required this.platform,
    required this.versionName,
    required this.buildNumber,
    required this.minSupportedBuild,
    this.storeAppId,
    required this.isMaintenance,
    this.maintenanceMessage,
  });
}
