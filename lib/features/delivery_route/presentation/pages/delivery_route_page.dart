import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/core/resources/app_colors.dart';
import 'package:shipgo/core/resources/app_strings.dart';
import 'package:shipgo/dependency_injection.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_route_entity.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/get_delivery_routes_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/delete_delivery_routes/delete_delivery_routes_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/delete_delivery_routes/delete_delivery_routes_state.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_state.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/search_delivery_routes/search_delivery_routes_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/search_delivery_routes/search_delivery_routes_state.dart';
import 'package:shipgo/shared/presentation/widgets/smgo_checkbox.dart';

class DeliveryRoutePage extends StatefulWidget {
  const DeliveryRoutePage({Key? key}) : super(key: key);

  @override
  State<DeliveryRoutePage> createState() => _DeliveryRoutePageState();
}

class _DeliveryRoutePageState extends State<DeliveryRoutePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(id);
        _isSelectionMode = true;
      }
    });
  }

  void _toggleSelectAll(List<DeliveryRouteEntity> currentTabRoutes) {
    setState(() {
      final currentTabIds = currentTabRoutes.map((e) => e.id).toSet();
      final isAllSelected = currentTabIds.every(_selectedIds.contains);

      if (isAllSelected) {
        _selectedIds.removeAll(currentTabIds);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.addAll(currentTabIds);
        _isSelectionMode = true;
      }
    });
  }

  void _deleteSelected(BuildContext parentContext) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider<DeleteDeliveryRoutesCubit>(
        create: (_) => di<DeleteDeliveryRoutesCubit>(),
        child:
            BlocConsumer<DeleteDeliveryRoutesCubit, DeleteDeliveryRoutesState>(
              builder: (context, state) {
                final isLoading = state is DeleteDeliveryRoutesLoading;

                return AlertDialog(
                  title: Text(
                    AppStrings.rPDeleteSelectedRoutesDialogTitle.tr(),
                  ),
                  content: Text(
                    AppStrings.rPDeleteSelectedRoutesDialogContent.tr(
                      namedArgs: {'quantity': _selectedIds.length.toString()},
                    ),
                  ),
                  actions: [
                    // Nút Hủy
                    TextButton(
                      onPressed: !isLoading
                          ? () => Navigator.of(dialogContext).pop()
                          : null,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                      child: Text(
                        AppStrings.rPDeleteSelectedRoutesDialogCancelBtnTitle
                            .tr(),
                      ),
                    ),

                    // Nút Đồng ý xóa
                    TextButton(
                      onPressed: !isLoading
                          ? () {
                              context.read<DeleteDeliveryRoutesCubit>().call(
                                _selectedIds.toList(),
                              );
                            }
                          : null, // Disable nút khi đang xóa
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.red,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              AppStrings
                                  .rPDeleteSelectedRoutesDialogDeleteBtnTitle
                                  .tr(),
                            ),
                    ),
                  ],
                );
              },
              listener: (_, state) {
                if (state is DeleteDeliveryRoutesDone) {
                  parentContext.read<GetDeliveryRoutesCubit>().call(
                    params: GetDeliveryRoutesUsecaseParams(
                      keyword: parentContext
                          .read<SearchDeliveryRoutesCubit>()
                          .state
                          .searchText,
                    ),
                  );
                  dialogContext.pop();
                  setState(() {
                    _selectedIds.clear();
                    _isSelectionMode = false;
                  });
                }
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchDeliveryRoutesCubit>(
          create: (context) => di<SearchDeliveryRoutesCubit>(),
        ),
        BlocProvider<GetDeliveryRoutesCubit>(
          create: (context) =>
              di<GetDeliveryRoutesCubit>()
                ..call(params: GetDeliveryRoutesUsecaseParams()),
        ),
      ],
      child: BlocBuilder<GetDeliveryRoutesCubit, GetDeliveryRoutesState>(
        builder: (context, state) => Column(
          children: [
            // 1. HEADER CỐ ĐỊNH PHÍA TRÊN (Không bị trượt/thay đổi khi swipe tab)
            CustomHeaderWithTabBar(
              tabController: _tabController,
              isSelectionMode: _isSelectionMode,
              selectedCount: _selectedIds.length,
              searchController: _searchController,
              onCloseSelection: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedIds.clear();
                });
              },
              onDeleteSelected: () => _deleteSelected(context),
              onAddRoute: () {
                context.pushNamed(
                  AppRouteNames.addDeliveryRoute,
                  extra: <String, Object>{
                    'GetDeliveryRoutesCubitInRP': context
                        .read<GetDeliveryRoutesCubit>(),
                    'GetDeliveryRoutesUsecaseParamsInRP':
                        GetDeliveryRoutesUsecaseParams(
                          keyword: context
                              .read<SearchDeliveryRoutesCubit>()
                              .state
                              .searchText,
                        ),
                  },
                );
              },
            ),

            // 2. VÙNG NỘI DUNG THAY ĐỔI THEO TAB
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  RouteListTabView<PendingRouteCardItem>(
                    routes: state.routes
                        .where((e) => e.status == 'pending')
                        .toList(),
                    hasError: state is GetDeliveryRoutesFailed,
                    isLoading:
                        state.isFirstLoad && state is GetDeliveryRoutesLoading,
                    isSelectionMode: _isSelectionMode,
                    selectedIds: _selectedIds,
                    onToggleSelection: _toggleSelection,
                    onToggleSelectAll: _toggleSelectAll,
                  ),
                  RouteListTabView<SortingRouteCardItem>(
                    routes: state.routes
                        .where((e) => e.status == 'sorting')
                        .toList(),
                    hasError: state is GetDeliveryRoutesFailed,
                    isLoading:
                        state.isFirstLoad && state is GetDeliveryRoutesLoading,
                    isSelectionMode: _isSelectionMode,
                    selectedIds: _selectedIds,
                    onToggleSelection: _toggleSelection,
                    onToggleSelectAll: _toggleSelectAll,
                  ),
                  RouteListTabView<DeliveringRouteCardItem>(
                    routes: state.routes
                        .where((e) => e.status == 'delivering')
                        .toList(),
                    hasError: state is GetDeliveryRoutesFailed,
                    isLoading:
                        state.isFirstLoad && state is GetDeliveryRoutesLoading,
                    isSelectionMode: _isSelectionMode,
                    selectedIds: _selectedIds,
                    onToggleSelection: _toggleSelection,
                    onToggleSelectAll: _toggleSelectAll,
                  ),
                  RouteListTabView<DeliveringRouteCardItem>(
                    routes: state.routes
                        .where((e) => e.status == 'completed')
                        .toList(),
                    hasError: state is GetDeliveryRoutesFailed,
                    isLoading:
                        state.isFirstLoad && state is GetDeliveryRoutesLoading,
                    isSelectionMode: _isSelectionMode,
                    selectedIds: _selectedIds,
                    onToggleSelection: _toggleSelection,
                    onToggleSelectAll: _toggleSelectAll,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RouteListTabView<T> extends StatefulWidget {
  final List<DeliveryRouteEntity> routes;
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggleSelection;
  final ValueChanged<List<DeliveryRouteEntity>> onToggleSelectAll;

  // Các thuộc tính trạng thái kích hoạt từ bên ngoài
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;

  // Tùy chỉnh giao diện (tùy chọn)
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;

  const RouteListTabView({
    Key? key,
    required this.routes,
    required this.isSelectionMode,
    required this.selectedIds,
    required this.onToggleSelection,
    required this.onToggleSelectAll,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.onRetry,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
  }) : super(key: key);

  @override
  State<RouteListTabView<T>> createState() => _RouteListTabViewState<T>();
}

class _RouteListTabViewState<T> extends State<RouteListTabView<T>>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final body = _buildBody();

    return Column(
      children: [
        if (widget.isSelectionMode &&
            !widget.isLoading &&
            !widget.hasError &&
            widget.routes.isNotEmpty)
          _buildSelectionHeader(),

        // Nội dung chính theo trạng thái
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<GetDeliveryRoutesCubit>().call(
                params: GetDeliveryRoutesUsecaseParams(
                  keyword: context
                      .read<SearchDeliveryRoutesCubit>()
                      .state
                      .searchText,
                ),
              );
            },
            child: body is ListView
                ? body
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(child: body),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  /// Thanh chọn tất cả & đếm số lượng
  Widget _buildSelectionHeader() {
    final isAllSelectedInThisTab =
        widget.routes.isNotEmpty &&
        widget.routes.every((e) => widget.selectedIds.contains(e.id));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => widget.onToggleSelectAll(widget.routes),
            child: Row(
              children: [
                SmgoCheckbox(
                  primaryColor: AppColors.primary,
                  value: isAllSelectedInThisTab,
                  onChanged: (_) => widget.onToggleSelectAll(widget.routes),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.rPSelectAllBtnLabel.tr(),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Text(
            AppStrings.rPSelectedRoutesCountContent.tr(
              namedArgs: {'quantity': widget.selectedIds.length.toString()},
            ),
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Điều hướng hiển thị UI theo trạng thái
  Widget _buildBody() {
    // 1. Trạng thái Loading
    if (widget.isLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    // 2. Trạng thái Error
    if (widget.hasError) {
      return widget.errorWidget ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.errorMessage ?? AppStrings.rPErrorMessage.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  if (widget.onRetry != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: widget.onRetry,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(AppStrings.rPRetryLabel.tr()),
                    ),
                  ],
                ],
              ),
            ),
          );
    }

    // 3. Trạng thái Empty
    if (widget.routes.isEmpty) {
      return widget.emptyWidget ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  AppStrings.rPDataEmpty.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
    }

    // 4. Trạng thái bình thường (Danh sách lộ trình)
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.routes.length,
      itemBuilder: (context, index) {
        final item = widget.routes[index];
        final isSelected = widget.selectedIds.contains(item.id);
        if (T == PendingRouteCardItem) {
          return PendingRouteCardItem(
            item: item,
            isSelectionMode: widget.isSelectionMode,
            isSelected: isSelected,
            onTap: () {
              if (widget.isSelectionMode) {
                widget.onToggleSelection(item.id);
              } else {
                context.pushNamed(
                  AppRouteNames.deliveryRouteDetail,
                  pathParameters: {'id': item.id},
                  extra: <String, Object>{
                    'DeliveryRouteData': item,
                    'GetDeliveryRoutesCubicInRP': context
                        .read<GetDeliveryRoutesCubit>(),
                    'GetDeliveryRoutesUsecaseParamsInRP':
                        GetDeliveryRoutesUsecaseParams(
                          keyword: context
                              .read<SearchDeliveryRoutesCubit>()
                              .state
                              .searchText,
                        ),
                  },
                );
              }
            },
            onLongPress: () {
              if (!widget.isSelectionMode) {
                widget.onToggleSelection(item.id);
              }
            },
            onCheckboxChanged: (val) {
              widget.onToggleSelection(item.id);
            },
          );
        } else if (T == SortingRouteCardItem) {
          return SortingRouteCardItem(
            item: item,
            isSelectionMode: widget.isSelectionMode,
            isSelected: isSelected,
            onTap: () {
              if (widget.isSelectionMode) {
                widget.onToggleSelection(item.id);
              } else {
                context.pushNamed(
                  AppRouteNames.deliveryRouteDetail,
                  pathParameters: {'id': item.id},
                  extra: <String, Object>{
                    'DeliveryRouteData': item,
                    'GetDeliveryRoutesCubicInRP': context
                        .read<GetDeliveryRoutesCubit>(),
                    'GetDeliveryRoutesUsecaseParamsInRP':
                        GetDeliveryRoutesUsecaseParams(
                          keyword: context
                              .read<SearchDeliveryRoutesCubit>()
                              .state
                              .searchText,
                        ),
                  },
                );
              }
            },
            onLongPress: () {
              if (!widget.isSelectionMode) {
                widget.onToggleSelection(item.id);
              }
            },
            onCheckboxChanged: (val) {
              widget.onToggleSelection(item.id);
            },
          );
        }

        return DeliveringRouteCardItem(
          item: item,
          isSelectionMode: widget.isSelectionMode,
          isSelected: isSelected,
          onTap: () {
            if (widget.isSelectionMode) {
              widget.onToggleSelection(item.id);
            } else {
              context.pushNamed(
                AppRouteNames.deliveryRouteDetail,
                pathParameters: {'id': item.id},
                extra: <String, Object>{
                  'DeliveryRouteData': item,
                  'GetDeliveryRoutesCubicInRP': context
                      .read<GetDeliveryRoutesCubit>(),
                  'GetDeliveryRoutesUsecaseParamsInRP':
                      GetDeliveryRoutesUsecaseParams(
                        keyword: context
                            .read<SearchDeliveryRoutesCubit>()
                            .state
                            .searchText,
                      ),
                },
              );
            }
          },
          onLongPress: () {
            if (!widget.isSelectionMode) {
              widget.onToggleSelection(item.id);
            }
          },
          onCheckboxChanged: (val) {
            widget.onToggleSelection(item.id);
          },
        );
      },
    );
  }
}

/// Combined Header & TabBar Component
class CustomHeaderWithTabBar extends StatelessWidget {
  final TabController tabController;
  final bool isSelectionMode;
  final int selectedCount;
  final TextEditingController searchController;
  final VoidCallback onCloseSelection;
  final VoidCallback onDeleteSelected;
  final VoidCallback onAddRoute;

  const CustomHeaderWithTabBar({
    Key? key,
    required this.tabController,
    required this.isSelectionMode,
    required this.selectedCount,
    required this.searchController,
    required this.onCloseSelection,
    required this.onDeleteSelected,
    required this.onAddRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.primary,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top),

              if (isSelectionMode)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onCloseSelection,
                    ),
                    Text(
                      AppStrings.rPHeaderSelectedRoutesCountContent.tr(
                        namedArgs: {'selectedCount': selectedCount.toString()},
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onDeleteSelected,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        AppStrings.rPHeaderDeleteSelectedRoutesButtonLabel.tr(
                          namedArgs: {
                            'selectedCount': selectedCount.toString(),
                          },
                        ),
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
                      AppStrings.rPTitle.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          BlocBuilder<
                            SearchDeliveryRoutesCubit,
                            SearchDeliveryRoutesState
                          >(
                            builder: (context, state) => TextField(
                              controller: searchController,
                              onChanged: (value) {
                                final searchDeliveryRoutesCubit = context
                                    .read<SearchDeliveryRoutesCubit>();
                                searchDeliveryRoutesCubit.searchTextChanged(
                                  value,
                                );
                                searchDeliveryRoutesCubit.submit(
                                  cb: () async {
                                    await context
                                        .read<GetDeliveryRoutesCubit>()
                                        .call(
                                          params:
                                              GetDeliveryRoutesUsecaseParams(
                                                keyword: value,
                                              ),
                                        );
                                  },
                                );
                              },
                              decoration: InputDecoration(
                                hintText: AppStrings.rPSearchHintText.tr(),
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 44,
                                  minHeight: 44,
                                ),
                                prefixIcon: state is SearchDeliveryRoutesLoading
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
                                // contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: onAddRoute,
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
                      AppStrings.rPAddRouteButtonLabel.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Thanh TabBar đặt cố định ngay bên dưới Header
        Container(
          color: Colors.white,
          child: TabBar(
            controller: tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.black54,
            indicatorColor: AppColors.primary,
            indicatorWeight: 4,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 15,
            ),
            tabs: [
              Tab(text: AppStrings.rPPendingOrdersTabLabel.tr()),
              Tab(text: AppStrings.rPSortingOrdersTabLabel.tr()),
              Tab(text: AppStrings.rPDeliveringTabLabel.tr()),
              Tab(text: AppStrings.rPCompletedTabLabel.tr()),
            ],
          ),
        ),
      ],
    );
  }
}

/// Card Item Lộ trình
class DeliveringRouteCardItem extends StatelessWidget {
  final DeliveryRouteEntity item;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<bool?> onCheckboxChanged;

  const DeliveringRouteCardItem({
    Key? key,
    required this.item,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onCheckboxChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (isSelectionMode) ...[
            SmgoCheckbox(
              value: isSelected,
              onChanged: onCheckboxChanged,
              primaryColor: AppColors.primary,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.03 * 255).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.alt_route,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppStrings.rPCreatedRouteDateString.tr(
                                  namedArgs: {
                                    'dateTimeString': DateFormat(
                                      'dd/MM/yyyy • HH:mm',
                                    ).format(item.createdAt.toLocal()),
                                  },
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.people_outline,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppStrings.rPCountContent.tr(
                                  namedArgs: {
                                    'quantity':
                                        (item.totalDeliveredOrders +
                                                item.totalCancelledOrders +
                                                item.totalRescheduledOrders)
                                            .toString(),
                                    'total': item.totalOrders.toString(),
                                  },
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusMetric(
                          icon: Icons.check_circle_outline,
                          iconColor: Colors.green,
                          count: item.totalDeliveredOrders,
                          label: AppStrings.rPSuccessStatusOrderLabel.tr(),
                        ),
                        _buildStatusMetric(
                          icon: Icons.cancel_outlined,
                          iconColor: Colors.red,
                          count: item.totalCancelledOrders,
                          label: AppStrings.rPFailedStatusOrderLabel.tr(),
                        ),
                        _buildStatusMetric(
                          icon: Icons.access_time,
                          iconColor: Colors.orange,
                          count: item.totalRescheduledOrders,
                          label: AppStrings.rPRescheduledStatusOrderLabel.tr(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMetric({
    required IconData icon,
    required Color iconColor,
    required int count,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}

class PendingRouteCardItem extends StatelessWidget {
  final DeliveryRouteEntity item;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<bool?> onCheckboxChanged;

  const PendingRouteCardItem({
    Key? key,
    required this.item,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onCheckboxChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (isSelectionMode) ...[
            SmgoCheckbox(
              value: isSelected,
              onChanged: onCheckboxChanged,
              primaryColor: AppColors.primary,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.04 * 255).round()),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon route chính bên trái
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.alt_route_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Tiêu đề & Thời gian (Render động từ item)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppStrings.rPCreatedRouteDateString.tr(
                                      namedArgs: {
                                        'dateTimeString': DateFormat(
                                          'dd/MM/yyyy • HH:mm',
                                        ).format(item.createdAt.toLocal()),
                                      },
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF1F5F9),
                    ),
                    const SizedBox(height: 16),

                    // Stats Row (Hiển thị các chỉ số động từ item)
                    Row(
                      children: [
                        // Chưa kiểm tra (Số đơn còn lại)
                        Expanded(
                          child: _buildStatusMetric(
                            icon: Icons.access_time_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            count: item.totalPendingOrders,
                            label: AppStrings.rPPendingStatusOrderLabel.tr(),
                          ),
                        ),

                        // Đã kiểm tra (Số đơn đã hoàn tất/hủy)
                        Expanded(
                          child: _buildStatusMetric(
                            icon: Icons.check_circle_outline_rounded,
                            iconColor: const Color(0xFF10B981),
                            count: item.totalCheckedOrders,
                            label: AppStrings.rPCheckedStatusOrderLabel.tr(),
                          ),
                        ),

                        // Tổng số đơn
                        Expanded(
                          child: _buildStatusMetric(
                            icon: Icons.description_outlined,
                            iconColor: const Color(0xFF3B82F6),
                            count: item.totalOrders,
                            label: AppStrings.rPTotalOrdersLabel.tr(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMetric({
    required IconData icon,
    required Color iconColor,
    required int count,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}

class SortingRouteCardItem extends StatelessWidget {
  final DeliveryRouteEntity item;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<bool?> onCheckboxChanged;

  const SortingRouteCardItem({
    Key? key,
    required this.item,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onCheckboxChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (isSelectionMode) ...[
            SmgoCheckbox(
              value: isSelected,
              onChanged: onCheckboxChanged,
              primaryColor: AppColors.primary,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.04 * 255).round()),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon route chính bên trái
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.alt_route_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Tiêu đề & Thời gian (Render động từ item)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppStrings.rPCreatedRouteDateString.tr(
                                      namedArgs: {
                                        'dateTimeString': DateFormat(
                                          'dd/MM/yyyy • HH:mm',
                                        ).format(item.createdAt.toLocal()),
                                      },
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF1F5F9),
                    ),
                    const SizedBox(height: 16),

                    // Stats Row (Hiển thị các chỉ số động từ item)
                    Row(
                      children: [
                        // Chưa sắp xếp (Số đơn còn lại)
                        Expanded(
                          child: _buildStatusMetric(
                            icon: Icons.access_time_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            count: item.totalOrders - item.totalSortedOrders,
                            label: AppStrings.rPUnsortedStatusOrderLabel.tr(),
                          ),
                        ),

                        // Đã sắp xếp (Số đơn đã hoàn tất/hủy)
                        Expanded(
                          child: _buildStatusMetric(
                            icon: Icons.check_circle_outline_rounded,
                            iconColor: const Color(0xFF10B981),
                            count: item.totalSortedOrders,
                            label: AppStrings.rPSortedStatusOrderLabel.tr(),
                          ),
                        ),

                        // Tổng số đơn
                        Expanded(
                          child: _buildStatusMetric(
                            icon: Icons.description_outlined,
                            iconColor: const Color(0xFF3B82F6),
                            count: item.totalOrders,
                            label: AppStrings.rPTotalOrdersLabel.tr(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMetric({
    required IconData icon,
    required Color iconColor,
    required int count,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
