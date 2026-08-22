import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/dependency_injection.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_order_entity.dart';
import 'package:shipgo/features/delivery_route/domain/entities/delivery_route_entity.dart';
import 'package:shipgo/features/delivery_route/domain/usecases/get_delivery_routes_usecase.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_cubit.dart';
import 'package:shipgo/features/delivery_route/presentation/bloc/get_delivery_routes/get_delivery_routes_state.dart';

class RouteColors {
  static const green = Color(0xFF008C45);
  static const greenDark = Color(0xFF007A3D);
  static const greenLight = Color(0xFFEAF7F0);

  static const blue = Color(0xFF1976D2);
  static const blueLight = Color(0xFFEAF3FF);

  static const orange = Color(0xFFFFA000);
  static const orangeLight = Color(0xFFFFF6E5);

  static const red = Color(0xFFE53935);

  static const text = Color(0xFF18224A);
  static const secondaryText = Color(0xFF6F758A);
  static const border = Color(0xFFE9EBF0);
}

class DeliveryOrderPage extends StatefulWidget {
  const DeliveryOrderPage({super.key});

  @override
  State<DeliveryOrderPage> createState() => _DeliveryOrderPageState();
}

class _DeliveryOrderPageState extends State<DeliveryOrderPage> {
  DeliveryRouteEntity? deliveryRoute;

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, Object>;
    deliveryRoute =
        deliveryRoute ?? extra['DeliveryRouteData'] as DeliveryRouteEntity;
    final getDeliveryRoutesCubitInDRDP =
        extra['GetDeliveryRoutesCubitInDRDP'] as GetDeliveryRoutesCubit;
    final getDeliveryRoutesUsecaseParamsInDRDP =
        extra['GetDeliveryRoutesUsecaseParamsInDRDP']
            as GetDeliveryRoutesUsecaseParams;

