import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/add_delivery_order_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/add_delivery_order_form/add_delivery_order_form_state.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/address_input.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/contact_name_input.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/contact_phone_input.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/location_input.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/order_code_input.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/order_name_input.dart';

class AddDeliveryOrderFormCubit extends Cubit<AddDeliveryOrderFormState> {
  final AddDeliveryOrderUsecase addDeliveryOrderUsecase;

  AddDeliveryOrderFormCubit({
    required String deliveryRouteId,
    required this.addDeliveryOrderUsecase,
  }) : super(AddDeliveryOrderFormInitial(deliveryRouteId: deliveryRouteId));

  void orderCodeInputChanged(String value) {
    emit(state.copyWith(orderCodeInput: OrderCodeInput.dirty(value)));
  }

  void orderMediaIdChanged(String value) {
    emit(state.copyWith(orderMediaId: value));
  }

  void orderNameInputChanged(String value) {
    emit(state.copyWith(orderNameInput: OrderNameInput.dirty(value)));
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

  void appliedLocationIdChanged(String value) {
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

  void submit() async {
    emit(
      state.copyWith(
        orderCodeInput: OrderCodeInput.dirty(state.orderCodeInput.value),
        orderNameInput: OrderNameInput.dirty(state.orderNameInput.value),
        contactNameInput: ContactNameInput.dirty(state.contactNameInput.value),
        contactPhoneInput: ContactPhoneInput.dirty(
          state.contactPhoneInput.value,
        ),
        addressInput: AddressInput.dirty(state.addressInput.value),
        locationInput: LocationInput.dirty(state.locationInput.value),
      ),
    );
    if (state.isValid) {
      emit(AddDeliveryOrderFormLoading(state: state));
      final dataState = await addDeliveryOrderUsecase.call(
        params: AddDeliveryOrderUsecaseParams(
          deliveryRouteId: state.deliveryRouteId,
          orderCode: state.orderCodeInput.value,
          orderName: state.orderNameInput.value,
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
