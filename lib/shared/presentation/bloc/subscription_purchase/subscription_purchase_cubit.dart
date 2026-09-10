import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:smgo/core/exceptions/app_exception.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/utils/platform_util.dart';
import 'package:smgo/shared/domain/entities/subscription_entity.dart';
import 'package:smgo/shared/domain/usecases/verify_subscription_usecase.dart';
import 'subscription_purchase_state.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

enum PurchaseOwnershipResult { owned, notOwned, unknown }

abstract interface class PurchasePlatformService {
  PurchaseParam createPurchaseParam({
    required ProductDetails productDetails,
    required String userId,
    PurchaseDetails? oldPurchaseDetails,
  });

  PurchaseOwnershipResult checkOwnership({
    required PurchaseDetails purchaseDetails,
    required String userId,
  });
}

class AndroidPurchasePlatformService implements PurchasePlatformService {
  @override
  PurchaseParam createPurchaseParam({
    required ProductDetails productDetails,
    required String userId,
    PurchaseDetails? oldPurchaseDetails,
  }) {
    ChangeSubscriptionParam? changeSubscriptionParam;

    if (oldPurchaseDetails is GooglePlayPurchaseDetails) {
      changeSubscriptionParam = ChangeSubscriptionParam(
        oldPurchaseDetails: oldPurchaseDetails,
        replacementMode: ReplacementMode.chargeProratedPrice,
      );
    }

    return GooglePlayPurchaseParam(
      productDetails: productDetails,
      applicationUserName: userId,
      changeSubscriptionParam: changeSubscriptionParam,
    );
  }

  @override
  PurchaseOwnershipResult checkOwnership({
    required PurchaseDetails purchaseDetails,
    required String userId,
  }) {
    if (purchaseDetails is! GooglePlayPurchaseDetails) {
      return PurchaseOwnershipResult.unknown;
    }

    final String? purchaseAccountId =
        purchaseDetails.billingClientPurchase.obfuscatedAccountId;

    /*
     * Không có accountId không có nghĩa là fraud.
     *
     * Có thể đây là purchase ngoài Play Store.
     *
     * Nhưng client cũng KHÔNG được tự nhận nó.
     */
    if (purchaseAccountId == null || purchaseAccountId.isEmpty) {
      return PurchaseOwnershipResult.unknown;
    }

    if (purchaseAccountId != userId) {
      return PurchaseOwnershipResult.notOwned;
    }

    return PurchaseOwnershipResult.owned;
  }
}

class SubscriptionPurchaseCubit extends Cubit<SubscriptionPurchaseState> {
  final VerifySubscriptionUsecase verifySubscriptionUsecase;
  final PurchasePlatformService purchasePlatformService;

  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  final Set<String> _verifyingTokens = <String>{};

  bool _isInitialized = false;
  bool _isInitializing = false;

  String? _currentUserId;

  /// Purchase hiện tại đã được xác định chắc chắn thuộc user SmGo hiện tại.
  /// Android dùng purchase này khi đổi gói bằng ChangeSubscriptionParam.
  PurchaseDetails? _currentPurchaseDetails;

  /// Product mà user đang chủ động mua / nâng cấp.
  ///
  /// Khi đổi subscription, Google Play có thể emit nhiều PurchaseDetails
  /// (bao gồm purchase cũ). Field này giúp chỉ verify đúng purchase mới
  /// mà user vừa yêu cầu.
  String? _pendingProductId;

  /// Tăng mỗi khi reset / đổi user để vô hiệu hóa async task từ session cũ.
  int _sessionVersion = 0;

  static const int _maxVerificationAttempts = 3;

  static const Duration _verificationRetryDelay = Duration(seconds: 2);

  static final Set<String> _productIds = <String>{
    ProductId.standard.value,
    ProductId.plus.value,
    ProductId.premium.value,
  };

  SubscriptionPurchaseCubit({
    required this.verifySubscriptionUsecase,
    required this.purchasePlatformService,
  }) : super(SubscriptionPurchaseState()) {
    _initPurchaseStream();
  }

  // ---------------------------------------------------------------------------
  // Purchase Stream
  // ---------------------------------------------------------------------------

