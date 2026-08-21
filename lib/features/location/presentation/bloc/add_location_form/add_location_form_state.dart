import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:shipgo/features/location/presentation/inputs/address.dart';
import 'package:shipgo/features/location/presentation/inputs/contact_name.dart';
import 'package:shipgo/features/location/presentation/inputs/contact_phone.dart';
import 'package:shipgo/features/location/presentation/inputs/location.dart';
import 'package:shipgo/features/location/presentation/inputs/location_name.dart';

class AddLocationFormState extends Equatable with FormzMixin {
  final LocationName locationName;
  final ContactName contactName;
  final ContactPhone contactPhone;
  final Address address;
  final Location location;
  final String? note;
  final List<String> mediaIds;

  const AddLocationFormState({
    this.locationName = const LocationName.pure(),
    this.contactName = const ContactName.pure(),
    this.contactPhone = const ContactPhone.pure(),
    this.address = const Address.pure(),
    this.location = const Location.pure(),
    this.note,
    this.mediaIds = const [],
  });

  AddLocationFormState.from(AddLocationFormState other)
    : locationName = other.locationName,
      contactName = other.contactName,
      contactPhone = other.contactPhone,
      address = other.address,
      location = other.location,
      note = other.note,
      mediaIds = other.mediaIds;

  AddLocationFormState copyWith({
    LocationName? locationName,
    ContactName? contactName,
    ContactPhone? contactPhone,
    Address? address,
    Location? location,
    String? note,
    List<String>? mediaIds,
  }) {
    return AddLocationFormState(
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

class AddLocationFormInitial extends AddLocationFormState {
  AddLocationFormInitial({required AddLocationFormState state})
    : super.from(state);
}

class AddLocationFormLoading extends AddLocationFormState {
  AddLocationFormLoading({required AddLocationFormState state})
    : super.from(state);
}

class AddLocationFormDone extends AddLocationFormState {
  AddLocationFormDone({required AddLocationFormState state})
    : super.from(state);
}

class AddLocationFormFailed extends AddLocationFormState {
  final Object error;

  AddLocationFormFailed({
    required AddLocationFormState state,
    required this.error,
  }) : super.from(state);
}
