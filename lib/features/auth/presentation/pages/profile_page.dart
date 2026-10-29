import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cashew_store/core/constants/app_colors.dart';
import 'package:cashew_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cashew_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:cashew_store/core/services/notification_service.dart';
import 'package:cashew_store/core/services/crashlytics_service.dart';

class ProfilePage extends StatelessWidget {
  final void Function(int)? onNavigateToTab;

  const ProfilePage({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Profile & Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          String name = 'Cashew Customer';
          String email = 'customer@cashew.com';

          if (state is Authenticated) {
            name = state.user.name;
            email = state.user.email;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'C',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified, size: 14, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verified Customer Account',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Account Navigation Tiles
                _buildSectionTitle('Orders & Tracking'),
                _buildActionTile(
                  icon: Icons.receipt_long_rounded,
                  title: 'My Orders & Live Status',
                  subtitle: 'Track your deliveries, shipments & past orders',
                  onTap: () {
                    if (onNavigateToTab != null) {
                      onNavigateToTab!(1);
                    } else {
                      context.push('/orders');
                    }
                  },
                ),
                const SizedBox(height: 16),

                _buildSectionTitle('Saved Addresses'),
                _buildActionTile(
                  icon: Icons.location_on_outlined,
                  title: 'Delivery Addresses',
                  subtitle: 'View, add or edit your delivery addresses',
                  onTap: () => context.push('/select-address'),
                ),
                _buildActionTile(
                  icon: Icons.add_location_alt_outlined,
                  title: 'Add New Address',
                  subtitle: 'Add a new home, office or personal address',
                  onTap: () => context.push('/add-address'),
                ),
                const SizedBox(height: 16),

                _buildSectionTitle('Notifications & Preferences'),
                _buildActionTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Test order, shipping, delivery and offer alerts',
                  onTap: () => _showNotificationTestModal(context),
                ),
                _buildActionTile(
                  icon: Icons.bug_report_outlined,
                  title: 'Firebase Crashlytics',
                  subtitle: 'Simulate crash, test non-fatal logging & breadcrumbs',
                  onTap: () => _showCrashlyticsTestModal(context),
                ),
                const SizedBox(height: 16),

                _buildSectionTitle('About & Support'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('App Version', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          Text('v1.0.0 (Cashew App)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Payment Methods', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          Text('Cash on Delivery (COD) & Online', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthCubit>().logout();
                    },
                    icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      ),
    );
  }

  void _showNotificationTestModal(BuildContext context) {
    final notif = NotificationService();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Test Push Notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select any of the 6 notification events to preview banner alert:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Divider(height: 20),
              ListTile(
                leading: const Icon(Icons.celebration_rounded, color: Colors.blue),
                title: const Text('Order Confirmed'),
                subtitle: const Text('Your order #CS1001 has been confirmed.'),
                onTap: () {
                  Navigator.pop(ctx);
                  notif.showOrderConfirmedNotification(orderNumber: 'CS1001');
                },
              ),
              ListTile(
                leading: const Icon(Icons.payment_rounded, color: Colors.teal),
                title: const Text('Payment Successful'),
                subtitle: const Text('Payment received successfully.'),
                onTap: () {
                  Navigator.pop(ctx);
                  notif.showPaymentSuccessfulNotification(orderNumber: 'CS1001');
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_shipping_rounded, color: Colors.orange),
                title: const Text('Order Dispatched'),
                subtitle: const Text('Your cashew order is on its way.'),
                onTap: () {
                  Navigator.pop(ctx);
                  notif.showOrderDispatchedNotification(orderNumber: 'CS1001');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delivery_dining_rounded, color: Colors.purple),
                title: const Text('Out for Delivery'),
                subtitle: const Text('Your order will arrive soon.'),
                onTap: () {
                  Navigator.pop(ctx);
                  notif.showOutForDeliveryNotification(orderNumber: 'CS1001');
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_rounded, color: Colors.green),
                title: const Text('Order Delivered'),
                subtitle: const Text('Your order has been delivered.'),
                onTap: () {
                  Navigator.pop(ctx);
                  notif.showOrderDeliveredNotification(orderNumber: 'CS1001');
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_offer_rounded, color: Colors.redAccent),
                title: const Text('Promotional Offer'),
                subtitle: const Text('Get 10% off your next order.'),
                onTap: () {
                  Navigator.pop(ctx);
                  notif.showPromotionalOfferNotification();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCrashlyticsTestModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bug_report_rounded, color: AppColors.error, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Firebase Crashlytics Test',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Simulate crashes and verify real-time reporting',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                title: const Text('Log Non-Fatal Exception'),
                subtitle: const Text('Records an error to Crashlytics without crashing the app'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await CrashlyticsService.testNonFatalError();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Non-fatal test error recorded to Firebase Crashlytics!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.blue),
                title: const Text('Send Custom Breadcrumb & Key'),
                subtitle: const Text('Attaches diagnostic breadcrumb and custom metadata'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await CrashlyticsService.log('Manual diagnostic check from Profile screen');
                  await CrashlyticsService.setCustomKey('last_profile_check', DateTime.now().toIso8601String());
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Diagnostic breadcrumb and custom key sent!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.dangerous_rounded, color: AppColors.error),
                title: const Text('Simulate Fatal Crash', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                subtitle: const Text('Forces an immediate crash via FirebaseCrashlytics.instance.crash()'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('💥 Crashing app in 1 second to test Crashlytics...'),
                      backgroundColor: AppColors.error,
                      duration: Duration(seconds: 1),
                    ),
                  );
                  Future.delayed(const Duration(seconds: 1), () {
                    CrashlyticsService.testCrash();
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
