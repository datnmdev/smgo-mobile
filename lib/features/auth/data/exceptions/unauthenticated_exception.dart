import 'package:shipgo/core/exceptions/app_exception.dart';

class UnauthenticatedException extends AppException {
  UnauthenticatedException({
    super.code = 'UNAUTHENTICATED',
    super.message = 'Xác thực không thành công. Vui lòng thử lại',
  });
}
