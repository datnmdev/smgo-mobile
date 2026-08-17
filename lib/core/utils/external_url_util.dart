abstract class ExternalUrlUtil {
  static Uri getDialUrl(String phoneNumber) {
    final String formattedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    return Uri(scheme: 'tel', path: formattedNumber);
  }

  static Uri getSmsUrl({required String phoneNumber, String message = ''}) {
    final String formattedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    return Uri(
      scheme: 'sms',
      path: formattedNumber,
      queryParameters: message.isNotEmpty
          ? <String, String>{'body': message}
          : null,
    );
  }

  static Uri getZaloUrl(String phoneNumber) {
    final String cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return Uri.parse('https://zalo.me/$cleanNumber');
  }
}
