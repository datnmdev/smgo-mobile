class UserEntity {
  final String id;
  final String name;
  final String provider;
  final String uuid;
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.name,
    required this.provider,
    required this.uuid,
    required this.createdAt,
  });
}
