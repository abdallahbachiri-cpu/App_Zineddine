import 'package:cuisinous/core/constants/app_consts.dart';
import 'dart:developer' as devtools;
import 'package:cuisinous/data/models/buyer_order.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/buyer_order_provider.dart';
import 'package:cuisinous/screens/buyer_order_details_screen.dart';
import 'package:cuisinous/core/enums/order_enums.dart';
import 'package:cuisinous/widgets/order_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart'
    show
        Stripe,
        StripeException,
        PaymentSheetGooglePay,
        PaymentSheetApplePay,
        SetupPaymentSheetParameters;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BuyerOrderScreen extends StatefulWidget {
  const BuyerOrderScreen({super.key});

  @override
  State<BuyerOrderScreen> createState() => _BuyerOrderScreenState();
}

class _BuyerOrderScreenState extends State<BuyerOrderScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BuyerOrderProvider>().fetchOrders();
    });
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    devtools.log('BuyerOrderScreen: dispose');
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<BuyerOrderProvider>().loadMoreOrders();
    }
  }

  Future<void> _handlePayForOrder(SmallOrder order) async {
    final provider = context.read<BuyerOrderProvider>();

    try {
      final data = await provider.payOrder(order.id);
      if (data == null) {
        _showSnackBar("Failed to initialize payment sheet");
        return;
      }
      final clientSecret = data["paymentResponse"]['client_secret'];
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.system,
          merchantDisplayName: "Cuisinous",
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'CA',
            currencyCode: 'CAD',
            testEnv: true,
          ),
          // applePay: const PaymentSheetApplePay(merchantCountryCode: 'CA'),
          allowsDelayedPaymentMethods: true,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      if (mounted) {
        _showSnackBar("Payment completed successfully!");
      }
      // FCM notification from the backend will trigger refreshOrders automatically
    } on StripeException catch (e) {
      _showSnackBar("Stripe error: ${e.error.localizedMessage}");
    } catch (e) {
      _showSnackBar("Unexpected error: $e");
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(S.of(context).buyerOrders_title),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
              Consumer<BuyerOrderProvider>(
                builder: (context, provider, _) {
                  if (!provider.hasActiveFilters) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () =>
                    context.read<BuyerOrderProvider>()
                      ..clearError()
                      ..fetchOrders(resetFilters: true),
          ),
        ],
      ),
      body: Consumer<BuyerOrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            if (provider.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => provider.fetchOrders(),
                      child: Text(S.of(context).buyerOrders_errorRetry),
                    ),
                  ],
                ),
              );
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.error!),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                provider.clearError();
              });
            }
          }

          if (provider.orders.isEmpty) {
            return Center(child: Text(S.of(context).buyerOrders_empty));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchOrders(resetFilters: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  provider.orders.length + (provider.canLoadMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= provider.orders.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final order = provider.orders[index];
                return _OrderListItem(order: order, onPay: _handlePayForOrder);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'buyerOrderScreenFab',
        onPressed:
            () => _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }

  void _showFilterDialog() {
    final provider = context.read<BuyerOrderProvider>();

    String search = provider.search;
    double? minPrice = provider.minPrice;
    double? maxPrice = provider.maxPrice;
    String? status = provider.status;
    String? paymentStatus = provider.paymentStatus;
    String? deliveryStatus = provider.deliveryStatus;
    String sortBy = provider.sortBy;
    String sortOrder = provider.sortOrder;

    showDialog(
      context: context,
      builder:
          (context) => OrderFilterDialog(
            initialSearch: search,
            initialMinPrice: minPrice,
            initialMaxPrice: maxPrice,
            initialStatus: status,
            initialPaymentStatus: paymentStatus,
            initialDeliveryStatus: deliveryStatus,
            initialSortBy: sortBy,
            initialSortOrder: sortOrder,
            onReset: () {
              provider.fetchOrders(resetFilters: true);
            },
            onApply: ({
              search,
              minPrice,
              maxPrice,
              status,
              paymentStatus,
              deliveryStatus,
              sortBy,
              sortOrder,
            }) {
              provider.setFilters(
                search: search ?? '',
                minPrice: minPrice,
                maxPrice: maxPrice,
                status: status,
                paymentStatus: paymentStatus,
                deliveryStatus: deliveryStatus,
                sortBy: sortBy ?? 'createdAt',
                sortOrder: sortOrder ?? 'DESC',
              );
            },
          ),
    );
  }
}

class _OrderListItem extends StatelessWidget {
  final SmallOrder order;
  final Function(SmallOrder) onPay;

  const _OrderListItem({required this.order, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BuyerOrderDetailScreen(orderId: order.id),
              ),
            ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${S.of(context).buyerOrders_itemNumber} #${order.orderNumber}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${S.of(context).buyerOrders_itemBuyer} ${order.buyerFullName}',
                      ),
                      Text(
                        '${S.of(context).buyerOrders_itemTotal} \$${order.grossTotal.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                  Chip(
                    label: Text(
                      parseOrderStatus(
                        order.status,
                      ).translate(context).toUpperCase(),
                    ),
                    backgroundColor: parseOrderStatus(
                      order.status,
                    ).color.withAlpha(50),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${S.of(context).buyerOrders_itemPlaced} ${DateFormat.yMMMd().format(order.createdAt)}',
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              
              if ((order.paymentStatus == 'pending' || order.paymentStatus == 'failed' || order.paymentStatus == 'processing') && parseOrderStatus(order.status) != OrderStatus.cancelled) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        parseOrderStatus(order.status) == OrderStatus.confirmed
                            ? () => onPay(order)
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConsts.secondaryAccentColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      parseOrderStatus(order.status) == OrderStatus.confirmed
                          ? S.of(context).buyerOrderDetails_payOrder
                          : S
                              .of(context)
                              .buyerOrderDetails_waitingForConfirmation,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
