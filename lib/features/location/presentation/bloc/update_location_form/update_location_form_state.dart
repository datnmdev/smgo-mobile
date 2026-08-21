import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:shipgo/features/location/presentation/inputs/address.dart';
import 'package:shipgo/features/location/presentation/inputs/contact_name.dart';
import 'package:shipgo/features/location/presentation/inputs/contact_phone.dart';
import 'package:shipgo/features/location/presentation/inputs/location.dart';
import 'package:shipgo/features/location/presentation/inputs/location_name.dart';

class UpdateLocationFormState extends Equatable with FormzMixin {
  final LocationName locationName;
  final ContactName contactName;
  final ContactPhone contactPhone;
  final Address address;
  final Location location;
  final String? note;
  final List<String> mediaIds;

  const UpdateLocationFormState({
    this.locationName = const LocationName.pure(),
    this.contactName = const ContactName.pure(),
    this.contactPhone = const ContactPhone.pure(),
    this.address = const Address.pure(),
    this.location = const Location.pure(),
    this.note,
    this.mediaIds = const [],
  });

  UpdateLocationFormState.from(UpdateLocationFormState other)
    : locationName = other.locationName,
      contactName = other.contactName,
      contactPhone = other.contactPhone,
      address = other.address,
      location = other.location,
      note = other.note,
      mediaIds = other.mediaIds;

  UpdateLocationFormState copyWith({
    LocationName? locationName,
    ContactName? contactName,
    ContactPhone? contactPhone,
    Address? address,
    Location? location,
    String? note,
    List<String>? mediaIds,
  }) {
    return UpdateLocationFormState(
      locationName: locationName ?? this.locationName,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      address: address ?? this.address,
      location: location ?? this.location,
      note: note ?? this.note,
      mediaIds: mediaIds ?? this.mediaIds,
    );
  }

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [
    locationName,
    contactName,
    contactPhone,
    address,
    location,
  ];

  @override
  List<Object?> get props => [
    locationName,
    contactName,
    contactPhone,
    address,
    note,
    location,
    mediaIds,
  ];
}

class UpdateLocationFormInitial extends UpdateLocationFormState {
  UpdateLocationFormInitial({required UpdateLocationFormState state})
    : super.from(state);
}

class UpdateLocationFormLoading extends UpdateLocationFormState {
  UpdateLocationFormLoading({required UpdateLocationFormState state})
    : super.from(state);
}

class UpdateLocationFormDone extends UpdateLocationFormState {
  UpdateLocationFormDone({required UpdateLocationFormState state})
    : super.from(state);
}

class UpdateLocationFormFailed extends UpdateLocationFormState {
  final Object error;

  UpdateLocationFormFailed({
    required UpdateLocationFormState state,
    required this.error,
  }) : super.from(state);
}
