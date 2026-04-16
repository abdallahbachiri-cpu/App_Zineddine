import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/errors/failures.dart';
import 'package:cuisinous/core/mixins/auto_refresh_mixin.dart';
import 'package:cuisinous/data/models/buyer_order.dart';
import 'package:cuisinous/data/models/full_buyer_order.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/vendor_order_provider.dart';
import 'package:cuisinous/core/enums/order_enums.dart';
import 'package:cuisinous/widgets/call_now_button.dart';
import 'package:cuisinous/widgets/order_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen>
    with WidgetsBindingObserver, AutoRefreshMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void onAutoRefresh() {
    context.read<VendorOrderProvider>().fetchOrders(silent: true);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorOrderProvider>().fetchOrders();
    });
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<VendorOrderProvider>().loadMoreOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(S.of(context).sellerOrderManagement_title),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
              Consumer<VendorOrderProvider>(
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
                    context.read<VendorOrderProvider>()
                      ..clearError()
                      ..fetchOrders(resetFilters: true),
          ),
        ],
      ),
      body: Consumer<VendorOrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            final error = provider.error!;
            if (provider.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => provider.fetchOrders(),
                      child: Text(S.of(context).sellerOrderManagement_retry),
                    ),
                  ],
                ),
              );
            } else {
              if (ModalRoute.of(context)?.isCurrent == true) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                  provider.clearError();
                });
              }
            }
          }

          if (provider.orders.isEmpty) {
            return Center(
              child: Text(S.of(context).sellerOrderManagement_empty),
            );
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
                return _VendorOrderListItem(order: order);
              },
            ),
          );
        },
      ),

      floatingActionButton:
          _scrollController.hasClients
              ? FloatingActionButton(
                backgroundColor: AppConsts.backgroundColor,
                heroTag: "buyerOrderScreenFab",
                onPressed:
                    () => {
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                    },
                child: const Icon(Icons.arrow_upward),
              )
              : null,
    );
  }

  void _showFilterDialog() {
    final provider = context.read<VendorOrderProvider>();

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
            searchLabel: S.of(context).buyerOrders_searchLabel,
            searchHint: S.of(context).sellerOrderManagement_searchHint,
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

class _VendorOrderListItem extends StatelessWidget {
  final SmallOrder order;

  const _VendorOrderListItem({required this.order});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VendorOrderDetailScreen(orderId: order.id),
              ),
            ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${S.of(context).sellerOrderManagement_orderNumber} ${order.orderNumber}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${S.of(context).sellerOrderManagement_itemBuyer} ${order.buyerFullName}',
                      ),
                      Text(
                        '${S.of(context).sellerOrderManagement_itemTotal} \$${order.totalPrice.toStringAsFixed(2)}',
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
                    '${S.of(context).sellerOrderManagement_itemPlaced} ${DateFormat.yMMMd().format(order.createdAt)}',
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VendorOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const VendorOrderDetailScreen({super.key, required this.orderId});

  @override
  State<VendorOrderDetailScreen> createState() =>
      _VendorOrderDetailScreenState();
}

