class LanguageEntity {
  final String code;
  final String countryCode;
  final String name;
  final String nativeName;
  final String flagEmoji;

  LanguageEntity({
    required this.code,
    required this.countryCode,
    required this.name,
    required this.nativeName,
    required this.flagEmoji,
  });
}

final List<LanguageEntity> appLanguages = [
  LanguageEntity(
    code: 'vi',
    countryCode: 'VN',
    name: 'Vietnamese',
    nativeName: 'Tiếng Việt',
    flagEmoji: '🇻🇳',
  ),
  LanguageEntity(
    code: 'en',
    countryCode: 'US',
    name: 'English',
    nativeName: 'English',
    flagEmoji: '🇬🇧',
  ),
];

final Map<String, String> appLanguageNativeNameMap = {
  'vi': 'Tiếng Việt',
  'en': 'English',
};
