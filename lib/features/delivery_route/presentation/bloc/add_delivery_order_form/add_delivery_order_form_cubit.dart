import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:smgo/features/delivery_route/domain/usecases/add_delivery_order_usecase.dart';
import 'package:smgo/features/delivery_route/presentation/bloc/add_delivery_order_form/add_delivery_order_form_state.dart';
import 'package:smgo/features/delivery_route/presentation/inputs/address_input.dart';
import 'package:smgo/features/delivery_route/presentation/inputs/contact_name_input.dart';
import 'package:smgo/features/delivery_route/presentation/inputs/contact_phone_input.dart';
import 'package:smgo/features/delivery_route/presentation/inputs/location_input.dart';
import 'package:smgo/features/delivery_route/presentation/inputs/order_code_input.dart';

class AddDeliveryOrderFormCubit extends Cubit<AddDeliveryOrderFormState> {
  final AddDeliveryOrderUsecase addDeliveryOrderUsecase;

  AddDeliveryOrderFormCubit({
    required String deliveryRouteId,
    required this.addDeliveryOrderUsecase,
  }) : super(AddDeliveryOrderFormInitial(deliveryRouteId: deliveryRouteId));

  void reset() {
    emit(
      state.copyWith(
        orderCodeInput: OrderCodeInput.pure(),
        orderName: null,
        orderMediaId: null,
        contactNameInput: ContactNameInput.pure(),
        contactPhoneInput: ContactPhoneInput.pure(),
        addressInput: AddressInput.pure(),
        appliedLocationId: null,
        locationInput: LocationInput.pure(),
      ),
    );
  }

  void orderCodeInputChanged(String value) {
    emit(state.copyWith(orderCodeInput: OrderCodeInput.dirty(value)));
  }

  void orderMediaIdChanged(String? value) {
    emit(state.copyWith(orderMediaId: value));
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

  void locationInputChanged(PointUsecaseParam? value) {
    emit(
      state.copyWith(
        locationInput: value != null
            ? LocationInput.dirty(Point(x: value.x, y: value.y))
            : LocationInput.dirty(null),
      ),
    );
  }

  bool isOrderCodeDuplicated({
    required List<DeliveryOrderEntity> existingDeliveryOrders,
  }) {
    return existingDeliveryOrders.any(
      (order) => order.orderCode == state.orderCodeInput.value,
    );
  }

  void submit({
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
          existingDeliveryOrders: existingDeliveryOrders,
        )) {
      emit(AddDeliveryOrderFormLoading(state: state));
      final dataState = await addDeliveryOrderUsecase.call(
        params: AddDeliveryOrderUsecaseParams(
          deliveryRouteId: state.deliveryRouteId,
          orderCode: state.orderCodeInput.value,
          orderName: state.orderName,
          orderMediaId: state.orderMediaId,
          contactName: state.contactNameInput.value,
          contactPhone: state.contactPhoneInput.value,
          address: state.addressInput.value,
          appliedLocationId: state.appliedLocationId,
          location: PointUsecaseParam(
            x: state.locationInput.value!.x,
            y: state.locationInput.value!.y,
          ),
        ),
      );
      if (dataState is DataSuccess) {
        emit(AddDeliveryOrderFormDone(state: state));
      } else if (dataState is DataFailed) {
        emit(AddDeliveryOrderFormFailed(error: dataState.error!, state: state));
      }
    }
  }
}