    return MultiBlocProvider(
      providers: [
        BlocProvider<GetDeliveryRoutesCubit>(
          create: (context) => di<GetDeliveryRoutesCubit>()
            ..call(
              params: GetDeliveryRoutesUsecaseParams(
                pageNumber: 1,
                pageSize: 1,
                id: deliveryRoute!.id,
                status: deliveryRoute!.status,
              ),
            ),
        ),
      ],
      child: BlocConsumer<GetDeliveryRoutesCubit, GetDeliveryRoutesState>(
        listener: (context, state) {
          if (state is GetDeliveryRoutesDone) {
            deliveryRoute = state.routes.firstOrNull ?? deliveryRoute;
            getDeliveryRoutesCubitInDRDP.call(
              params: getDeliveryRoutesUsecaseParamsInDRDP,
            );
          }
        },
        builder: (context, state) => Scaffold(
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: () async {
              await context.read<GetDeliveryRoutesCubit>().call(
                params: GetDeliveryRoutesUsecaseParams(
                  pageNumber: 1,
                  pageSize: 1,
                  id: deliveryRoute!.id,
                  status: deliveryRoute!.status,
                ),
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: IntrinsicHeight(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 100),
                          child: RouteHeader(),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: RouteSummary(deliveryRoute: deliveryRoute!),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverFillRemaining(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: RouteProgress(deliveryRoute: deliveryRoute!),
                      ),
                      SliverFillRemaining(
                        hasScrollBody:
                            true, // Cho phép TabBarView cuộn bên trong
                        child: _buildStatusContent(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: RouteActionBar(route: deliveryRoute!),
        ),
      ),
    );
  }

  Widget _buildStatusContent() {
    switch (deliveryRoute!.status) {
      case DeliveryRouteStatus.pending:
        return PendingView(deliveryRoute: deliveryRoute!);

      case DeliveryRouteStatus.sorting:
        return SortingView(deliveryRoute: deliveryRoute!);

      case DeliveryRouteStatus.delivering:
        return DeliveringView(deliveryRoute: deliveryRoute!);

      case DeliveryRouteStatus.completed:
        return CompletedView(deliveryRoute: deliveryRoute!);

      default:
        return PendingView(deliveryRoute: deliveryRoute!);
    }
  }
}

// Header
class RouteHeader extends StatelessWidget {
  const RouteHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 55, 12, 25),
      decoration: const BoxDecoration(
        color: RouteColors.green,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _CircleButton(
                icon: Icons.arrow_back_ios_new,
                onPressed: () {
                  context.pop();
                },
              ),

              const Expanded(
                child: Column(
                  children: [
                    Text(
                      'Lộ trình Quận 1 – Sáng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tạo lúc 20/05/2024 • 08:30',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 22),
            ],
          ),

          const SizedBox(height: 20),

          const _SearchBox(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// Thanh search
class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: RouteColors.text, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Tìm kiếm đơn hàng...',
        hintStyle: const TextStyle(color: Color(0xFF9AA0B3), fontSize: 16),
        prefixIcon: const Icon(Icons.search, size: 28, color: RouteColors.text),
        suffixIcon: IconButton(
          onPressed: () {
            // TODO: scan QR
          },
          icon: const Icon(Icons.qr_code_scanner, color: RouteColors.green),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// Summary
class RouteSummary extends StatelessWidget {
  final DeliveryRouteEntity deliveryRoute;

  const RouteSummary({super.key, required this.deliveryRoute});

  @override
  Widget build(BuildContext context) {
    final familarCount = deliveryRoute.orders
        .where((order) => order.appliedLocation != null)
        .length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _SummaryItem(
              title: 'Tổng số đơn',
              value: '${deliveryRoute.totalOrders}',
              subtitle: 'đơn',
            ),
          ),

          _divider(),

          Expanded(child: _buildProgressSummary()),

          _divider(),

          Expanded(
            child: _SummaryItem(
              title: 'Khách quen',
              value: '$familarCount',
              subtitle:
                  'đơn (${deliveryRoute.totalOrders > 0 ? ((familarCount / deliveryRoute.totalOrders) * 100).round() : 0}%)',
              badge: true,
            ),
          ),

          _divider(),

          Expanded(child: _buildStatusSummary()),
        ],
      ),
    );
  }

  Widget _buildProgressSummary() {
    switch (deliveryRoute.status) {
      case DeliveryRouteStatus.pending:
        return _ProgressSummaryItem(
          title: 'Tiến độ',
          progress: deliveryRoute.checkProgress,
          value: '${(deliveryRoute.checkProgress * 100).round()}%',
          subtitle:
              '${deliveryRoute.totalCheckedOrders}/${deliveryRoute.totalOrders}',
        );

      case DeliveryRouteStatus.sorting:
        return _ProgressSummaryItem(
          title: 'Tiến độ',
          progress: deliveryRoute.sortingProgress,
          value: '${(deliveryRoute.sortingProgress * 100).round()}%',
          subtitle: deliveryRoute.isAllSorted ? 'Đã sắp xếp' : 'Chưa sắp xếp',
        );

      case DeliveryRouteStatus.delivering:
        return _ProgressSummaryItem(
          title: 'Tiến độ',
          progress: deliveryRoute.deliveryProgress,
          value: '${(deliveryRoute.deliveryProgress * 100).round()}%',
          subtitle:
              '${deliveryRoute.totalDeliveredOrders + deliveryRoute.totalCancelledOrders + deliveryRoute.totalRescheduledOrders}/${deliveryRoute.totalOrders} đơn',
        );

      case DeliveryRouteStatus.completed:
        // return _SummaryItem(
        //   title: 'Đã giao',
        //   value: '${deliveryRoute.tota}',
        //   subtitle: 'đơn',
        // );
        return _ProgressSummaryItem(
          title: 'Tiến độ',
          progress: 1,
          value: '100%',
          subtitle: '${deliveryRoute.totalOrders} đơn',
        );

      default:
        return _ProgressSummaryItem(
          title: 'Tiến độ',
          progress: deliveryRoute.checkProgress,
          value: '${(deliveryRoute.checkProgress * 100).round()}%',
          subtitle:
              '${deliveryRoute.totalCheckedOrders}/${deliveryRoute.totalOrders}',
        );
    }
  }

  Widget _buildStatusSummary() {
    switch (deliveryRoute.status) {
      case DeliveryRouteStatus.pending:
        return const _StatusSummaryItem(
          icon: Icons.check_circle_outline,
          color: RouteColors.green,
          text: 'Kiểm tra hàng',
        );

      case DeliveryRouteStatus.sorting:
        return const _StatusSummaryItem(
          icon: Icons.access_time,
          color: RouteColors.blue,
          text: 'Sắp xếp',
        );

      case DeliveryRouteStatus.delivering:
        return const _StatusSummaryItem(
          icon: Icons.access_time,
          color: RouteColors.blue,
          text: 'Đang giao hàng',
        );

      case DeliveryRouteStatus.completed:
        return const _StatusSummaryItem(
          icon: Icons.check_circle_outline,
          color: RouteColors.green,
          text: 'Hoàn thành',
        );

      default:
        return const _StatusSummaryItem(
          icon: Icons.check_circle_outline,
          color: RouteColors.green,
          text: 'Kiểm tra hàng',
        );
    }
  }

  Widget _divider() {
    return Container(width: 1, height: 95, color: RouteColors.border);
  }
}

// Summary item
class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final bool badge;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.subtitle,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: RouteColors.text,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: RouteColors.green,
          ),
        ),

