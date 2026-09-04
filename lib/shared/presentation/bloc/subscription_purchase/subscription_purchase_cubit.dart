import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:smgo/core/exceptions/app_exception.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/core/utils/platform_util.dart';
import 'package:smgo/shared/domain/entities/subscription_entity.dart';
import 'package:smgo/shared/domain/usecases/verify_subscription_usecase.dart';
import 'subscription_purchase_state.dart';

class SubscriptionPurchaseCubit extends Cubit<SubscriptionPurchaseState> {
  final VerifySubscriptionUsecase verifySubscriptionUsecase;

  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  final Set<String> _verifyingTokens = <String>{};

  bool _isInitialized = false;
  bool _isInitializing = false;

  static final Set<String> _productIds = <String>{
    ProductId.standard.value,
    ProductId.plus.value,
    ProductId.premium.value,
  };

  SubscriptionPurchaseCubit({required this.verifySubscriptionUsecase})
    : super(SubscriptionPurchaseState()) {
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

  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) {
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

      if (success) {
        _isInitialized = true;
      }
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

  // ---------------------------------------------------------------------------
  // Purchase
  // ---------------------------------------------------------------------------

  Future<void> buyProduct(ProductDetails productDetails) async {
    if (state.status == SubscriptionPurchaseStatus.purchasing) {
      return;
    }

    emit(
      state.copyWith(
        status: SubscriptionPurchaseStatus.purchasing,
        products: state.products,
      ),
    );

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );

    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      emit(
        state.copyWith(
          status: SubscriptionPurchaseStatus.error,
          error: e,
          products: state.products,
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
          _handlePendingPurchase();
          break;

        case PurchaseStatus.purchased:
          await _handleSuccessfulPurchase(purchaseDetails);
          break;

        case PurchaseStatus.restored:
          await _handleSuccessfulPurchase(purchaseDetails);
          break;

        case PurchaseStatus.error:
          _handlePurchaseError(purchaseDetails);
          break;

        case PurchaseStatus.canceled:
          _handlePurchaseCanceled();
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
    emit(
      state.copyWith(
        status: SubscriptionPurchaseStatus.error,
        error: purchaseDetails.error ?? Exception('Transaction failed.'),
        products: state.products,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Canceled
  // ---------------------------------------------------------------------------

  void _handlePurchaseCanceled() {
    emit(
      state.copyWith(
        status: SubscriptionPurchaseStatus.loaded,
        products: state.products,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Successful Purchase
  // ---------------------------------------------------------------------------
  Future<void> _handleSuccessfulPurchase(
    PurchaseDetails purchaseDetails,
  ) async {
    final String purchaseToken =
        purchaseDetails.verificationData.serverVerificationData;
    try {
      if (purchaseToken.isEmpty) {
        throw AppException(
          code: 'EMPTY_PURCHASE_TOKEN',
          message: 'Purchase token is empty.',
        );
      }
      if (_verifyingTokens.contains(purchaseToken)) {
        return;
      }
      _verifyingTokens.add(purchaseToken);
      emit(
        state.copyWith(
          status: SubscriptionPurchaseStatus.purchasing,
          products: state.products,
        ),
      );
      final bool isValid = await _verifyWithBackend(purchaseDetails);
      if (!isValid) {
        throw AppException(
          code: 'VERIFICATION_FAILED',
          message: 'Failed to verify the purchased package from the server.',
        );
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
      emit(
        state.copyWith(
          status: SubscriptionPurchaseStatus.success,
          products: state.products,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SubscriptionPurchaseStatus.error,
          error: e is AppException
              ? e
              : AppException(
                  code: 'PAYMENT_FAILED',
                  message: 'Payment failed or cancelled',
                ),
          products: state.products,
        ),
      );
    } finally {
      if (purchaseToken.isNotEmpty) {
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

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  @override
  Future<void> close() async {
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;

    _verifyingTokens.clear();

    return super.close();
  }
}
