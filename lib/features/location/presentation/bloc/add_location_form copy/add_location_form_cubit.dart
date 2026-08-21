import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/shared/widgets/m3_image_picker.dart';
import 'package:shipgo/features/location/data/models/point_model.dart';
import 'package:shipgo/features/location/domain/repository/location_repository.dart';
import 'package:shipgo/features/location/domain/usecases/add_location_usecase.dart';
import 'package:shipgo/features/location/presentation/bloc/add_location_form/add_location_form_state.dart';
import 'package:shipgo/features/location/presentation/inputs/address.dart';
import 'package:shipgo/features/location/presentation/inputs/contact_name.dart';
import 'package:shipgo/features/location/presentation/inputs/contact_phone.dart';
import 'package:shipgo/features/location/presentation/inputs/location.dart';
import 'package:shipgo/features/location/presentation/inputs/location_name.dart';

class AddLocationFormCubit extends Cubit<AddLocationFormState> {
  final AddLocationUsecase addLocationUsecase;

  AddLocationFormCubit({required this.addLocationUsecase})
    : super(AddLocationFormInitial(state: AddLocationFormState()));

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
              ? PointModel(x: location.longitude, y: location.latitude)
              : null,
        ),
      ),
    );
  }

  void noteChanged(String value) {
    emit(state.copyWith(note: value));
  }

  void mediaIdsChanged(List<GridImageItem> value) {
    emit(state.copyWith(mediaIds: value.map((e) => e.id).toList()));
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
      emit(AddLocationFormLoading(state: state));
      final dataState = await addLocationUsecase.call(
        params: AddLocationParams(
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
        emit(AddLocationFormDone(state: state));
      } else {
        emit(AddLocationFormFailed(state: state, error: dataState.error!));
      }
    }
  }
}
