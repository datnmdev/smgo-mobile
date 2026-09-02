class UserEntity {
  final String id;
  final String name;
  final String provider;
  final String uuid;
  final String? avatarUrl;
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.name,
    required this.provider,
    required this.uuid,
    this.avatarUrl,
    required this.createdAt,
  });
}