  void _initPurchaseStream() {
    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () {
        _purchaseSubscription = null;
      },
      onError: (Object error, StackTrace stackTrace) {
        emit(
          state.copyWith(
            status: SubscriptionPurchaseStatus.error,
            error: error,
            products: state.products,
          ),
        );
      },
      cancelOnError: false,
    );
  }

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  Future<void> initialize({String? userId}) async {
    if (userId != null && userId.isNotEmpty) {
      /*
       * Nếu đổi sang SmGo user khác,
       * reset toàn bộ state thuộc session cũ trước.
       */
      if (_currentUserId != null && _currentUserId != userId) {
        _resetSessionState();
      }

      _currentUserId = userId;
    }

    if (_currentUserId == null || _currentUserId!.isEmpty) {
      return;
    }

    if (_isInitializing) {
      return;
    }

    /*
     * Đã initialize thành công trong session này.
     * Không query products và không restore lần nữa.
     */
    if (_isInitialized) {
      return;
    }

    _isInitializing = true;

    if (state.status != SubscriptionPurchaseStatus.purchasing) {
      emit(
        state.copyWith(
          status: SubscriptionPurchaseStatus.loading,
          products: state.products,
        ),
      );
    }

    try {
      final bool isAvailable = await _iap.isAvailable();

      if (!isAvailable) {
        emit(
          state.copyWith(
            status: SubscriptionPurchaseStatus.error,
            error: Exception('Google Play / App Store is unavailable.'),
            products: state.products,
          ),
        );

        return;
      }

      final bool success = await _loadProducts();

      if (!success) {
        return;
      }

      /*
       * Restore đúng 1 lần trong user session.
       *
       * Chỉ đánh dấu initialized sau khi restore call chạy thành công.
       * Nếu restore throw thì lần initialize() sau vẫn có thể retry.
       */
      final bool restored = await _restorePurchases();

      if (!restored) {
        return;
      }

      _isInitialized = true;
    } catch (e) {
      emit(
        state.copyWith(
          status: SubscriptionPurchaseStatus.error,
          error: e,
          products: state.products,
        ),
      );
    } finally {
      _isInitializing = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Products
  // ---------------------------------------------------------------------------

  Future<bool> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        _productIds,
      );

      if (response.error != null) {
        emit(
          state.copyWith(
            status: SubscriptionPurchaseStatus.error,
            error: response.error,
            products: state.products,
          ),
        );

        return false;
      }

      if (response.productDetails.isEmpty) {
        emit(
          state.copyWith(
            status: SubscriptionPurchaseStatus.error,
            error: Exception('No subscription products were found.'),
            products: state.products,
          ),
        );

        return false;
      }

      emit(
        state.copyWith(
          status: SubscriptionPurchaseStatus.loaded,
          products: response.productDetails,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: SubscriptionPurchaseStatus.error,
          error: e,
          products: state.products,
        ),
      );

      return false;
    }
  }

  void _resetSessionState() {
    /*
     * Vô hiệu hóa mọi Future verify/restore từ session cũ.
     */
    _sessionVersion++;

    _currentUserId = null;
    _currentPurchaseDetails = null;
    _pendingProductId = null;

    _isInitialized = false;
    _isInitializing = false;

    _verifyingTokens.clear();
  }

  void reset() {
    _resetSessionState();

    emit(SubscriptionPurchaseState());
  }

  void clearCurrentPurchase() {
    _currentPurchaseDetails = null;
  }

  // ---------------------------------------------------------------------------
  // Purchase
  // ---------------------------------------------------------------------------

  Future<void> buyProduct(
    ProductDetails productDetails, {
    required bool isUpgrade,
  }) async {
    if (state.isPaymentFlowActive) {
      return;
    }

    emit(
      state.copyWith(
        status: SubscriptionPurchaseStatus.purchasing,
        products: state.products,
        isPaymentFlowActive: true,
      ),
    );

    final String? currentUserId = _currentUserId;

    if (currentUserId == null || currentUserId.isEmpty) {
      emit(
        state.copyWith(
          status: SubscriptionPurchaseStatus.error,
          error: AppException(
            code: 'PAYMENT_FAILED',
            message: 'Current user is unavailable.',
          ),
          products: state.products,
          isPaymentFlowActive: false,
        ),
      );

      return;
    }

    /*
   * Upgrade bắt buộc phải có purchase hiện tại.
   *
   * Không được biến upgrade thành purchase mới
   * chỉ vì restore chưa lấy được purchase cũ.
   */
    if (isUpgrade && _currentPurchaseDetails == null) {
      emit(
        state.copyWith(
          status: SubscriptionPurchaseStatus.error,
          error: AppException(
            code: 'PAYMENT_FAILED',
            message:
                'Current subscription purchase is unavailable for upgrade.',
          ),
          products: state.products,
          isPaymentFlowActive: false,
        ),
      );

      return;
    }

    try {
      // Ghi nhận chính xác product user đang yêu cầu mua / nâng cấp.
      // Purchase stream sẽ dùng giá trị này để bỏ qua purchase cũ.
      _pendingProductId = productDetails.id;

      final PurchaseParam purchaseParam = purchasePlatformService
          .createPurchaseParam(
            productDetails: productDetails,
            userId: currentUserId,
            oldPurchaseDetails: isUpgrade ? _currentPurchaseDetails : null,
          );

      final bool launched = await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      /*
       * Nếu Billing flow không launch được thì purchaseStream
       * sẽ không có event để kết thúc loading.
       */
      if (!launched) {
        _pendingProductId = null;

        emit(
          state.copyWith(
            status: SubscriptionPurchaseStatus.loaded,
            products: state.products,
            isPaymentFlowActive: false,
          ),
        );
      }
    } catch (e) {
      _pendingProductId = null;

      emit(
        state.copyWith(
          status: SubscriptionPurchaseStatus.error,
          error: AppException(code: 'PAYMENT_FAILED', message: e.toString()),
          products: state.products,
          isPaymentFlowActive: false,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Purchase Updates
  // ---------------------------------------------------------------------------

  Future<void> _onPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          /*
           * Pending chỉ xử lý purchase mà user đang chủ động mua.
           */
          if (_pendingProductId != null &&
              purchaseDetails.productID != _pendingProductId) {
            break;
          }

          _handlePendingPurchase();
          break;

        case PurchaseStatus.purchased:
          /*
           * Khi upgrade Google Play có thể emit cả purchase cũ
           * và purchase mới.
           *
           * Chỉ purchase khớp đúng product user vừa yêu cầu
           * mới được verify.
           */
          if (state.isPaymentFlowActive &&
              _pendingProductId != null &&
              purchaseDetails.productID != _pendingProductId) {
            break;
          }

          final ownership = _checkOwnership(purchaseDetails);

          if (ownership == PurchaseOwnershipResult.notOwned) {
            _handleOwnershipRejected();
            break;
          }

          if (ownership == PurchaseOwnershipResult.unknown) {
            _handleOwnershipUnknown(isRestoredPurchase: false);
            break;
          }

          await _handleSuccessfulPurchase(
            purchaseDetails,
            isRestoredPurchase: false,
          );

          break;

        case PurchaseStatus.restored:
          /*
           * Restore không thuộc payment flow chủ động.
           * Không filter restore bằng _pendingProductId.
           */
          final ownership = _checkOwnership(purchaseDetails);

          if (ownership != PurchaseOwnershipResult.owned) {
            break;
          }

          await _handleSuccessfulPurchase(
            purchaseDetails,
            isRestoredPurchase: true,
          );

          break;

        case PurchaseStatus.error:
          /*
           * Error của billing flow phải kết thúc loading.
           * Không filter theo productID vì event error/cancel
           * có thể không mang productID đúng như _pendingProductId.
           */
          if (state.isPaymentFlowActive) {
            _handlePurchaseError(purchaseDetails);
          }
          break;

        case PurchaseStatus.canceled:
          /*
           * User đóng / hủy Google Play payment sheet.
           * Luôn kết thúc payment flow hiện tại.
           */
          if (state.isPaymentFlowActive) {
            _handlePurchaseCanceled();
          }
          break;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Pending
  // ---------------------------------------------------------------------------

  void _handlePendingPurchase() {
    emit(
      state.copyWith(
        status: SubscriptionPurchaseStatus.purchasing,
        products: state.products,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Error
  // ---------------------------------------------------------------------------

  void _handlePurchaseError(PurchaseDetails purchaseDetails) {
    _pendingProductId = null;

    emit(
      state.copyWith(
        status: SubscriptionPurchaseStatus.error,
        error: AppException(
          code: 'PAYMENT_FAILED',
          message: purchaseDetails.error?.message ?? 'Transaction failed.',
        ),
        products: state.products,
        isPaymentFlowActive: false,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Canceled
  // ---------------------------------------------------------------------------

  void _handlePurchaseCanceled() {
    _pendingProductId = null;

    emit(
      state.copyWith(
        status: SubscriptionPurchaseStatus.loaded,
        products: state.products,
        isPaymentFlowActive: false,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Successful Purchase
  // ---------------------------------------------------------------------------

  Future<void> _handleSuccessfulPurchase(
    PurchaseDetails purchaseDetails, {
    required bool isRestoredPurchase,
  }) async {
    final String purchaseToken =
        purchaseDetails.verificationData.serverVerificationData;

    /*
     * Snapshot session hiện tại.
     * Nếu user logout / đổi account trong lúc verify đang chạy,
     * kết quả async của session cũ không được emit sang session mới.
     */
    final int sessionVersion = _sessionVersion;
    final String? sessionUserId = _currentUserId;

    try {
      if (purchaseToken.isEmpty) {
        throw AppException(
          code: 'EMPTY_PURCHASE_TOKEN',
          message: 'Purchase token is empty.',
        );
      }

      if (sessionUserId == null || sessionUserId.isEmpty) {
        return;
      }

      /*
       * Tránh một token bị verify đồng thời nhiều lần
       * nếu purchaseStream emit trùng.
       */
      if (_verifyingTokens.contains(purchaseToken)) {
        return;
      }

      _verifyingTokens.add(purchaseToken);

      emit(
        state.copyWith(
          status: SubscriptionPurchaseStatus.purchasing,
          products: state.products,
          error: null,
          isRestoredPurchase: isRestoredPurchase,

          /*
           * Restore chạy nền không được bật loading "Đang thanh toán".
           */
          isPaymentFlowActive: isRestoredPurchase
              ? false
              : state.isPaymentFlowActive,
        ),
      );

      final bool isValid = await _verifyWithBackendWithRetry(purchaseDetails);

      /*
       * User đã logout hoặc đổi account trong lúc request đang chạy.
       * Không cho kết quả của session cũ tác động state session mới.
       */
      if (sessionVersion != _sessionVersion ||
          sessionUserId != _currentUserId) {
        return;
      }

      if (!isValid) {
        throw AppException(
          code: 'VERIFICATION_FAILED',
          message: 'Failed to verify the purchased package from the server.',
        );
      }

      /*
       * Chỉ complete khi backend đã verify thành công.
       *
       * Nếu backend lỗi thì purchase vẫn còn để
       * lần sau restore và verify lại.
       */
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }

      /*
       * completePurchase là async nên kiểm tra session thêm lần nữa.
       */
      if (sessionVersion != _sessionVersion ||
          sessionUserId != _currentUserId) {
        return;
      }

      /*
       * Purchase đã verify hợp lệ thuộc user hiện tại.
       * Lưu lại để dùng làm oldPurchaseDetails cho lần upgrade tiếp theo.
       */
      _currentPurchaseDetails = purchaseDetails;
      _pendingProductId = null;

      emit(
        state.copyWith(
          status: SubscriptionPurchaseStatus.success,
          products: state.products,
          error: null,
          verifiedProductId: purchaseDetails.productID,
          isRestoredPurchase: isRestoredPurchase,
          isPaymentFlowActive: false,
        ),
      );
    } catch (e) {
      /*
       * Không emit error của session cũ sang user/session mới.
       */
      if (sessionVersion != _sessionVersion ||
          sessionUserId != _currentUserId) {
        return;
      }

      if (!isRestoredPurchase) {
        _pendingProductId = null;
      }

      emit(
        state.copyWith(
          status: SubscriptionPurchaseStatus.error,
          error: AppException(code: 'PAYMENT_FAILED', message: e.toString()),
          products: state.products,
          isRestoredPurchase: isRestoredPurchase,
          isPaymentFlowActive: false,
        ),
      );
    } finally {
      /*
       * Chỉ chỉnh verifying set nếu vẫn cùng session.
       * reset() của session mới đã tự clear set.
       */
      if (purchaseToken.isNotEmpty && sessionVersion == _sessionVersion) {
        _verifyingTokens.remove(purchaseToken);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Backend Verification
  // ---------------------------------------------------------------------------

  Future<bool> _verifyWithBackend(PurchaseDetails purchaseDetails) async {
    final String purchaseToken =
        purchaseDetails.verificationData.serverVerificationData;

    final dataState = await verifySubscriptionUsecase.call(
      params: VerifySubscriptionUsecaseParams(
        platform: PlatformUtil.getPlatformName(),
        purchaseToken: purchaseToken,
      ),
    );

    if (dataState is DataSuccess<bool>) {
      return dataState.data ?? false;
    }

    return false;
  }

  Future<bool> _verifyWithBackendWithRetry(
    PurchaseDetails purchaseDetails,
  ) async {
    for (int attempt = 1; attempt <= _maxVerificationAttempts; attempt++) {
      try {
        final bool isValid = await _verifyWithBackend(purchaseDetails);

        if (isValid) {
          return true;
        }
      } catch (_) {
        /*
         * Retry phía dưới.
         *
         * Nếu retry cuối cùng vẫn fail thì
         * _handleSuccessfulPurchase sẽ chuyển
         * thành PAYMENT_FAILED.
         */
      }

      if (attempt < _maxVerificationAttempts) {
        await Future<void>.delayed(_verificationRetryDelay * attempt);
      }
    }

    return false;
  }

  // ---------------------------------------------------------------------------
  // Purchase ownership
  // ---------------------------------------------------------------------------

  PurchaseOwnershipResult _checkOwnership(PurchaseDetails purchaseDetails) {
    final String? currentUserId = _currentUserId;

    if (currentUserId == null || currentUserId.isEmpty) {
      return PurchaseOwnershipResult.unknown;
    }

    return purchasePlatformService.checkOwnership(
      purchaseDetails: purchaseDetails,
      userId: currentUserId,
    );
  }

  // ---------------------------------------------------------------------------
  // Restore
  // ---------------------------------------------------------------------------

  Future<bool> _restorePurchases() async {
    try {
      await _iap.restorePurchases();
      return true;
    } catch (_) {
      /*
       * Restore chỉ dùng để recovery.
       *
       * Trả false để initialize() không đánh dấu session đã hoàn tất.
       * Lần retry sau vẫn có thể restore lại.
       */
      return false;
    }
  }

  void _handleOwnershipRejected() {
    _pendingProductId = null;

    emit(
      state.copyWith(
        status: SubscriptionPurchaseStatus.error,
        error: AppException(
          code: 'PAYMENT_FAILED',
          message: 'Purchase does not belong to the current user.',
        ),
        products: state.products,
        isPaymentFlowActive: false,
      ),
    );
  }

  void _handleOwnershipUnknown({required bool isRestoredPurchase}) {
    /*
     * Restore chạy nền:
     * unknown chỉ có nghĩa client không đủ dữ liệu xác định owner.
     * Không hiện lỗi vì backend RTDN có thể xử lý out-of-app purchase.
     */
    if (isRestoredPurchase) {
      return;
    }

    _pendingProductId = null;

    /*
     * Purchase mới phát sinh từ flow trong app mà thiếu account binding
     * là bất thường. Kết thúc payment flow rõ ràng.
     */
    emit(
      state.copyWith(
        status: SubscriptionPurchaseStatus.error,
        error: AppException(
          code: 'PAYMENT_FAILED',
          message: 'Unable to verify purchase ownership.',
        ),
        products: state.products,
        isPaymentFlowActive: false,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  @override
  Future<void> close() async {
    _sessionVersion++;

    await _purchaseSubscription?.cancel();

    _purchaseSubscription = null;

    _currentUserId = null;
    _currentPurchaseDetails = null;
    _pendingProductId = null;

    _verifyingTokens.clear();

    return super.close();
  }
}