        const SizedBox(height: 4),

        if (badge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: RouteColors.greenLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              subtitle,
              style: const TextStyle(
                color: RouteColors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Text(
            subtitle,
            style: const TextStyle(color: RouteColors.text, fontSize: 12),
          ),
      ],
    );
  }
}

// Progress summary
class _ProgressSummaryItem extends StatelessWidget {
  final String title;
  final double progress;
  final String value;
  final String subtitle;

  const _ProgressSummaryItem({
    required this.title,
    required this.progress,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: RouteColors.text,
          ),
        ),
        SizedBox(height: 14),
        SizedBox(
          width: 32,
          height: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 4,
                backgroundColor: RouteColors.greenLight,
                valueColor: const AlwaysStoppedAnimation(RouteColors.green),
              ),

              Text(value, style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),

        const SizedBox(height: 6),

        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: RouteColors.text),
        ),
      ],
    );
  }
}

// Status summary
class _StatusSummaryItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _StatusSummaryItem({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Trạng thái',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: RouteColors.text,
          ),
        ),

        const SizedBox(height: 12),

        Icon(icon, size: 32, color: color),

        const SizedBox(height: 8),

        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: RouteColors.text),
        ),
      ],
    );
  }
}

// Route progress
class RouteProgress extends StatelessWidget {
  final DeliveryRouteEntity deliveryRoute;

  const RouteProgress({super.key, required this.deliveryRoute});

  @override
  Widget build(BuildContext context) {
    final currentStep = _currentStep;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepItem(
              step: 1,
              title: 'Kiểm tra đơn hàng',
              subtitle:
                  '${deliveryRoute.totalCheckedOrders}/${deliveryRoute.totalOrders} đơn',
              completed: currentStep > 1,
              active: currentStep == 1,
            ),

            _StepConnector(completed: currentStep > 2),

            _StepItem(
              step: 2,
              title: 'Sắp xếp hàng hoá',
              subtitle: _sortingSubtitle,
              completed: currentStep > 2,
              active: currentStep == 2,
            ),

            _StepConnector(completed: currentStep > 3),

            _StepItem(
              step: 3,
              title: 'Giao hàng',
              subtitle: _deliverySubtitle,
              completed: currentStep > 3,
              active: currentStep == 3,
            ),

            _StepConnector(completed: currentStep >= 4),

            _StepItem(
              step: 4,
              title: 'Hoàn thành',
              subtitle: deliveryRoute.isCompleted ? 'Hoàn tất' : null,
              completed: currentStep >= 4,
              active: currentStep == 4,
            ),
          ],
        ),
      ),
    );
  }

  int get _currentStep {
    switch (deliveryRoute.status) {
      case DeliveryRouteStatus.pending:
        return 1;

      case DeliveryRouteStatus.sorting:
        return 2;

      case DeliveryRouteStatus.delivering:
        return 3;

      case DeliveryRouteStatus.completed:
        return 4;

      default:
        return 1;
    }
  }

  String get _sortingSubtitle {
    if (deliveryRoute.isAllSorted) {
      return 'Đã sắp xếp';
    }

    if (deliveryRoute.totalSortedOrders == 0) {
      return 'Chưa sắp xếp';
    }

    return '${deliveryRoute.totalSortedOrders}/${deliveryRoute.totalOrders} đơn';
  }

  String? get _deliverySubtitle {
    switch (deliveryRoute.status) {
      case DeliveryRouteStatus.delivering:
        return 'Đang giao';

      case DeliveryRouteStatus.completed:
        return '${deliveryRoute.totalOrders} đơn';

      default:
        return null;
    }
  }
}

