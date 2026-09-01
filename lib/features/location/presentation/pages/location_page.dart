import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:smgo/core/config/app_route_names.dart';
import 'package:smgo/core/resources/app_assets.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/core/resources/app_strings.dart';
import 'package:smgo/dependency_injection.dart';

import 'package:smgo/features/location/presentation/bloc/delete_locations/delete_locations_cubit.dart';
import 'package:smgo/features/location/domain/usecases/get_my_locations_usecase.dart';
import 'package:smgo/features/location/presentation/bloc/delete_locations/delete_locations_state.dart';
import 'package:smgo/features/location/presentation/bloc/get_my_locations/get_my_locations_cubit.dart';
import 'package:smgo/features/location/presentation/bloc/get_my_locations/get_my_locations_state.dart';
import 'package:smgo/features/location/presentation/bloc/search_locations/search_locations_cubit.dart';
import 'package:smgo/features/location/presentation/bloc/search_locations/search_locations_state.dart';

import 'package:smgo/shared/domain/entities/location_entity.dart';
import 'package:smgo/features/location/presentation/widgets/location_contact_card.dart';
import 'package:smgo/shared/presentation/bloc/selection/selection_cubit.dart';
import 'package:smgo/shared/presentation/bloc/selection/selection_state.dart';
import 'package:smgo/shared/presentation/widgets/smgo_button.dart';
import 'package:smgo/shared/presentation/widgets/smgo_checkbox.dart';
import 'package:smgo/shared/utils/app_dialog_utils.dart';

