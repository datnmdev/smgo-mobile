import 'package:shipgo/core/exceptions/app_exception.dart';

class UserCanceledException extends AppException {
  UserCanceledException({
    super.code = 'USER_CANCELED',
    super.message = 'Bạn đã hủy thao tác',
  });
}