// Step item
class _StepItem extends StatelessWidget {
  final int step;
  final String title;
  final String? subtitle;
  final bool completed;
  final bool active;

  const _StepItem({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.completed,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color = completed || active
        ? RouteColors.green
        : const Color(0xFF9FA3B5);

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed
                  ? RouteColors.green
                  : active
                  ? RouteColors.greenLight
                  : Colors.transparent,
            ),
            child: completed
                ? const Icon(Icons.check, color: Colors.white)
                : Icon(_icon, color: color),
          ),

          const SizedBox(height: 8),

          Text(
            '$step. $title',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active || completed
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: color,
            ),
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData get _icon {
    switch (step) {
      case 1:
        return Icons.fact_check_outlined;
      case 2:
        return Icons.view_in_ar_outlined;
      case 3:
        return Icons.delivery_dining_outlined;
      case 4:
        return Icons.flag_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
}

// Step connector
class _StepConnector extends StatelessWidget {
  final bool completed;

  const _StepConnector({required this.completed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          4,
          (_) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              height: 3,
              color: completed ? RouteColors.green : const Color(0xFFB8BBC8),
            ),
          ),
        ),
      ),
    );
  }
}

// Pending
class PendingView extends StatelessWidget {
  final DeliveryRouteEntity deliveryRoute;

  const PendingView({super.key, required this.deliveryRoute});

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách theo trạng thái
    final pendingOrders = deliveryRoute.orders
        .where((o) => o.status == DeliveryOrderStatus.pending.value)
        .toList();
    final checkedOrders = deliveryRoute.orders
        .where((o) => o.status == DeliveryOrderStatus.checked.value)
        .toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // 1. THANH TAB DỰA THEO THIẾT KẾ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              indicatorColor: Colors.green,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.green,
              unselectedLabelColor: const Color(0xFF1E2440),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
              tabs: [
                Tab(
                  child: _TabBadge(
                    title: 'Chờ kiểm tra',
                    count: pendingOrders.length,
                  ),
                ),
                Tab(
                  child: _TabBadge(
                    title: 'Đã kiểm tra',
                    count: checkedOrders.length,
                  ),
                ),
              ],
            ),
          ),

          // 2. NỘI DUNG DANH SÁCH VUỐT ĐƯỢC
          Expanded(
            child: TabBarView(
              children: [
                _OrderList(orders: pendingOrders),
                _OrderList(orders: checkedOrders),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget hiển thị Tiêu đề + Badge đếm số lượng
class _TabBadge extends StatelessWidget {
  final String title;
  final int count;

  const _TabBadge({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// Widget hiển thị danh sách đơn hàng
class _OrderList extends StatelessWidget {
  final List<DeliveryOrderEntity> orders;

  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text('Không có đơn hàng nào'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return OrderCard(order: orders[index]);
      },
    );
  }
}

// Sort order
class SortingView extends StatelessWidget {
  final DeliveryRouteEntity deliveryRoute;

  const SortingView({super.key, required this.deliveryRoute});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SortingGuide(),

        ...deliveryRoute.orders.map((order) => SortingOrderCard(order: order)),
      ],
    );
  }
}

class _SortingGuide extends StatelessWidget {
  const _SortingGuide();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RouteColors.orangeLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD166)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: RouteColors.orange, size: 28),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hướng dẫn sắp xếp hàng hoá',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: RouteColors.text,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Số thứ tự càng lớn là đơn hàng giao sau cùng.\n'
                  'Vui lòng xếp hàng hoá từ dưới lên trên trong thùng để đảm bảo giao đúng thứ tự.',
                  style: TextStyle(
                    height: 1.5,
                    fontSize: 13,
                    color: RouteColors.text,
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.close, color: RouteColors.orange),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final DeliveryOrderEntity order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RouteColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // CỘT BÊN TRÁI: Tự co dãn theo khoảng trống còn lại
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      order.orderCode,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: RouteColors.text,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _CustomerBadge(familiar: order.appliedLocation != null),
                  ],
                ),
                const SizedBox(height: 10),
                _InfoRow(icon: Icons.person_outline, text: order.contactName),
                _InfoRow(icon: Icons.phone_outlined, text: order.contactPhone),
                _InfoRow(
                  icon: Icons.shopping_bag_outlined,
                  text: order.orderName,
                ),
                _InfoRow(icon: Icons.location_on_outlined, text: order.address),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.chevron_right, color: RouteColors.text),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: RouteColors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: RouteColors.text, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class SortingOrderCard extends StatelessWidget {
  final DeliveryOrderEntity order;

  const SortingOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RouteColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RouteColors.greenLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${order.sequenceOrder ?? '-'}',
              style: const TextStyle(
                color: RouteColors.green,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(child: OrderCardContent(order: order)),

          const Icon(Icons.chevron_right, color: RouteColors.text),
        ],
      ),
    );
  }
}

