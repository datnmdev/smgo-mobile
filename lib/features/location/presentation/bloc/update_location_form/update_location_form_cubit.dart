import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:smgo/core/resources/data_state.dart';
import 'package:smgo/features/location/domain/repository/location_repository.dart';
import 'package:smgo/features/location/domain/usecases/update_location_usecase.dart';
import 'package:smgo/features/location/presentation/bloc/update_location_form/update_location_form_state.dart';
import 'package:smgo/features/location/presentation/inputs/address.dart';
import 'package:smgo/features/location/presentation/inputs/contact_name.dart';
import 'package:smgo/features/location/presentation/inputs/contact_phone.dart';
import 'package:smgo/features/location/presentation/inputs/location.dart';
import 'package:smgo/features/location/presentation/inputs/location_name.dart';
import 'package:smgo/shared/domain/entities/point_entity.dart';

class UpdateLocationFormCubit extends Cubit<UpdateLocationFormState> {
  final String locationId;
  final UpdateLocationUsecase updateLocationUsecase;

  UpdateLocationFormCubit({
    required this.updateLocationUsecase,
    required this.locationId,
  }) : super(UpdateLocationFormInitial(state: UpdateLocationFormState()));

  void locationNameChanged(String value) {
    emit(state.copyWith(locationName: LocationName.dirty(value)));
  }

  void contactNameChanged(String value) {
    emit(state.copyWith(contactName: ContactName.dirty(value)));
  }

  void contactPhoneChanged(String value) {
    emit(state.copyWith(contactPhone: ContactPhone.dirty(value)));
  }

  void addressChanged(String value) {
    emit(state.copyWith(address: Address.dirty(value)));
  }

  void locationChanged(LatLng? location) {
    emit(
      state.copyWith(
        location: Location.dirty(
          location != null
              ? PointEntity(x: location.longitude, y: location.latitude)
              : null,
        ),
      ),
    );
  }

  void noteChanged(String value) {
    emit(state.copyWith(note: value));
  }

  void mediaIdsChanged(List<String> mediaIds) {
    emit(state.copyWith(mediaIds: mediaIds));
  }

  void submit() async {
    final locationName = LocationName.dirty(state.locationName.value);
    final contactName = ContactName.dirty(state.contactName.value);
    final contactPhone = ContactPhone.dirty(state.contactPhone.value);
    final address = Address.dirty(state.address.value);
    final location = Location.dirty(state.location.value);
    emit(
      state.copyWith(
        locationName: locationName,
        contactName: contactName,
        contactPhone: contactPhone,
        address: address,
        location: location,
      ),
    );
    if (state.isValid) {
      emit(UpdateLocationFormLoading(state: state));
      final dataState = await updateLocationUsecase.call(
        params: UpdateLocationUsecaseParams(
          locationId: locationId,
          locationName: state.locationName.value,
          contactName: state.contactName.value,
          contactPhone: state.contactPhone.value,
          address: state.address.value,
          location: LocationData(
            x: state.location.value!.x,
            y: state.location.value!.y,
          ),
          note: state.note,
          mediaIds: state.mediaIds,
        ),
      );
      if (dataState is DataSuccess) {
        emit(UpdateLocationFormDone(state: state));
      } else {
        emit(UpdateLocationFormFailed(state: state, error: dataState.error!));
      }
    }
  }
}
