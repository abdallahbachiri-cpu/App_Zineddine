import 'dart:ui';
import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/notification_provider.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/screens/buyer_order_details_screen.dart';
import 'package:cuisinous/screens/seller_order_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class NotificationSallerView extends StatefulWidget {
  const NotificationSallerView({super.key});

  @override
  State<NotificationSallerView> createState() => _NotificationSallerViewState();
}

class _NotificationSallerViewState extends State<NotificationSallerView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      body: Stack(
        children: [
          // Futuristic background with floating blurred shapes
          _buildAntigravityBackground(),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: Consumer<NotificationProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading && provider.notifications.isEmpty) {
                        return _buildLoadingShimmer();
                      }

                      if (provider.error != null) {
                        return _buildErrorState(provider);
                      }

                      if (provider.notifications.isEmpty) {
                        return _buildEmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: () => provider.fetchNotifications(),
                        color: AppConsts.accentColor,
                        backgroundColor: Colors.white,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                          itemCount: provider.notifications.length,
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder: (context, index) => const SizedBox(height: 20),
                          itemBuilder: (context, index) {
                            final notification = provider.notifications[index];
                            return _buildAnimatedNotificationCard(notification, provider, index);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppConsts.primaryColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  S.of(context).notification_title,
                  style: const TextStyle(
                    color: AppConsts.primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  if (provider.unreadCount == 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppConsts.accentColor, Color(0xFFFF6B6B)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppConsts.accentColor.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      S.of(context).notification_newCount(provider.unreadCount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(NotificationProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: AppConsts.accentColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            S.of(context).notification_errorTitle,
            style: const TextStyle(
              color: AppConsts.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              provider.error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppConsts.primaryColor.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildFuturisticButton(
            label: S.of(context).notification_tryAgain,
            onTap: () => provider.fetchNotifications(),
          ),
        ],
      ),
    );
  }

  Widget _buildAntigravityBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Color(0xFFFFF5EA),
              AppConsts.backgroundColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildFloatingShape(
              top: -50,
              right: -50,
              size: 250,
              color: AppConsts.accentColor.withOpacity(0.08),
            ),
            _buildFloatingShape(
              bottom: 100,
              left: -80,
              size: 300,
              color: AppConsts.secondaryAccentColor.withOpacity(0.05),
            ),
            _buildFloatingShape(
              top: 300,
              right: 100,
              size: 150,
              color: AppConsts.accentColor.withOpacity(0.05),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingShape({double? top, double? bottom, double? left, double? right, required double size, required Color color}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildAnimatedNotificationCard(notification, provider, index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + ((index as int) * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: _buildDismissibleCard(notification, provider),
          ),
        );
      },
    );
  }

  Widget _buildDismissibleCard(notification, provider) {
    return Dismissible(
      key: Key(notification.id!),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => provider.deleteNotification(notification.id!),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 25),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 32),
      ),
      child: _buildNotificationCard(notification, provider),
    );
  }

  Widget _buildNotificationCard(notification, provider) {
    final isUnread = notification.isShow == false;
    final createdAt = notification.createdAt != null
        ? DateTime.parse(notification.createdAt!)
        : DateTime.now();
    final timeStr = DateFormat('MMM d, h:mm a').format(createdAt);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isUnread ? 0.08 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            if (isUnread) provider.markAsRead(notification.id!);
            if (notification.orderId != null) {
              final authProvider = context.read<AuthProvider>();
              final isSeller = authProvider.currentUserType == 'seller';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => isSeller
                      ? SellerOrderDetailScreen(orderId: notification.orderId!)
                      : BuyerOrderDetailScreen(orderId: notification.orderId!),
                ),
              );
            }
          },
          splashColor: AppConsts.accentColor.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatar(notification),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  provider.getNotificationTitle(notification),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                    color: AppConsts.primaryColor.withOpacity(isUnread ? 1.0 : 0.6),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppConsts.accentColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppConsts.accentColor,
                                        blurRadius: 6,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            provider.getNotificationBody(notification),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppConsts.primaryColor.withOpacity(isUnread ? 0.7 : 0.5),
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppConsts.primaryColor.withOpacity(0.4),
                      ),
                    ),
                    if (isUnread)
                      GestureDetector(
                        onTap: () => provider.markAsRead(notification.id!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: AppConsts.accentColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            S.of(context).notification_markAsRead,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppConsts.accentColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(notification) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConsts.accentColor,
            AppConsts.accentColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppConsts.accentColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 15 * (1 - value)),
                child: Icon(
                  Icons.notifications_off_rounded,
                  size: 80,
                  color: AppConsts.accentColor.withOpacity(0.6),
                ),
              );
            },
            curve: Curves.easeInOutSine,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              S.of(context).notification_emptyState,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppConsts.primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildFuturisticButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: AppConsts.primaryColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppConsts.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.5),
        highlightColor: Colors.white.withOpacity(0.8),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
