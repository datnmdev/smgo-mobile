import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/address_input.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/contact_name_input.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/contact_phone_input.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/location_input.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/order_code_input.dart';
import 'package:shipgo/features/delivery_route/presentation/inputs/order_name_input.dart';

class AddDeliveryOrderFormState extends Equatable with FormzMixin {
  final String deliveryRouteId;
  final OrderCodeInput orderCodeInput;
  final String? orderMediaId;
  final OrderNameInput orderNameInput;
  final ContactNameInput contactNameInput;
  final ContactPhoneInput contactPhoneInput;
  final AddressInput addressInput;
  final String? appliedLocationId;
  final LocationInput locationInput;

  const AddDeliveryOrderFormState({
    required this.deliveryRouteId,
    this.orderCodeInput = const OrderCodeInput.pure(),
    this.orderMediaId,
    this.orderNameInput = const OrderNameInput.pure(),
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
      orderNameInput = other.orderNameInput,
      contactNameInput = other.contactNameInput,
      contactPhoneInput = other.contactPhoneInput,
      addressInput = other.addressInput,
      appliedLocationId = other.appliedLocationId,
      locationInput = other.locationInput;

  AddDeliveryOrderFormState copyWith({
    OrderCodeInput? orderCodeInput,
    String? orderMediaId,
    OrderNameInput? orderNameInput,
    ContactNameInput? contactNameInput,
    ContactPhoneInput? contactPhoneInput,
    AddressInput? addressInput,
    String? appliedLocationId,
    LocationInput? locationInput,
  }) {
    return AddDeliveryOrderFormState(
      deliveryRouteId: deliveryRouteId,
      orderCodeInput: orderCodeInput ?? this.orderCodeInput,
      orderMediaId: orderMediaId ?? this.orderMediaId,
      orderNameInput: orderNameInput ?? this.orderNameInput,
      contactNameInput: contactNameInput ?? this.contactNameInput,
      contactPhoneInput: contactPhoneInput ?? this.contactPhoneInput,
      addressInput: addressInput ?? this.addressInput,
      appliedLocationId: appliedLocationId ?? this.appliedLocationId,
      locationInput: locationInput ?? this.locationInput,
    );
  }

  @override
  List<Object?> get props => [
    orderCodeInput,
    orderNameInput,
    contactNameInput,
    contactPhoneInput,
    addressInput,
    locationInput,
  ];

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [
    orderCodeInput,
    orderNameInput,
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
