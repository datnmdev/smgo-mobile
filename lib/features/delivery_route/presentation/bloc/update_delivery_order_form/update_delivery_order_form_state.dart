import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:smgo/features/delivery_route/presentation/inputs/address_input.dart';
import 'package:smgo/features/delivery_route/presentation/inputs/contact_name_input.dart';
import 'package:smgo/features/delivery_route/presentation/inputs/contact_phone_input.dart';
import 'package:smgo/features/delivery_route/presentation/inputs/location_input.dart';
import 'package:smgo/features/delivery_route/presentation/inputs/order_code_input.dart';

const Object _absent = Object();

class UpdateDeliveryOrderFormState extends Equatable with FormzMixin {
  final String deliveryRouteId;
  final String deliveryOrderId;
  final OrderCodeInput orderCodeInput;
  final String? orderMediaId;
  final String? orderMediaUrl;
  final String? orderName;
  final ContactNameInput contactNameInput;
  final ContactPhoneInput contactPhoneInput;
  final AddressInput addressInput;
  final String? appliedLocationId;
  final LocationInput locationInput;

  const UpdateDeliveryOrderFormState({
    required this.deliveryRouteId,
    required this.deliveryOrderId,
    this.orderCodeInput = const OrderCodeInput.pure(),
    this.orderMediaId,
    this.orderMediaUrl,
    this.orderName,
    this.contactNameInput = const ContactNameInput.pure(),
    this.contactPhoneInput = const ContactPhoneInput.pure(),
    this.addressInput = const AddressInput.pure(),
    this.appliedLocationId,
    this.locationInput = const LocationInput.pure(),
  });

  UpdateDeliveryOrderFormState.copy(UpdateDeliveryOrderFormState other)
    : deliveryRouteId = other.deliveryRouteId,
      deliveryOrderId = other.deliveryOrderId,
      orderCodeInput = other.orderCodeInput,
      orderMediaId = other.orderMediaId,
      orderMediaUrl = other.orderMediaUrl,
      orderName = other.orderName,
      contactNameInput = other.contactNameInput,
      contactPhoneInput = other.contactPhoneInput,
      addressInput = other.addressInput,
      appliedLocationId = other.appliedLocationId,
      locationInput = other.locationInput;

  UpdateDeliveryOrderFormState copyWith({
    OrderCodeInput? orderCodeInput,
    Object? orderMediaId = _absent,
    Object? orderMediaUrl = _absent,
    Object? orderName = _absent,
    ContactNameInput? contactNameInput,
    ContactPhoneInput? contactPhoneInput,
    AddressInput? addressInput,
    Object? appliedLocationId = _absent,
    LocationInput? locationInput,
  }) {
    return UpdateDeliveryOrderFormState(
      deliveryRouteId: deliveryRouteId,
      deliveryOrderId: deliveryOrderId,
      orderCodeInput: orderCodeInput ?? this.orderCodeInput,
      orderMediaId: orderMediaId == _absent
          ? this.orderMediaId
          : orderMediaId == null
          ? null
          : orderMediaId as String,
      orderMediaUrl: orderMediaUrl == _absent
          ? this.orderMediaUrl
          : orderMediaUrl == null
          ? null
          : orderMediaUrl as String,
      orderName: orderName == _absent
          ? this.orderName
          : orderName == null
          ? null
          : orderName as String,
      contactNameInput: contactNameInput ?? this.contactNameInput,
      contactPhoneInput: contactPhoneInput ?? this.contactPhoneInput,
      addressInput: addressInput ?? this.addressInput,
      appliedLocationId: appliedLocationId == _absent
          ? this.appliedLocationId
          : appliedLocationId == null
          ? null
          : appliedLocationId as String,
      locationInput: locationInput ?? this.locationInput,
    );
  }

  @override
  List<Object?> get props => [
    orderCodeInput,
    orderName,
    contactNameInput,
    contactPhoneInput,
    addressInput,
    locationInput,
    appliedLocationId,
    orderMediaId,
    deliveryRouteId,
  ];

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [
    orderCodeInput,
    contactNameInput,
    contactPhoneInput,
    addressInput,
    locationInput,
  ];
}

class UpdateDeliveryOrderFormInitial extends UpdateDeliveryOrderFormState {
  UpdateDeliveryOrderFormInitial({
    required super.deliveryRouteId,
    required super.deliveryOrderId,
  });
}

class UpdateDeliveryOrderFormLoading extends UpdateDeliveryOrderFormState {
  UpdateDeliveryOrderFormLoading({required UpdateDeliveryOrderFormState state})
    : super.copy(state);
}

class UpdateDeliveryOrderFormDone extends UpdateDeliveryOrderFormState {
  UpdateDeliveryOrderFormDone({required UpdateDeliveryOrderFormState state})
    : super.copy(state);
}

class UpdateDeliveryOrderFormFailed extends UpdateDeliveryOrderFormState {
  final Object error;

  UpdateDeliveryOrderFormFailed({
    required this.error,
    required UpdateDeliveryOrderFormState state,
  }) : super.copy(state);
}
