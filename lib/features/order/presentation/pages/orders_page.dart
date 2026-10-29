import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashew_store/core/constants/app_colors.dart';
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';
import '../../data/models/order_model.dart';

class OrdersPage extends StatefulWidget {
  final bool showBackButton;
  const OrdersPage({super.key, this.showBackButton = false});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderCubit>().fetchMyOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'My Orders & Tracking',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Refresh Status',
            onPressed: () {
              context.read<OrderCubit>().fetchMyOrders();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Checking latest order & delivery updates...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              tabs: const [
                Tab(text: 'All Orders'),
                Tab(text: 'Active / Live'),
                Tab(text: 'Delivered'),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state.isLoading && state.orders.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.isFailure && state.orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 54, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage ?? 'Unable to load orders',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<OrderCubit>().fetchMyOrders(),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }

          final allOrders = state.orders;
          final activeOrders = allOrders.where((o) => _isActiveStatus(o.status)).toList();
          final deliveredOrders = allOrders.where((o) => o.status.toUpperCase() == 'DELIVERED').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersList(allOrders, 'No orders found yet.\nBrowse our fresh cashews and place your first order!'),
              _buildOrdersList(activeOrders, 'No active orders at the moment.\nYour ongoing deliveries will appear here.'),
              _buildOrdersList(deliveredOrders, 'No delivered orders yet.\nCompleted deliveries will be archived here.'),
            ],
          );
        },
      ),
    );
  }

  bool _isActiveStatus(String status) {
    final s = status.toUpperCase();
    return s != 'DELIVERED' && s != 'CANCELLED' && s != 'RETURNED';
  }

  Widget _buildOrdersList(List<OrderModel> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long_outlined, size: 44, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Orders Found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<OrderCubit>().fetchMyOrders(),
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final statusColor = _getStatusColor(order.status);
    final formattedDate = _formatDate(order.placedAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Order #${order.orderNumber}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(order.status), size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _formatStatusLabel(order.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Live Progress Tracker Stepper
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: _buildOrderTimeline(order.status),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Order Items Preview
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.items.isNotEmpty) ...[
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.productName}${item.variantName != null ? ' (${item.variantName})' : ''} × ${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '₹${item.totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      )),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Items: ${order.itemCount}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      Text(
                        '₹${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 10),

                // Delivery address
                if (order.deliveryAddress.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border.withOpacity(0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryDark),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Deliver to: ${order.recipientName} • ${order.deliveryAddress}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Footer Row: Payment & Details Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            order.paymentMethod.toUpperCase() == 'COD' ? '💵 Cash on Delivery' : '💳 Online Payment',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB78103)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${order.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => _showOrderTrackingBottomSheet(order),
                      icon: const Icon(Icons.timeline_rounded, size: 16, color: AppColors.primary),
                      label: const Text(
                        'Track History',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline(String status) {
    final stages = [
      {'key': 'PLACED', 'label': 'Placed'},
      {'key': 'CONFIRMED', 'label': 'Confirmed'},
      {'key': 'PACKED', 'label': 'Packed'},
      {'key': 'SHIPPED', 'label': 'On Way'},
      {'key': 'DELIVERED', 'label': 'Delivered'},
    ];

    int currentStageIndex = _getStageIndex(status);

    return Column(
      children: [
        Row(
          children: List.generate(stages.length * 2 - 1, (index) {
            if (index.isEven) {
              final stageIdx = index ~/ 2;
              final isPassed = stageIdx <= currentStageIndex;
              final isCurrent = stageIdx == currentStageIndex;

              return Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPassed ? AppColors.primary : const Color(0xFFE0E0E0),
                  border: isCurrent
                      ? Border.all(color: AppColors.primaryDark, width: 2.5)
                      : null,
                ),
                child: Center(
                  child: isPassed
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                ),
              );
            } else {
              final lineIdx = index ~/ 2;
              final isLinePassed = lineIdx < currentStageIndex;

              return Expanded(
                child: Container(
                  height: 3,
                  color: isLinePassed ? AppColors.primary : const Color(0xFFE0E0E0),
                ),
              );
            }
          }),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: stages.map((s) {
            final idx = stages.indexOf(s);
            final isHighlight = idx == currentStageIndex;
            return Expanded(
              child: Text(
                s['label']!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                  color: isHighlight ? AppColors.primaryDark : AppColors.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  int _getStageIndex(String status) {
    switch (status.toUpperCase()) {
      case 'PLACED':
      case 'PENDING_PAYMENT':
        return 0;
      case 'CONFIRMED':
      case 'PROCESSING':
        return 1;
      case 'PACKED':
        return 2;
      case 'SHIPPED':
      case 'OUT_FOR_DELIVERY':
        return 3;
      case 'DELIVERED':
        return 4;
      default:
        return 0;
    }
  }

  void _showOrderTrackingBottomSheet(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Order Tracking',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Order #${order.orderNumber}',
                        style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Status history items
              if (order.statusHistory.isNotEmpty) ...[
                const Text(
                  'Activity Timeline:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                ...order.statusHistory.map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.radio_button_checked, size: 16, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatStatusLabel(h.newStatus),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                if (h.note != null && h.note!.isNotEmpty)
                                  Text(
                                    h.note!,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                if (h.createdAt != null)
                                  Text(
                                    _formatDate(h.createdAt!),
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Current Status: ${_formatStatusLabel(order.status)}. Your order will update as it progresses through shipping.',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close Tracking', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PLACED':
        return Colors.blue;
      case 'CONFIRMED':
        return Colors.indigo;
      case 'PROCESSING':
      case 'PACKED':
        return Colors.orange;
      case 'SHIPPED':
      case 'OUT_FOR_DELIVERY':
        return const Color(0xFF8E24AA);
      case 'DELIVERED':
        return const Color(0xFF2E7D32);
      case 'CANCELLED':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PLACED':
        return Icons.access_time_filled_rounded;
      case 'CONFIRMED':
        return Icons.verified_rounded;
      case 'PROCESSING':
      case 'PACKED':
        return Icons.inventory_2_rounded;
      case 'SHIPPED':
        return Icons.local_shipping_rounded;
      case 'OUT_FOR_DELIVERY':
        return Icons.delivery_dining_rounded;
      case 'DELIVERED':
        return Icons.check_circle_rounded;
      case 'CANCELLED':
        return Icons.cancel_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }

  String _formatStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PLACED':
        return 'Order Placed';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'PROCESSING':
        return 'Processing';
      case 'PACKED':
        return 'Packed';
      case 'SHIPPED':
        return 'Dispatched';
      case 'OUT_FOR_DELIVERY':
        return 'Out for Delivery';
      case 'DELIVERED':
        return 'Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final day = date.day.toString().padLeft(2, '0');
      final month = months[date.month - 1];
      final year = date.year;
      final hour12 = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final amPm = date.hour >= 12 ? 'PM' : 'AM';
      return '$day $month $year, $hour12:$minute $amPm';
    } catch (_) {
      return isoString;
    }
  }
}