class OrderCardContent extends StatelessWidget {
  final DeliveryOrderEntity order;

  const OrderCardContent({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              order.orderCode,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: RouteColors.text,
              ),
            ),

            const SizedBox(width: 8),

            _CustomerBadge(familiar: order.appliedLocation != null),
          ],
        ),

        const SizedBox(height: 6),

        _InfoRow(icon: Icons.person_outline, text: order.contactName),

        _InfoRow(icon: Icons.shopping_bag_outlined, text: order.orderName),

        _InfoRow(icon: Icons.location_on_outlined, text: order.address),
      ],
    );
  }
}

// Delevering
class DeliveringView extends StatelessWidget {
  final DeliveryRouteEntity deliveryRoute;

  const DeliveringView({super.key, required this.deliveryRoute});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _DeliveryTabs(),

        const _DeliveryInfoBanner(),

        ...deliveryRoute.orders.asMap().entries.map((entry) {
          final index = entry.key;
          final order = entry.value;

          return DeliveryTimelineOrderCard(
            index: index + 1,
            order: order,
            isCurrent: order.status == DeliveryOrderStatus.delivering,
          );
        }),
      ],
    );
  }
}

class _DeliveryTabs extends StatelessWidget {
  const _DeliveryTabs();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _TabItem(title: 'Danh sách giao hàng', active: true)),
          Expanded(child: _TabItem(title: 'Thông tin lộ trình')),
          Expanded(child: _TabItem(title: 'Thống kê')),
          Expanded(child: _TabItem(title: 'Ghi chú')),
        ],
      ),
    );
  }
}