/// ===============================================================
/// LOCATION PAGE
/// ===============================================================

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// ---------------------------------------------------------------
  /// ADD LOCATION
  /// ---------------------------------------------------------------

  void _addLocation(BuildContext context) {
    context.pushNamed(
      AppRouteNames.addLocation,
      extra: <String, Object>{
        'GetMyLocationsCubitInLP': context.read<GetMyLocationsCubit>(),
        'GetMyLocationsParamsInLP': GetMyLocationsParams(
          keyword: context.read<SearchLocationsCubit>().state.searchText,
        ),
      },
    );
  }

  /// ---------------------------------------------------------------
  /// DELETE SELECTED LOCATIONS
  ///
  /// Giữ nguyên flow delete hiện tại:
  /// 1. Lấy selection cubit
  /// 2. Gọi DeleteLocationsCubit
  /// 3. Clear selection
  /// 4. Reload locations
  /// 5. Đóng dialog
  /// ---------------------------------------------------------------

  void _deleteSelectedLocations(BuildContext parentContext) {
    final selectionCubit = parentContext.read<SelectionCubit<String>>();

    final selectedIds = selectionCubit.state.selectedItems.toList();

    if (selectedIds.isEmpty) {
      return;
    }

    AppDialogUtils.showCustomDialog(
      context: parentContext,
      iconData: Icons.delete_forever,
      title: AppStrings.lPDeleteSelectedLocationsDialogTitle.tr(),
      subtitle: AppStrings.lPDeleteSelectedLocationsDialogContent.tr(
        namedArgs: {'quantity': selectedIds.length.toString()},
      ),
      barrierDismissible: false,
      actions: [
        BlocProvider<DeleteLocationsCubit>(
          create: (_) => di<DeleteLocationsCubit>(),
          child: BlocConsumer<DeleteLocationsCubit, DeleteLocationsState>(
            listener: (consumerContext, state) {
              /// =====================================================
              /// DELETE SUCCESS
              /// =====================================================
              if (state is DeleteLocationsDone) {
                // Giữ nguyên luồng reload danh sách
                parentContext.read<GetMyLocationsCubit>().call(
                  GetMyLocationsParams(
                    keyword: parentContext
                        .read<SearchLocationsCubit>()
                        .state
                        .searchText,
                  ),
                );

                // Đóng dialog
                consumerContext.pop();

                // Hiển thị thông báo thành công
                AppDialogUtils.showSuccess(
                  context: parentContext,
                  title: 'Xoá địa điểm thành công',
                  subtitle: '${selectedIds.length} địa điểm đã bị xoá',
                );

                selectionCubit.closeSelectionMode();
              }
              /// =====================================================
              /// DELETE FAILED
              /// =====================================================
              else if (state is DeleteLocationsFailed) {
                AppDialogUtils.showError(
                  context: parentContext,
                  title: 'Xoá địa điểm thất bại!',
                  subtitle: 'Đã xảy ra lỗi. Vui lòng thử lại.',
                );
              }
            },

            builder: (consumerContext, state) {
              final isLoading = state is DeleteLocationsLoading;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// =================================================
                    /// CANCEL
                    /// =================================================
                    Expanded(
                      child: SmgoButton(
                        primaryColor: AppColors.primary,
                        text: AppStrings
                            .lPDeleteSelectedLocationsDialogCancelBtnTitle
                            .tr(),
                        isOutlined: true,
                        isDisabled: isLoading,
                        onPressed: () {
                          consumerContext.pop();
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// =================================================
                    /// DELETE
                    /// =================================================
                    Expanded(
                      child: SmgoButton(
                        primaryColor: AppColors.primary,
                        isDisabled: isLoading,
                        onPressed: () {
                          consumerContext.read<DeleteLocationsCubit>().call(
                            locationIds: selectedIds,
                          );
                        },
                        child: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                AppStrings
                                    .lPDeleteSelectedLocationsDialogDBtnTitle
                                    .tr(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GetMyLocationsCubit>(
          create: (context) =>
              di<GetMyLocationsCubit>()..call(GetMyLocationsParams()),
        ),

        BlocProvider<SelectionCubit<String>>(
          create: (context) => di<SelectionCubit<String>>(),
        ),

        BlocProvider<SearchLocationsCubit>(
          create: (context) => di<SearchLocationsCubit>(),
        ),
      ],
      child: BlocBuilder<GetMyLocationsCubit, GetMyLocationsState>(
        builder: (context, state) => Scaffold(
          body: Column(
            children: [
              _LocationHeader(
                searchController: _searchController,
                onAddLocation: () {
                  _addLocation(context);
                },
                onCloseSelection: () {
                  context.read<SelectionCubit<String>>().closeSelectionMode();
                },
                onDeleteSelected: () {
                  _deleteSelectedLocations(context);
                },
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
                  child: _LocationBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===============================================================
/// LOCATION HEADER
///
/// Thiết kế theo CustomHeaderWithTabBar của Route Page.
/// ===============================================================

class _LocationHeader extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onAddLocation;
  final VoidCallback onCloseSelection;
  final VoidCallback onDeleteSelected;

  const _LocationHeader({
    required this.searchController,
    required this.onAddLocation,
    required this.onCloseSelection,
    required this.onDeleteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectionCubit<String>, SelectionState<String>>(
      builder: (context, selectionState) {
        final bool isSelectionMode = selectionState.isEnabled;
        final int selectedCount = selectionState.selectedItems.length;

        return Container(
          width: double.infinity,
          color: AppColors.primary,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top),

              /// =================================================
              /// TITLE / SELECTION HEADER
              /// =================================================
              if (isSelectionMode)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// CLOSE
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onCloseSelection,
                    ),

                    /// SELECTED COUNT
                    Expanded(
                      child: Center(
                        child: Text(
                          '$selectedCount địa điểm đã chọn',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    /// DELETE
                    TextButton.icon(
                      onPressed: selectedCount > 0 ? onDeleteSelected : null,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        selectedCount > 0 ? 'Xoá ($selectedCount)' : 'Xoá',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.lPPageTitle.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 12),

              /// =================================================
              /// SEARCH + ADD
              /// =================================================
              Row(
                children: [
                  /// SEARCH
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          BlocBuilder<
                            SearchLocationsCubit,
                            SearchLocationsState
                          >(
                            builder: (searchContext, searchState) {
                              return TextField(
                                controller: searchController,
                                onTapOutside: (_) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                onChanged: (value) {
                                  final searchLocaitonCubit = searchContext
                                      .read<SearchLocationsCubit>();
                                  searchLocaitonCubit.searchTextChanged(value);
                                  searchLocaitonCubit.submit(
                                    cb: () async {
                                      await context
                                          .read<GetMyLocationsCubit>()
                                          .call(
                                            GetMyLocationsParams(
                                              keyword: value,
                                            ),
                                          );
                                    },
                                  );
                                },
                                decoration: InputDecoration(
                                  hintText: AppStrings.lPSearchLocationHintText
                                      .tr(),
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 44,
                                    minHeight: 44,
                                  ),
                                  prefixIcon:
                                      searchState is SearchLocationsLoading
                                      ? const UnconstrainedBox(
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.search,
                                          color: Colors.grey,
                                        ),
                                  border: InputBorder.none,
                                ),
                              );
                            },
                          ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// =================================================
                  /// ADD BUTTON
                  ///
                  /// Giống chính xác style nút Add Route:
                  /// transparent + border trắng + icon + text.
                  /// =================================================
                  ElevatedButton.icon(
                    onPressed: onAddLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      side: const BorderSide(color: Colors.white70, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      AppStrings.lPAddLocationButtonTitle.tr(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ===============================================================
/// LOCATION BODY
/// ===============================================================

class _LocationBody extends StatelessWidget {
  const _LocationBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetMyLocationsCubit, GetMyLocationsState>(
      builder: (context, state) {
        final data = state.data?.data ?? [];
        Widget content;
        if (state is GetMyLocationsLoading && state.data == null) {
          content = CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        } else if (state is GetMyLocationsDone &&
            state.data!.meta.totalCount == 0) {
          content = CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(context),
              ),
            ],
          );
        } else if (state is GetMyLocationsFailed) {
          content = CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: Colors.redAccent,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          AppStrings.lPErrorMessage.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 16),

                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<GetMyLocationsCubit>().call(
                              GetMyLocationsParams(
                                keyword: context
                                    .read<SearchLocationsCubit>()
                                    .state
                                    .searchText,
                              ),
                            );
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          content = ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final location = data[index];

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == data.length - 1 ? 0 : 8,
                ),
                child: _LocationContactCardItem(
                  key: Key(location.id),
                  location: location,
                ),
              );
            },
          );
        }

        /// =========================================================
        /// SELECTION
        /// =========================================================

        return BlocBuilder<SelectionCubit<String>, SelectionState<String>>(
          builder: (context, selectionState) {
            return Column(
              children: [
                /// SELECT ALL
                if (selectionState.isEnabled && data.isNotEmpty)
                  _SelectionToolbar(locations: data),

                /// CONTENT
                Expanded(child: content),
              ],
            );
          },
        );
      },
    );
  }

  /// ---------------------------------------------------------------
  /// EMPTY STATE
  /// ---------------------------------------------------------------

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.locationEmpty,
              width: 132,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 8),

            Text(
              AppStrings.lPDataEmptyTitle.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              AppStrings.lPDataEmptyDesc.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),

            /// ADD LOCATION
            ElevatedButton.icon(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                AppStrings.lPAddLocationButtonTitle.tr(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// SELECTION TOOLBAR
///
/// Phần Select All chỉ xuất hiện khi selection mode.
/// Header phía trên đã đảm nhiệm phần:
/// Close / Count / Delete.
/// ===============================================================

class _SelectionToolbar extends StatelessWidget {
  final List<LocationEntity> locations;

  const _SelectionToolbar({required this.locations});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectionCubit<String>, SelectionState<String>>(
      builder: (context, state) {
        final bool isAllSelected =
            locations.isNotEmpty &&
            locations.every(
              (location) => state.selectedItems.contains(location.id),
            );

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// SELECT ALL
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  context.read<SelectionCubit<String>>().toggleSelectAll(
                    currentItems: locations
                        .map((location) => location.id)
                        .toList(),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: SmgoCheckbox(
                        value: isAllSelected,
                        onChanged: (_) {
                          context
                              .read<SelectionCubit<String>>()
                              .toggleSelectAll(
                                currentItems: locations
                                    .map((location) => location.id)
                                    .toList(),
                              );
                        },
                        primaryColor: AppColors.primary,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      AppStrings.lPSelectAllButtonTitle.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),

              /// COUNT
              Text(
                'Đã chọn ${state.selectedItems.length}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ===============================================================
/// LOCATION CARD ITEM
/// ===============================================================

class _LocationContactCardItem extends StatelessWidget {
  final LocationEntity location;

  const _LocationContactCardItem({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectionCubit<String>, SelectionState<String>>(
      builder: (context, state) {
        final bool isSelectionMode = state.isEnabled;

        final bool isSelected = state.selectedItems.contains(location.id);

        /// =========================================================
        /// NORMAL MODE
        /// =========================================================

        if (!isSelectionMode) {
          return LocationContactCard(
            onTap: () {
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
            },
            onLongPress: () {
              context.read<SelectionCubit<String>>().toggleSelection(
                item: location.id,
              );
            },
            locationName: location.locationName,
            contactName: location.contactName,
            contactPhone: location.contactPhone,
            media: location.media,
          );
        }

        /// =========================================================
        /// SELECTION MODE
        ///
        /// Checkbox nằm ngoài card giống Route Page.
        /// =========================================================

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// CHECKBOX
            SizedBox(
              width: 24,
              height: 24,
              child: SmgoCheckbox(
                value: isSelected,
                onChanged: (value) {
                  context.read<SelectionCubit<String>>().toggleSelection(
                    item: location.id,
                  );
                },
                primaryColor: AppColors.primary,
              ),
            ),

            const SizedBox(width: 8),

            /// CARD
            Expanded(
              child: LocationContactCard(
                onTap: () {
                  context.read<SelectionCubit<String>>().toggleSelection(
                    item: location.id,
                  );
                },
                locationName: location.locationName,
                contactName: location.contactName,
                contactPhone: location.contactPhone,
                media: location.media,
              ),
            ),
          ],
        );
      },
    );
  }
}