class _VendorOrderDetailScreenState extends State<VendorOrderDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrder();
    });
  }

  Future<void> _loadOrder() async {
    if (!mounted) return;
    await context.read<VendorOrderProvider>().getOrderById(widget.orderId);
  }

  void _showErrorSnackBar(BuildContext context, String error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(error)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: S.of(context).retry,
          textColor: Colors.white,
          onPressed: _loadOrder,
        ),
      ),
    );
  }

  bool _shouldShowProxyCall(FullOrder order) {
    final paymentStatus = parseOrderPaymentStatus(order.paymentStatus);
    final orderStatus = parseOrderStatus(order.status);

    final isPaid = paymentStatus == OrderPaymentStatus.paid;
    final isDelivered = orderStatus == OrderStatus.completed;

    return isPaid && !isDelivered;
  }

  Future<void> _handleProxyCall(
    VendorOrderProvider provider,
    FullOrder order,
  ) async {
    try {
      final proxyNumbers = await provider.fetchProxyNumbers(order.id);
      if (!mounted) return;
      await _launchDialer(proxyNumbers.buyerProxyNumber);
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      _showErrorSnackBar(context, _mapProxyCallError(failure));
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(context, S.of(context).proxyCallUnableToInitiate);
    }
  }

  Future<void> _launchDialer(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);

    if (!await canLaunchUrl(uri)) {
      if (!mounted) return;
      _showErrorSnackBar(context, S.of(context).proxyCallNotSupported);
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!launched) {
      _showErrorSnackBar(context, S.of(context).proxyCallUnableToInitiate);
    }
  }

  String _mapProxyCallError(ApiFailure failure) {
    switch (failure.statusCode) {
      case 400:
        return S.of(context).proxyCallNotAvailable;
      case 404:
        return S.of(context).proxyCallOrderNotFound;
      case 500:
        return S.of(context).proxyCallServerError;
      default:
        return failure.message.isNotEmpty
            ? failure.message
            : S.of(context).proxyCallUnableToInitiate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<VendorOrderProvider>().clearError();
            Navigator.pop(context);
          },
        ),
        title: Text(S.of(context).sellerOrderManagement_orderDetailsTitle),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Consumer<VendorOrderProvider>(
          builder: (context, provider, _) {
            if (provider.error != null) {
              final error = provider.error!;
              if (ModalRoute.of(context)?.isCurrent == true) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showErrorSnackBar(context, error);
                  provider.clearError();
                });
              }
            }

            if (provider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      S.of(context).loadingOrderDetails,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            final order = provider.selectedOrder;
            if (order == null || order.id != widget.orderId) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, color: Colors.grey, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).sellerOrderManagement_notFound,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadOrder,
                      icon: const Icon(Icons.refresh),
                      label: Text(S.of(context).retry),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildReceiptHeader(order),
                  const SizedBox(height: 24),

                  _buildOrderStatusRow(order),
                  const SizedBox(height: 24),

                  _buildSection(
                    S.of(context).sellerOrderManagement_sectionCustomer,
                    [
                      _buildReceiptRow(
                        S.of(context).sellerOrderManagement_labelName,
                        order.buyer.fullName,
                      ),
                    ],
                  ),

                  _buildSection(S.of(context).deliveryMethod, [
                    _buildReceiptRow(
                      S.of(context).method,
                      order.deliveryMethod?.toUpperCase() ?? S.of(context).deliveryMethodLabel,
                    ),
                  ]),

                  if (order.deliveryMethod?.toLowerCase() != 'pickup')
                    _buildSection(
                      S.of(context).sellerOrderManagement_sectionDeliveryTo,
                      [
                        Text(order.location.street),
                        Text('${order.location.city}, ${order.location.state}'),
                        Text(order.location.zipCode),
                      ],
                    ),

                  if (order.buyerNote != null && order.buyerNote!.isNotEmpty)
                    _buildSection(
                      S.of(context).sellerOrderManagement_sectionOrderNotes,
                      [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            order.buyerNote!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),

                  _buildSection(
                    S.of(context).sellerOrderManagement_sectionItems,
                    [
                      ...order.dishes.map(
                        (item) => Column(
                          children: [
                            _buildItemRow(
                              name: item.dish.name,
                              quantity: item.quantity,
                              price: item.unitPrice,
                              total: item.baseSubtotalPrice,
                              dishId: item.dish.id,
                              orderId: order.id,
                              status: order.status,
                            ),
                            if (item.ingredients.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  bottom: 8,
                                ),
                                child: Wrap(
                                  spacing: 6,
                                  children:
                                      item.ingredients
                                          .map(
                                            (i) => Chip(
                                              label: Text(
                                                Localizations.localeOf(context).languageCode == 'fr'
                                                    ? i.dishIngredient.ingredientNameFr
                                                    : i.dishIngredient.ingredientNameEn,
                                              ),
                                              padding: EdgeInsets.zero,
                                              labelPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            const Divider(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),

                  _buildSection(
                    S.of(context).sellerOrderManagement_sectionTotal,
                    [
                      _buildReceiptRow(
                        S.of(context).sellerOrderManagement_labelSubtotal,
                        '\$${order.totalPrice.toStringAsFixed(2)}',
                      ),
                      _buildReceiptRow(
                        "${S.of(context).taxLabel} ${order.appliedTaxes.rates.entries.map((e) => '${e.key}: ${(e.value * 100).toStringAsFixed(3).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "")}%').join(', ')}",
                        '\$${order.taxTotal.toStringAsFixed(2)}',
                      ),
                      if (order.tipAmount != null && order.tipAmount! > 0)
                        _buildReceiptRow(
                          S.of(context).sellerOrderManagement_labelTipAmount,
                          '\$${order.tipAmount!.toStringAsFixed(2)}',
                        ),
                      _buildReceiptDivider(),
                      _buildReceiptTotalRow(
                        S.of(context).sellerOrderManagement_totalPaid,
                        order.grossTotal + (order.tipAmount ?? 0),
                      ),
                    ],
                  ),

                  _buildSection(
                    S.of(context).sellerOrderManagement_sectionPaymentDetails,
                    [
                      _buildStatusChip(
                        S.of(context).sellerOrderManagement_labelPaymentStatus,
                        parseOrderPaymentStatus(
                          order.paymentStatus,
                        ).translate(context),
                        parseOrderPaymentStatus(order.paymentStatus).color,
                      ),
                      _buildStatusChip(
                        S.of(context).sellerOrderManagement_labelDeliveryStatus,
                        parseOrderDeliveryStatus(
                          order.deliveryStatus,
                        ).translate(context),
                        parseOrderDeliveryStatus(order.deliveryStatus).color,
                      ),
                      if (order.confirmationCode != null)
                        _buildReceiptRow(
                          S
                              .of(context)
                              .sellerOrderManagement_labelConfirmationCode,
                          order.confirmationCode!,
                        ),
                    ],
                  ),

                  _buildSection(S.of(context).sellerOrderManagement_orderFrom, [
                    Text(
                      order.store.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(order.store.description ?? ''),
                    const SizedBox(height: 8),
                    Text(order.store.address.street ?? ''),
                    Text(
                      '${order.store.address.city}, ${order.store.address.state}',
                    ),
                    Text(order.store.address.zipCode ?? ''),
                  ]),

                  if (order.confirmationCode != null &&
                      parseOrderDeliveryStatus(order.deliveryStatus) !=
                          OrderDeliveryStatus.delivered)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        "${S.of(context).sellerOrderManagement_thankYou}\n",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),

                  _buildActionButtons(context, provider, order),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReceiptHeader(FullOrder order) {
    return Column(
      children: [
        Text(
          order.store.name.toUpperCase(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          order.store.address.street ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          '${order.store.address.city}, ${order.store.address.state}',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Divider(thickness: 2),
        _buildReceiptRow(
          S.of(context).sellerOrderManagement_orderNumber,
          order.orderNumber,
        ),
        _buildReceiptRow(
          S.of(context).sellerOrderManagement_date,
          DateFormat.yMd().add_jm().format(order.createdAt),
        ),
        const Divider(thickness: 2),
      ],
    );
  }

  Widget _buildItemRow({
    required String name,
    required int quantity,
    required double price,
    required double total,
    required String dishId,
    required String orderId,
    required String status,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '${quantity}x $name',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${price.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${total.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildReceiptDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: Colors.grey[400], height: 1),
    );
  }

  Widget _buildReceiptTotalRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label: ', style: TextStyle(color: Colors.grey[600])),
          Chip(
            label: Text(value.toUpperCase()),
            backgroundColor: color,
            labelStyle: const TextStyle(fontSize: 12, color: Colors.white),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusRow(FullOrder order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (order.status == 'cancelled')
          _buildTimelineStep(
            OrderStatus.cancelled.translate(context),
            isActive: true,
          ),
        if (order.status != 'cancelled') ...[
          _buildTimelineStep(
            OrderStatus.pending.translate(context),
            isActive: true,
          ),
          _buildTimelineStep(
            OrderStatus.confirmed.translate(context),
            isActive:
                order.status == 'confirmed' ||
                order.status == 'ready' ||
                order.status == 'completed',
          ),
          _buildTimelineStep(
            OrderStatus.ready.translate(context),
            isActive: order.status == 'ready' || order.status == 'completed',
          ),
          _buildTimelineStep(
            OrderStatus.completed.translate(context),
            isActive: order.status == 'completed',
          ),
        ],
      ],
    );
  }

  Widget _buildTimelineStep(String label, {required bool isActive}) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color:
                isActive
                    ? label == OrderStatus.cancelled.translate(context)
                        ? Colors.red
                        : Colors.green
                    : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child:
              isActive
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color:
                isActive
                    ? label == OrderStatus.cancelled.translate(context)
                        ? Colors.red
                        : Colors.green
                    : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    VendorOrderProvider provider,
    FullOrder order,
  ) {
    final orderStatus = parseOrderStatus(order.status);
    final showConfirmOrder = orderStatus == OrderStatus.pending;
    final showReadyButton = orderStatus == OrderStatus.confirmed;
    final showConfirmDelivery = orderStatus == OrderStatus.ready;
    final showCancelButton =
        orderStatus != OrderStatus.cancelled &&
        orderStatus != OrderStatus.completed &&
        orderStatus != OrderStatus.ready;

    return Column(
      children: [
        CallNowButton(
          visible: _shouldShowProxyCall(order),
          isLoading: provider.isProxyCallLoading,
          onPressed: () => _handleProxyCall(provider, order),
          backgroundColor: AppConsts.secondaryAccentColor,
          foregroundColor: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          label: S.of(context).callBuyer,
        ),
        if (showConfirmOrder)
          ElevatedButton(
            onPressed:
                provider.isProcessing
                    ? null
                    : () => provider.confirmOrder(order.id),
            child: Text(S.of(context).confirmOrderButton),
          ),
        if (showReadyButton)
          ElevatedButton(
            onPressed:
                provider.isProcessing
                    ? null
                    : () => provider.markOrderAsReady(order.id),
            child: Text(S.of(context).markAsReadyButton),
          ),
        if (showConfirmDelivery)
          ElevatedButton(
            onPressed: () => _showDeliveryConfirmationDialog(context, provider),
            child: Text(S.of(context).confirmDeliveryButton),
          ),
        if (showCancelButton)
          TextButton(
            onPressed:
                provider.isProcessing
                    ? null
                    : () => provider.cancelOrder(order.id),
            child: Text(
              S.of(context).sellerOrderManagement_cancelOrder,
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  void _showDeliveryConfirmationDialog(
    BuildContext context,
    VendorOrderProvider provider,
  ) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(S.of(context).confirmDeliveryButton),
            content: TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: S.of(context).orderConfirmationCode,
                hintText: S.of(context).confirmationCodeHint,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).sellerOrderManagement_cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.confirmDelivery(
                    provider.selectedOrder!.id,
                    codeController.text,
                  );
                  Navigator.pop(context);
                },
                child: Text(S.of(context).confirm),
              ),
            ],
          ),
    );
  }
}