class _DeliveryInfoBanner extends StatelessWidget {
  const _DeliveryInfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RouteColors.blueLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: RouteColors.blue),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Bạn đang trên đường giao hàng. '
              'Hãy giao theo đúng thứ tự để tối ưu thời gian.',
              style: TextStyle(
                color: RouteColors.text,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveryTimelineOrderCard extends StatelessWidget {
  final int index;
  final DeliveryOrderEntity order;
  final bool isCurrent;

  const DeliveryTimelineOrderCard({
    super.key,
    required this.index,
    required this.order,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final isDelivered = order.status == DeliveryOrderStatus.delivered;

    final cardColor = isCurrent
        ? RouteColors.orangeLight
        : isDelivered
        ? RouteColors.greenLight
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 45,
            child: Column(
              children: [
                _TimelineCircle(
                  index: index,
                  delivered: isDelivered,
                  current: isCurrent,
                ),

                if (!isCurrent)
                  Container(
                    width: 2,
                    height: 75,
                    color: const Color(0xFFE4E7ED),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrent
                      ? const Color(0xFFFFD166)
                      : RouteColors.border,
                ),
              ),
              child: OrderCardContent(order: order),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCircle extends StatelessWidget {
  final int index;
  final bool delivered;
  final bool current;

  const _TimelineCircle({
    required this.index,
    required this.delivered,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    if (delivered) {
      return Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: RouteColors.green,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 20),
      );
    }

    if (current) {
      return Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: RouteColors.orange,
        ),
        child: const Icon(Icons.navigation, color: Colors.white, size: 20),
      );
    }

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF1F2F5),
      ),
      child: Text(
        '$index',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: RouteColors.text,
        ),
      ),
    );
  }
}

// Completed
class CompletedView extends StatelessWidget {
  final DeliveryRouteEntity deliveryRoute;

  const CompletedView({super.key, required this.deliveryRoute});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _CompletedTabs(),

        const _CompletedBanner(),

        RouteStatistics(route: deliveryRoute),

