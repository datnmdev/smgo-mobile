import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/update_delivery_order_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/update_delivery_order_form/update_delivery_order_form_state.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/address_input.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/contact_name_input.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/contact_phone_input.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/location_input.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/order_code_input.dart';
import 'package:shipgo/shared/domain/entities/point_entity.dart';

const _absent = Object();

class UpdateDeliveryOrderFormCubit extends Cubit<UpdateDeliveryOrderFormState> {
  final UpdateDeliveryOrderUsecase updateDeliveryOrderUsecase;

  UpdateDeliveryOrderFormCubit({
    required String deliveryRouteId,
    required String deliveryOrderId,
    required this.updateDeliveryOrderUsecase,
  }) : super(
         UpdateDeliveryOrderFormInitial(
           deliveryRouteId: deliveryRouteId,
           deliveryOrderId: deliveryOrderId,
         ),
       );

  void initialize({
    String? orderCode,
    Object? orderName = _absent,
    Object? orderMediaId = _absent,
    String? contactName,
    String? contactPhone,
    String? address,
    Object? appliedLocationId = _absent,
    Point? location,
  }) {
    emit(
      state.copyWith(
        orderCodeInput: OrderCodeInput.pure(
          orderCode ?? state.orderCodeInput.value,
        ),
        orderName: orderName == _absent ? state.orderName : orderName,
        orderMediaId: orderMediaId == _absent
            ? state.orderMediaId
            : orderMediaId,
        contactNameInput: ContactNameInput.pure(
          contactName ?? state.contactNameInput.value,
        ),
        contactPhoneInput: ContactPhoneInput.pure(
          contactPhone ?? state.contactPhoneInput.value,
        ),
        addressInput: AddressInput.pure(address ?? state.addressInput.value),
        appliedLocationId: appliedLocationId == _absent
            ? state.appliedLocationId
            : appliedLocationId,
        locationInput: location != null
            ? LocationInput.pure(location)
            : state.locationInput,
      ),
    );
  }

  void orderCodeInputChanged(String value) {
    emit(state.copyWith(orderCodeInput: OrderCodeInput.dirty(value)));
  }

  void orderMediaIdChanged(String? value) {
    emit(state.copyWith(orderMediaId: value));
  }

  void orderMediaUrlChanged(String? value) {
    emit(state.copyWith(orderMediaUrl: value));
  }

  void orderNameInputChanged(String? value) {
    emit(state.copyWith(orderName: value));
  }

  void contactNameInputChanged(String value) {
    emit(state.copyWith(contactNameInput: ContactNameInput.dirty(value)));
  }

  void contactPhoneInputChanged(String value) {
    emit(state.copyWith(contactPhoneInput: ContactPhoneInput.dirty(value)));
  }

  void addressInputChanged(String value) {
    emit(state.copyWith(addressInput: AddressInput.dirty(value)));
  }

  void appliedLocationIdChanged(String? value) {
    emit(state.copyWith(appliedLocationId: value));
  }

  void locationInputChanged(PointEntity? point) {
    emit(
      state.copyWith(
        locationInput: point != null
            ? LocationInput.dirty(Point(x: point.x, y: point.y))
            : LocationInput.dirty(null),
      ),
    );
  }

  bool isOrderCodeDuplicated({
    required String oldOrderCode,
    required List<DeliveryOrderEntity> existingDeliveryOrders,
  }) {
    return existingDeliveryOrders.any(
      (order) =>
          state.orderCodeInput.value != oldOrderCode &&
          order.orderCode == state.orderCodeInput.value,
    );
  }

  void submit({
    required String oldOrderCode,
    required List<DeliveryOrderEntity> existingDeliveryOrders,
  }) async {
    emit(
      state.copyWith(
        orderCodeInput: OrderCodeInput.dirty(state.orderCodeInput.value),
        contactNameInput: ContactNameInput.dirty(state.contactNameInput.value),
        contactPhoneInput: ContactPhoneInput.dirty(
          state.contactPhoneInput.value,
        ),
        addressInput: AddressInput.dirty(state.addressInput.value),
        locationInput: LocationInput.dirty(state.locationInput.value),
      ),
    );
    if (state.isValid &&
        !isOrderCodeDuplicated(
          oldOrderCode: oldOrderCode,
          existingDeliveryOrders: existingDeliveryOrders,
        )) {
      emit(UpdateDeliveryOrderFormLoading(state: state));
      final dataState = await updateDeliveryOrderUsecase.call(
        params: UpdateDeliveryOrderUsecaseParams(
          deliveryRouteId: state.deliveryRouteId,
          deliveryOrderId: state.deliveryOrderId,
          orderCode: state.orderCodeInput.value,
          orderName: state.orderName,
          orderMediaId: state.orderMediaId,
          contactName: state.contactNameInput.value,
          contactPhone: state.contactPhoneInput.value,
          address: state.addressInput.value,
          appliedLocationId: state.appliedLocationId,
          location: PointEntity(
            x: state.locationInput.value!.x,
            y: state.locationInput.value!.y,
          ),
        ),
      );
      if (dataState is DataSuccess) {
        emit(UpdateDeliveryOrderFormDone(state: state));
      } else if (dataState is DataFailed) {
        emit(
          UpdateDeliveryOrderFormFailed(error: dataState.error!, state: state),
        );
      }
    }
  }
}
