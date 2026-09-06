const _absent = Object();

class UserEntity {
  final String id;
  final String name;
  final String provider;
  final String uuid;
  final String? avatar;
  final String? avatarUrl;
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.name,
    this.avatar,
    required this.provider,
    required this.uuid,
    this.avatarUrl,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? provider,
    String? uuid,
    Object? avatar = _absent,
    Object? avatarUrl = _absent,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      uuid: uuid ?? this.uuid,
      avatar: avatar == _absent ? this.avatar : avatar as String?,
      avatarUrl: avatarUrl == _absent ? this.avatarUrl : avatarUrl as String?,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