        // _OrderListPreview(orders: route.orders),
      ],
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      padding: const EdgeInsets.symmetric(vertical: 24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: RouteColors.greenLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle, color: RouteColors.green, size: 72),

          SizedBox(height: 12),

          Text(
            'LỘ TRÌNH ĐÃ HOÀN THÀNH',
            style: TextStyle(
              color: RouteColors.green,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 6),

          Text(
            '15/15 đơn giao thành công',
            style: TextStyle(
              color: RouteColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Hoàn thành lúc 11:42, 20/05/2024',
            style: TextStyle(color: RouteColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class RouteStatistics extends StatelessWidget {
  final DeliveryRouteEntity route;

  const RouteStatistics({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RouteColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TỔNG KẾT LỘ TRÌNH',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: RouteColors.text,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _StatisticItem(
                  icon: Icons.access_time,
                  title: 'Thời gian',
                  value: '3h 12p',
                  subtitle: '08:30 – 11:42',
                ),
              ),

              Expanded(
                child: _StatisticItem(
                  icon: Icons.route,
                  title: 'Quãng đường',
                  value: '12.8 km',
                  subtitle: '',
                ),
              ),

              Expanded(
                child: _StatisticItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Tổng số đơn',
                  value: '${route.totalOrders}',
                  subtitle: 'đơn',
                ),
              ),
            ],
          ),

          const Divider(height: 30),

          Row(
            children: [
              Expanded(
                child: _StatisticItem(
                  icon: Icons.check_circle_outline,
                  title: 'Thành công',
                  value: '${route.totalDeliveredOrders}',
                  subtitle: '(100%)',
                ),
              ),

              Expanded(
                child: _StatisticItem(
                  icon: Icons.access_time,
                  title: 'Giao sau',
                  value: '0',
                  subtitle: '(0%)',
                ),
              ),

              Expanded(
                child: _StatisticItem(
                  icon: Icons.cancel_outlined,
                  title: 'Thất bại',
                  value: '0',
                  subtitle: '(0%)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RouteActionBar extends StatelessWidget {
  final DeliveryRouteEntity route;

  const RouteActionBar({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          physics: AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: _buildAction(context),
        ),
      ),
    );
  }

  Widget _buildAction(BuildContext context) {
    if (route.status == DeliveryRouteStatus.pending.value) {
      return Row(
        children: [
          const SizedBox(width: 12),

          _OutlineButton(
            icon: Icons.add,
            label: 'Thêm đơn',
            onPressed: () {
              context.pushNamed(
                AppRouteNames.addDeliveryOrder,
                pathParameters: {'id': route.id},
                extra: <String, Object>{
                  'DeliveryRouteData': route,
                  'GetDeliveryRoutesCubitInDOP': context
                      .read<GetDeliveryRoutesCubit>(),
                  'GetDeliveryRoutesUsecaseParamsInDOP':
                      GetDeliveryRoutesUsecaseParams(
                        id: route.id,
                        pageNumber: 1,
                        pageSize: 1,
                        status: route.status,
                      ),
                },
              );
            },
          ),

          const SizedBox(width: 12),

          _OutlineButton(
            icon: Icons.touch_app_outlined,
            label: 'Xác nhận đơn hàng',
            onPressed: () {},
          ),
          const SizedBox(width: 12),

          _DisabledButton(
            icon: Icons.local_shipping_outlined,
            label: 'Sắp xếp hàng hoá',
            subtitle: 'Cần kiểm tra 100% đơn hàng',
          ),

          const SizedBox(width: 12),
        ],
      );
    } else if (route.status == DeliveryRouteStatus.sorting.value) {
      return Row(
        children: [
          _OutlineButton(icon: Icons.add, label: 'Thêm đơn', onPressed: () {}),

          const SizedBox(width: 12),

          _PrimaryButton(
            icon: Icons.local_shipping_outlined,
            label: 'Sắp xếp hàng hoá',
            onPressed: () {},
          ),

          const SizedBox(width: 12),

          _DisabledButton(
            icon: Icons.play_arrow,
            label: 'Bắt đầu giao hàng',
            subtitle: 'Chỉ khả dụng khi sắp xếp 100%',
          ),
        ],
      );
    } else if (route.status == DeliveryRouteStatus.delivering.value) {
      return Row(
        children: [
          _OutlineButton(
            icon: Icons.phone_outlined,
            label: 'Liên hệ',
            onPressed: () {},
          ),

          const SizedBox(width: 12),

          _PrimaryButton(
            icon: Icons.navigation,
            label: 'Điều hướng đến điểm giao tiếp theo',
            subtitle: '67 Lê Lợi, P. Bến Nghé, Q.1, TP.HCM',
            onPressed: () {},
          ),
        ],
      );
    } else if (route.status == DeliveryRouteStatus.completed.value) {
      return Row(
        children: [
          _OutlineButton(
            icon: Icons.assignment_outlined,
            label: 'Xem lại đơn hàng',
            onPressed: () {},
          ),

          const SizedBox(width: 12),

          _PrimaryButton(
            icon: Icons.check_circle_outline,
            label: 'Về danh sách lộ trình',
            onPressed: () {},
          ),
        ],
      );
    } else {
      throw Exception('Delivery status does not match any valid case');
    }
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RouteColors.green,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),

              const SizedBox(width: 8),

              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _OutlineButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: RouteColors.green,
        side: const BorderSide(color: RouteColors.green),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon),
      label: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}

class _DisabledButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _DisabledButton({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFA7ABB9)),

          const SizedBox(width: 8),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF9297A8),
                  fontWeight: FontWeight.w600,
                ),
              ),

              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFA7ABB9), fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerBadge extends StatelessWidget {
  final bool familiar;

  const _CustomerBadge({required this.familiar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: familiar ? RouteColors.greenLight : RouteColors.blueLight,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        familiar ? 'Khách quen' : 'Khách lạ',
        style: TextStyle(
          color: familiar ? RouteColors.green : RouteColors.blue,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 20),
      onPressed: onPressed,
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool active;

  const _TabItem({required this.title, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: active ? RouteColors.green : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: active ? RouteColors.green : RouteColors.text,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _CompletedTabs extends StatelessWidget {
  const _CompletedTabs();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _TabItem(title: 'Tổng quan', active: true)),
          Expanded(child: _TabItem(title: 'Đơn hàng')),
          Expanded(child: _TabItem(title: 'Thống kê')),
          Expanded(child: _TabItem(title: 'Ghi chú')),
        ],
      ),
    );
  }
}

class _StatisticItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _StatisticItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: RouteColors.greenLight,
          ),
          child: Icon(icon, color: RouteColors.green, size: 22),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: RouteColors.secondaryText,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: RouteColors.text,
                ),
              ),

              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: RouteColors.secondaryText,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
