import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:smgo/features/delivery_route/presentation/inputs/address_input.dart';
import 'package:smgo/features/delivery_route/presentation/inputs/contact_name_input.dart';
import 'package:smgo/features/delivery_route/presentation/inputs/contact_phone_input.dart';
import 'package:smgo/features/delivery_route/presentation/inputs/location_input.dart';
import 'package:smgo/features/delivery_route/presentation/inputs/order_code_input.dart';

const Object _absent = Object();

class AddDeliveryOrderFormState extends Equatable with FormzMixin {
  final String deliveryRouteId;
  final OrderCodeInput orderCodeInput;
  final String? orderMediaId;
  final String? orderName;
  final ContactNameInput contactNameInput;
  final ContactPhoneInput contactPhoneInput;
  final AddressInput addressInput;
  final String? appliedLocationId;
  final LocationInput locationInput;

  const AddDeliveryOrderFormState({
    required this.deliveryRouteId,
    this.orderCodeInput = const OrderCodeInput.pure(),
    this.orderMediaId,
    this.orderName,
    this.contactNameInput = const ContactNameInput.pure(),
    this.contactPhoneInput = const ContactPhoneInput.pure(),
    this.addressInput = const AddressInput.pure(),
    this.appliedLocationId,
    this.locationInput = const LocationInput.pure(),
  });

  AddDeliveryOrderFormState.copy(AddDeliveryOrderFormState other)
    : deliveryRouteId = other.deliveryRouteId,
      orderCodeInput = other.orderCodeInput,
      orderMediaId = other.orderMediaId,
      orderName = other.orderName,
      contactNameInput = other.contactNameInput,
      contactPhoneInput = other.contactPhoneInput,
      addressInput = other.addressInput,
      appliedLocationId = other.appliedLocationId,
      locationInput = other.locationInput;

  AddDeliveryOrderFormState copyWith({
    OrderCodeInput? orderCodeInput,
    Object? orderMediaId = _absent,
    Object? orderName = _absent,
    ContactNameInput? contactNameInput,
    ContactPhoneInput? contactPhoneInput,
    AddressInput? addressInput,
    Object? appliedLocationId = _absent,
    LocationInput? locationInput,
  }) {
    return AddDeliveryOrderFormState(
      deliveryRouteId: deliveryRouteId,
      orderCodeInput: orderCodeInput ?? this.orderCodeInput,
      orderMediaId: orderMediaId == _absent
          ? this.orderMediaId
          : orderMediaId == null
          ? null
          : orderMediaId as String,
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

class AddDeliveryOrderFormInitial extends AddDeliveryOrderFormState {
  AddDeliveryOrderFormInitial({required super.deliveryRouteId});
}

class AddDeliveryOrderFormLoading extends AddDeliveryOrderFormState {
  AddDeliveryOrderFormLoading({required AddDeliveryOrderFormState state})
    : super.copy(state);
}

class AddDeliveryOrderFormDone extends AddDeliveryOrderFormState {
  AddDeliveryOrderFormDone({required AddDeliveryOrderFormState state})
    : super.copy(state);
}

class AddDeliveryOrderFormFailed extends AddDeliveryOrderFormState {
  final Object error;

  AddDeliveryOrderFormFailed({
    required this.error,
    required AddDeliveryOrderFormState state,
  }) : super.copy(state);
}
