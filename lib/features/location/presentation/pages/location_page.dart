import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/core/resources/app_assets.dart';
import 'package:shipgo/core/resources/app_colors.dart';
import 'package:shipgo/core/resources/app_strings.dart';
import 'package:shipgo/core/resources/data_state.dart';
import 'package:shipgo/dependency_injection.dart';
import 'package:shipgo/features/location/domain/entities/location_entity.dart';
import 'package:shipgo/features/location/domain/usecases/delete_location_usecase.dart';
import 'package:shipgo/features/location/domain/usecases/get_my_locations_usecase.dart';
import 'package:shipgo/features/location/presentation/bloc/get_my_locations/get_my_locations_cubit.dart';
import 'package:shipgo/features/location/presentation/bloc/get_my_locations/get_my_locations_state.dart';
import 'package:shipgo/features/location/presentation/bloc/location_selection/location_selection_cubit.dart';
import 'package:shipgo/features/location/presentation/bloc/location_selection/location_selection_state.dart';
import 'package:shipgo/features/location/presentation/bloc/search_locations/search_locations_cubit.dart';
import 'package:shipgo/features/location/presentation/bloc/search_locations/search_locations_state.dart';
import 'package:shipgo/features/location/presentation/widgets/location_contact_card.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider<GetMyLocationsCubit>(
            create: (context) =>
                di<GetMyLocationsCubit>()..call(GetMyLocationsParams()),
          ),
          BlocProvider<LocationSelectionCubit>(
            create: (context) => di<LocationSelectionCubit>(),
          ),
          BlocProvider<SearchLocationsCubit>(
            create: (context) => di<SearchLocationsCubit>(),
          ),
        ],
        child: Column(
          children: [
            const _Header(),
            const Expanded(child: _Body()),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.8 * 255).round()),
            offset: Offset(0, 0),
            blurRadius: 8,
          ),
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: statusBarHeight),
            Text(
              AppStrings.lPPageTitle.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),

            SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child:
                      BlocBuilder<SearchLocationsCubit, SearchLocationsState>(
                        builder: (searchLocationContext, state) => TextField(
                          onChanged: (value) {
                            searchLocationContext
                                .read<SearchLocationsCubit>()
                                .call(
                                  searchText: value,
                                  cb: () {
                                    context.read<GetMyLocationsCubit>().call(
                                      GetMyLocationsParams(keyword: value),
                                    );
                                  },
                                );
                          },
                          decoration: InputDecoration(
                            hintText: AppStrings.lPSearchLocationHintText.tr(),
                            hintStyle: const TextStyle(color: Colors.black),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                ),

                const SizedBox(width: 8),

                // Nút thêm địa điểm
                IconButton.filledTonal(
                  onPressed: () {
                    context.pushNamed(
                      AppRouteNames.addLocation,
                      extra: <String, Object>{
                        'GetMyLocationsCubitInLP': context
                            .read<GetMyLocationsCubit>(),
                        'GetMyLocationsParamsInLP': GetMyLocationsParams(
                          keyword: context
                              .read<SearchLocationsCubit>()
                              .state
                              .searchText,
                        ),
                      },
                    );
                  },
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetMyLocationsCubit, GetMyLocationsState>(
      builder: (context, state) {
        final data = state.data?.data ?? [];
        late Widget content = ListView(
          padding: const EdgeInsets.all(0),
          children: [
            for (int i = 0; i < data.length; ++i)
              Column(
                children: [
                  if (i == 0) SizedBox(height: 16),
                  _LocationContactCardItem(
                    key: Key(data[i].id),
                    location: data[i],
                  ),
                  SizedBox(height: i == data.length - 1 ? 16 : 8),
                ],
              ),
          ],
        );

        if (state is GetMyLocationsLoading) {
          if (state.data == null) {
            content = Center(child: CircularProgressIndicator());
          }
        } else if (state is GetMyLocationsDone) {
          if (state.data!.meta.totalCount == 0) {
            content = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppAssets.locationEmpty,
                  width: 132,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 8),
                Text(
                  AppStrings.lPDataEmptyTitle.tr(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  AppStrings.lPDataEmptyDesc.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          context.pushNamed(
                            AppRouteNames.addLocation,
                            extra: <String, Object>{
                              'GetMyLocationsCubitInLP': context
                                  .read<GetMyLocationsCubit>(),
                              'GetMyLocationsParamsInLP': GetMyLocationsParams(
                                keyword: context
                                    .read<SearchLocationsCubit>()
                                    .state
                                    .searchText,
                              ),
                            },
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Text(
                            AppStrings.lPAddLocationButtonTitle.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        } else if (state is GetMyLocationsFailed) {
          content = Center(child: Text(AppStrings.lPErrorMessage.tr()));
        }

        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            children: [
              BlocBuilder<LocationSelectionCubit, LocationSelectionState>(
                buildWhen: (previous, current) => current != previous,
                builder: (context, state) => state.isActivated
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Transform.scale(
                                    scale: 1.4,
                                    child: Checkbox(
                                      value:
                                          context
                                              .read<GetMyLocationsCubit>()
                                              .state
                                              .data
                                              ?.meta
                                              .totalCount ==
                                          state.selectedLocationIdsSet.length,
                                      onChanged: (bool? value) {
                                        final cubit = context
                                            .read<LocationSelectionCubit>();
                                        if (value == true) {
                                          final locations = context
                                              .read<GetMyLocationsCubit>()
                                              .state
                                              .data;
                                          if (locations != null) {
                                            for (final location
                                                in locations.data) {
                                              cubit.selectLocation(location.id);
                                            }
                                          }
                                        } else {
                                          cubit.clearSelection();
                                        }
                                      },
                                      activeColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppStrings.lPSelectAllButtonTitle.tr(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                // Nút Xóa
                                BlocBuilder<
                                  LocationSelectionCubit,
                                  LocationSelectionState
                                >(
                                  buildWhen: (previous, current) =>
                                      previous != current,
                                  builder: (context, state) => Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withAlpha(
                                            35,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(14),
                                        onTap:
                                            !state.isDeletingSelectedLocations
                                            ? () {
                                                if (state
                                                    .selectedLocationIdsSet
                                                    .isEmpty)
                                                  return;

                                                // 1. Lấy tham chiếu 2 Cubit từ Context của MÀN HÌNH (trước khi mở dialog)
                                                final locationSelectionCubit =
                                                    context
                                                        .read<
                                                          LocationSelectionCubit
                                                        >();
                                                final getMyLocationsCubit =
                                                    context
                                                        .read<
                                                          GetMyLocationsCubit
                                                        >();
                                                final searchLocationCubit =
                                                    context
                                                        .read<
                                                          SearchLocationsCubit
                                                        >();

                                                // Hiển thị Dialog
                                                showDialog(
                                                  context: context,
                                                  builder: (dialogContext) => BlocProvider.value(
                                                    // 2. Truyền Cubit vào cây widget của Dialog
                                                    value:
                                                        locationSelectionCubit,
                                                    child:
                                                        BlocBuilder<
                                                          LocationSelectionCubit,
                                                          LocationSelectionState
                                                        >(
                                                          builder:
                                                              (
                                                                builderContext,
                                                                dialogState,
                                                              ) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                    AppStrings
                                                                        .lPDeleteSelectedLocationsDialogTitle
                                                                        .tr(),
                                                                  ),
                                                                  content: Text(
                                                                    AppStrings.lPDeleteSelectedLocationsDialogContent.tr(
                                                                      namedArgs: {
                                                                        'quantity': state
                                                                            .selectedLocationIdsSet
                                                                            .length
                                                                            .toString(),
                                                                      },
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    // Nút Hủy
                                                                    TextButton(
                                                                      onPressed:
                                                                          !dialogState
                                                                              .isDeletingSelectedLocations
                                                                          ? () => Navigator.of(
                                                                              dialogContext,
                                                                            ).pop()
                                                                          : null,
                                                                      style: TextButton.styleFrom(
                                                                        foregroundColor:
                                                                            Colors.green,
                                                                      ),
                                                                      child: Text(
                                                                        AppStrings
                                                                            .lPDeleteSelectedLocationsDialogCancelBtnTitle
                                                                            .tr(),
                                                                      ),
                                                                    ),

                                                                    // Nút Đồng ý xóa
                                                                    TextButton(
                                                                      onPressed:
                                                                          !dialogState
                                                                              .isDeletingSelectedLocations
                                                                          ? () async {
                                                                              locationSelectionCubit.startDeleteSelectedLocations();

                                                                              // Thực hiện xoá lần lượt các mục
                                                                              await Future.wait(
                                                                                locationSelectionCubit.state.selectedLocationIdsSet.map(
                                                                                  (
                                                                                    locationId,
                                                                                  ) async {
                                                                                    final dataState =
                                                                                        await di<
                                                                                              DeleteLocationUsecase
                                                                                            >()
                                                                                            .call(
                                                                                              params: DeleteLocationParams(
                                                                                                locationId: locationId,
                                                                                              ),
                                                                                            );
                                                                                    if (dataState
                                                                                        is DataSuccess) {
                                                                                      locationSelectionCubit.deselectLocation(
                                                                                        locationId,
                                                                                      );
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              );

                                                                              locationSelectionCubit.endDeleteSelectedLocations();

                                                                              // 3. Dùng biến đã lưu từ trước, không dùng context.read() ở đây nữa
                                                                              getMyLocationsCubit.call(
                                                                                GetMyLocationsParams(
                                                                                  keyword: searchLocationCubit.state.searchText,
                                                                                ),
                                                                              );

                                                                              // Đóng Dialog
                                                                              if (dialogContext.mounted) {
                                                                                Navigator.of(
                                                                                  dialogContext,
                                                                                ).pop();
                                                                              }
                                                                            }
                                                                          : null,
                                                                      style: TextButton.styleFrom(
                                                                        foregroundColor:
                                                                            Colors.red,
                                                                      ),
                                                                      child:
                                                                          dialogState
                                                                              .isDeletingSelectedLocations
                                                                          ? const SizedBox(
                                                                              width: 16,
                                                                              height: 16,
                                                                              child: CircularProgressIndicator(
                                                                                color: Colors.red,
                                                                                strokeWidth: 2,
                                                                              ),
                                                                            )
                                                                          : Text(
                                                                              AppStrings.lPDeleteSelectedLocationsDialogDBtnTitle.tr(),
                                                                            ),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                        ),
                                                  ),
                                                );
                                              }
                                            : null,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.delete_outline_outlined,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                AppStrings.lPDeleteButtonTitle.tr(
                                                  namedArgs: {
                                                    'quantity': state
                                                        .selectedLocationIdsSet
                                                        .length
                                                        .toString(),
                                                  },
                                                ),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Nút thoát chế độ chọn nhiều
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  color: AppColors.primary,
                                  onPressed: () {
                                    context.read<LocationSelectionCubit>()
                                      ..disableSelectionMode()
                                      ..clearSelection();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<GetMyLocationsCubit>().call(
                      GetMyLocationsParams(
                        keyword: context
                            .read<SearchLocationsCubit>()
                            .state
                            .searchText,
                      ),
                    );
                  },
                  child: content is! ListView
                      ? CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: content,
                            ),
                          ],
                        )
                      : content,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LocationContactCardItem extends StatelessWidget {
  final LocationEntity location;

  const _LocationContactCardItem({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BlocBuilder<LocationSelectionCubit, LocationSelectionState>(
          buildWhen: (previous, current) => current != previous,
          builder: (context, state) => state.isActivated
              ? Column(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Transform.scale(
                        scale: 1.4,
                        child: Checkbox(
                          value: state.selectedLocationIdsSet.contains(
                            location.id,
                          ),
                          onChanged: (bool? value) {
                            final cubit = context
                                .read<LocationSelectionCubit>();
                            if (value == true) {
                              cubit.selectLocation(location.id);
                            } else {
                              cubit.deselectLocation(location.id);
                            }
                          },
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                )
              : SizedBox.shrink(),
        ),
        Expanded(
          child: LocationContactCard(
            onTap: () {
              final cubit = context.read<LocationSelectionCubit>();
              if (cubit.state.isActivated) {
                if (cubit.state.selectedLocationIdsSet.contains(location.id)) {
                  cubit.deselectLocation(location.id);
                } else {
                  cubit.selectLocation(location.id);
                }
              } else {
                context.pushNamed(
                  AppRouteNames.locationDetail,
                  pathParameters: {'id': location.id},
                  extra: <String, Object>{
                    'LocationData': location,
                    'GetMyLocationsCubitInLP': context
                        .read<GetMyLocationsCubit>(),
                    'GetMyLocationsParamsInLP': GetMyLocationsParams(
                      keyword: context
                          .read<SearchLocationsCubit>()
                          .state
                          .searchText,
                    ),
                  },
                );
              }
            },
            onLongPress: () {
              context.read<LocationSelectionCubit>()
                ..enableSelectionMode()
                ..selectLocation(location.id);
            },
            locationName: location.locationName,
            contactName: location.contactName,
            contactPhone: location.contactPhone,
            media: location.media.map((e) => e.fileKey).toList(),
          ),
        ),
      ],
    );
  }
}
