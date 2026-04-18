import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/errors/failures.dart';
import 'package:cuisinous/core/routes/app_router.dart';
import 'package:cuisinous/data/models/full_buyer_order.dart';
import 'package:cuisinous/providers/chat_provider.dart';
import 'package:cuisinous/core/enums/order_enums.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/providers/buyer_order_provider.dart';
import 'package:cuisinous/providers/buyer_rating_provider.dart';
import 'package:cuisinous/providers/payment_creds_provider.dart';
import 'package:cuisinous/widgets/custom_input_field.dart';

import 'package:cuisinous/widgets/tip_modal.dart';
import 'package:cuisinous/widgets/call_now_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart'
    show
        PaymentSheetApplePay,
        PaymentSheetGooglePay,
        SetupPaymentSheetParameters,
        Stripe,
        StripeException,
        FailureCode;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cuisinous/screens/menu_item_reviews_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cuisinous/core/utils/map_marker_utils.dart';

class BuyerOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const BuyerOrderDetailScreen({super.key, required this.orderId});

  @override
  State<BuyerOrderDetailScreen> createState() => _BuyerOrderDetailScreenState();
}

class _BuyerOrderDetailScreenState extends State<BuyerOrderDetailScreen> {
  final TextEditingController _noteController = TextEditingController();
  BitmapDescriptor? _customMarkerIcon;
  bool _hasShownTipModal = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (mounted) {
          context.read<BuyerOrderProvider>().getOrderById(widget.orderId);
          context.read<BuyerRatingProvider>().fetchUserRatings(refresh: true);
        }
      }
    });
  }

  Future<void> _handleLeaveTip(FullOrder order) async {
    final double? tipAmount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: TipModal(orderTotal: order.grossTotal),
          ),
    );

    if (tipAmount == null || tipAmount <= 0) return;

    try {
      final data = await context.read<BuyerOrderProvider>().addTipToOrder(
        order.id,
        tipAmount,
      );

      if (data == null) {
        final provider = context.read<BuyerOrderProvider>();
        if (provider.error != null) {
          _scaffoldMessengerShowSnackBar(provider.error!, color: Colors.red);
          provider.clearError();
        } else {
          _scaffoldMessengerShowSnackBar(
            S.of(context).paymentFailedToInitialize,
            color: Colors.red,
          );
        }
        return;
      }

      if (!data.containsKey('paymentResponse')) {
        throw Exception("Invalid server response: Missing payment details");
      }

      final paymentResponse = data['paymentResponse'];
      final clientSecret = paymentResponse['client_secret'];

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
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      await _refetchOrder();
      _scaffoldMessengerShowSnackBar(
        S.of(context).tipSuccess,
        color: Colors.green,
      );
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return;
      }
      _scaffoldMessengerShowSnackBar(
        S.of(context).paymentStripeError(e.error.localizedMessage ?? ""),
        color: Colors.red,
      );
    } catch (e) {
      _scaffoldMessengerShowSnackBar(S.of(context).paymentUnexpectedError(e.toString()), color: Colors.red);
    }
  }

  Future<void> _handlePayForOrder(FullOrder order) async {
    try {
      final data = await context.read<BuyerOrderProvider>().payOrder(order.id);

      if (data == null) {
        final provider = context.read<BuyerOrderProvider>();
        if (provider.error != null) {
          _scaffoldMessengerShowSnackBar(provider.error!, color: Colors.red);
          provider.clearError();
        } else {
          _scaffoldMessengerShowSnackBar(
            S.of(context).paymentFailedToInitialize,
            color: Colors.red,
          );
        }
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
      await _refetchOrder();
      _scaffoldMessengerShowSnackBar(S.of(context).paymentCompleted);
    } on StripeException catch (e) {
      _scaffoldMessengerShowSnackBar(
        S.of(context).paymentStripeError(e.error.localizedMessage ?? ""),
      );
    } catch (e) {
      _scaffoldMessengerShowSnackBar(S.of(context).paymentUnexpectedError(e.toString()));
    }
  }

  void _scaffoldMessengerShowSnackBar(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _refetchOrder() async {
    await context.read<BuyerOrderProvider>().getOrderById(widget.orderId);
  }

  bool _shouldShowProxyCall(FullOrder order) {
    final paymentStatus = parseOrderPaymentStatus(order.paymentStatus);
    final orderStatus = parseOrderStatus(order.status);

    final isPaid = paymentStatus == OrderPaymentStatus.paid;
    final isDelivered = orderStatus == OrderStatus.completed;

    return isPaid && !isDelivered;
  }

  bool _hasValidPhoneNumber() {
    final user = context.read<AuthProvider>().user;
    if (user?.phoneNumber == null || user!.phoneNumber!.isEmpty) {
      return false;
    }

    final phoneNumber = user.phoneNumber!;

    if (!phoneNumber.startsWith('+')) {
      return false;
    }

    final digitsOnly = phoneNumber
        .substring(1)
        .replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10 || digitsOnly.length > 13) {
      return false;
    }

    final phoneDigits =
        digitsOnly.length > 9
            ? digitsOnly.substring(digitsOnly.length - 9)
            : digitsOnly;
    return phoneDigits.length == 9 &&
        RegExp(r'^[0-9]{9}$').hasMatch(phoneDigits);
  }

  void _navigateToProfile() {
    Navigator.of(context).pushNamed(AppRouter.profile);
  }

  Future<void> _handleProxyCall(
    BuyerOrderProvider provider,
    FullOrder order,
  ) async {
    try {
      final proxyNumbers = await provider.fetchProxyNumbers(order.id);
      if (!mounted) return;
      await _launchDialer(proxyNumbers.sellerProxyNumber);
    } on ApiFailure catch (failure) {
      _scaffoldMessengerShowSnackBar(
        _mapProxyCallError(failure),
        color: Colors.red,
      );
    } catch (e) {
      _scaffoldMessengerShowSnackBar(
        S.of(context).proxyCallUnableToInitiate,
        color: Colors.red,
      );
    }
  }

  Future<void> _launchDialer(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);

    if (!await canLaunchUrl(uri)) {
      _scaffoldMessengerShowSnackBar(
        S.of(context).proxyCallNotSupported,
        color: Colors.red,
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      _scaffoldMessengerShowSnackBar(
        S.of(context).proxyCallUnableToInitiate,
        color: Colors.red,
      );
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

  Widget _buildMiniMap(Store store) {
    if (store.address.latitude == 0 && store.address.longitude == 0) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => _navigateToMap(store),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              AbsorbPointer(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      store.address.latitude,
                      store.address.longitude,
                    ),
                    zoom: 15,
                  ),
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  markers: {
                    Marker(
                      markerId: MarkerId(store.id),
                      position: LatLng(
                        store.address.latitude,
                        store.address.longitude,
                      ),
                      icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
                    ),
                  },
                  onMapCreated: (controller) {
                    _loadMarkerIcon(store);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadMarkerIcon(Store store) async {
    if (_customMarkerIcon == null) {
      final icon = await MapMarkerUtils.loadStoreMarkerIcon(
        store.profileImageUrl,
      );
      if (icon != null && mounted) {
        setState(() {
          _customMarkerIcon = icon;
        });
      }
    }
  }

  Future<void> _navigateToMap(Store store) async {
    await MapMarkerUtils.navigateToMap(
      context,
      store.address.latitude,
      store.address.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConsts.backgroundColor,
        title: Text(S.of(context).buyerOrderDetails_title),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Consumer2<BuyerOrderProvider, BuyerRatingProvider>(
          builder: (context, orderProvider, ratingProvider, _) {
            final order = orderProvider.selectedOrder;

            if (orderProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (orderProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      orderProvider.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _refetchOrder(),
                      child: Text(S.of(context).buyerOrders_errorRetry),
                    ),
                  ],
                ),
              );
            }

            if (order == null || order.id != widget.orderId) {
              return Center(
                child: Text(S.of(context).buyerOrderDetails_notFound),
              );
            }

            // Check for auto-showing tip modal
            if (!_hasShownTipModal &&
                parseOrderStatus(order.status) == OrderStatus.completed &&
                (order.tipAmount == null)) {
              _hasShownTipModal = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _handleLeaveTip(order);
                }
              });
            }

            return RefreshIndicator(
              onRefresh: _refetchOrder,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildReceiptHeader(order),
                    const SizedBox(height: 24),
                    _buildOrderStatusRow(order),
                    if (order.confirmationCode != null &&
                        parseOrderStatus(order.status) == OrderStatus.ready &&
                        parseOrderPaymentStatus(order.paymentStatus) ==
                            OrderPaymentStatus.paid) ...[
                      const SizedBox(height: 24),
                      _buildConfirmationCode(order.confirmationCode!),
                    ],
                    const SizedBox(height: 24),
                    _buildSection(
                      S.of(context).buyerOrderDetails_sectionOrderNotes,
                      [
                        if (order.buyerNote != null &&
                            order.buyerNote!.isNotEmpty)
                          _buildNoteCard(order.buyerNote!, order),
                        if (order.buyerNote == null || order.buyerNote!.isEmpty)
                          _buildNoteCard(
                            S.of(context).buyerOrderDetails_noNotes,
                            order,
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    _buildSection(
                      S.of(context).buyerOrderDetails_sectionCustomer,
                      [
                        _buildReceiptRow(
                          S.of(context).buyerOrderDetails_labelName,
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
                        S.of(context).buyerOrderDetails_sectionDeliveryTo,
                        [
                          Text(order.location.street),
                          Text(
                            '${order.location.city}, ${order.location.state}',
                          ),
                          Text(order.location.zipCode),
                        ],
                      ),
                    _buildSection(
                      S.of(context).buyerOrderDetails_sectionItems,
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
                    _buildSection(S.of(context).buyerOrderDetails_sectionTotal, [
                      _buildReceiptRow(
                        S.of(context).buyerOrderDetails_labelSubtotal,
                        '\$${order.totalPrice.toStringAsFixed(2)}',
                      ),
                      _buildReceiptRow(
                        "${S.of(context).taxLabel} ${order.appliedTaxes.rates.entries.map((e) => '${e.key}: ${(e.value * 100).toStringAsFixed(3).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "")}%').join(', ')}",
                        '\$${order.taxTotal.toStringAsFixed(2)}',
                      ),
                      _buildReceiptRow(
                        S.of(context).cart_total,
                        '\$${order.grossTotal.toStringAsFixed(2)}',
                      ),
                      if (order.tipAmount != null && order.tipAmount! > 0)
                        _buildReceiptRow(
                          S.of(context).buyerOrderDetails_labelTipAmount,
                          '\$${order.tipAmount!.toStringAsFixed(2)}',
                        ),
                      _buildReceiptDivider(),
                      _buildReceiptTotalRow(
                        S.of(context).buyerOrderDetails_totalPaid,
                        order.grossTotal + (order.tipAmount ?? 0),
                      ),
                    ]),
                    _buildSection(
                      S.of(context).buyerOrderDetails_sectionPaymentDetails,
                      [
                        _buildStatusChip(
                          S.of(context).buyerOrderDetails_labelPaymentStatus,
                          parseOrderPaymentStatus(
                            order.paymentStatus,
                          ).translate(context),
                          parseOrderPaymentStatus(order.paymentStatus).color,
                        ),
                        _buildStatusChip(
                          S.of(context).buyerOrderDetails_labelDeliveryStatus,
                          parseOrderDeliveryStatus(
                            order.deliveryStatus,
                          ).translate(context),
                          parseOrderDeliveryStatus(order.deliveryStatus).color,
                        ),
                      ],
                    ),
                    _buildSection(S.of(context).storeInformation, [
                      _buildReceiptRow(
                        S.of(context).storeNameLabel,
                        order.store.name,
                      ),
                      if (order.store.description != null &&
                          order.store.description!.isNotEmpty)
                        Text(
                          order.store.description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (order.store.address.street != null)
                        Text(order.store.address.street!),
                      Text(
                        '${order.store.address.city ?? ''}, ${order.store.address.state ?? ''}',
                      ),
                      if (order.store.address.zipCode != null)
                        Text(order.store.address.zipCode!),
                      if (parseOrderStatus(order.status) ==
                              OrderStatus.confirmed &&
                          parseOrderPaymentStatus(order.paymentStatus) ==
                              OrderPaymentStatus.paid) ...[
                        const SizedBox(height: 16),
                        _buildMiniMap(order.store),
                      ],
                    ]),
                    if (order.confirmationCode != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          '${S.of(context).buyerOrderDetails_thankYou}\n',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    _buildActionButtons(context, orderProvider, order),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    BuyerOrderProvider provider,
    FullOrder order,
  ) {
    final paymentStatus = parseOrderPaymentStatus(order.paymentStatus);
    final orderStatus = parseOrderStatus(order.status);
    final showPaymentButton =
        (paymentStatus == OrderPaymentStatus.pending || paymentStatus == OrderPaymentStatus.failed || paymentStatus == OrderPaymentStatus.processing)  &&
        orderStatus != OrderStatus.cancelled;
    final showCancelButton =
        orderStatus != OrderStatus.cancelled &&
        orderStatus != OrderStatus.completed;

    final showTipButton =
        orderStatus == OrderStatus.completed && order.tipAmount == null;

    final hasValidPhone = _hasValidPhoneNumber();
    final showProxyCall = _shouldShowProxyCall(order);

    return Column(
      children: [
        CallNowButton(
          visible: showProxyCall,
          isLoading: provider.isProxyCallLoading,
          onPressed:
              hasValidPhone
                  ? () => _handleProxyCall(provider, order)
                  : () => _navigateToProfile(),
          backgroundColor: AppConsts.secondaryAccentColor,
          foregroundColor: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),

          label:
              hasValidPhone
                  ? S.of(context).callSeller
                  : S.of(context).verifyYourNumberInProfile,
        ),
        if (showPaymentButton)
          ElevatedButton(
            onPressed:
                provider.isProcessing || orderStatus != OrderStatus.confirmed
                    ? null
                    : () => _handlePayForOrder(order),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConsts.secondaryAccentColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              orderStatus == OrderStatus.confirmed
                  ? S.of(context).buyerOrderDetails_payOrder
                  : S.of(context).buyerOrderDetails_waitingForConfirmation,
            ),
          ),
        if (showTipButton)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton.icon(
              onPressed:
                  provider.isProcessing ? null : () => _handleLeaveTip(order),
              icon: const Icon(Icons.monetization_on_outlined),
              label: Text(S.of(context).leaveATip),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: AppConsts.secondaryAccentColor),
                foregroundColor: AppConsts.secondaryAccentColor,
              ),
            ),
          ),
        if (showCancelButton)
          TextButton(
            onPressed:
                provider.isProcessing
                    ? null
                    : () => provider.cancelOrder(order.id),
            child: Text(
              S.of(context).buyerOrderDetails_cancelOrder,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        // ── Chat button ──────────────────────────────────────────────────
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8, bottom: 4),
          child: OutlinedButton.icon(
            onPressed: () {
              context.read<ChatProvider>().clear();
              Navigator.pushNamed(
                context,
                AppRouter.chat,
                arguments: {
                  'orderId': order.id,
                  'orderNumber': order.orderNumber,
                  'otherPartyName': order.store.name,
                },
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Contacter le vendeur'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFFF97316)),
              foregroundColor: const Color(0xFFF97316),
            ),
          ),
        ),
      ],
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
          order.store.address.street ?? "",
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
          S.of(context).buyerOrderDetails_labelOrderNumber,
          order.orderNumber,
        ),
        _buildReceiptRow(
          S.of(context).buyerOrderDetails_labelDate,
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
    return Column(
      children: [
        Padding(
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
        ),
        if (parseOrderStatus(status) == OrderStatus.completed)
          Consumer<BuyerRatingProvider>(
            builder: (context, ratingProvider, _) {
              final userRating = ratingProvider.userRatings.firstWhereOrNull(
                (rating) =>
                    rating.dishId == dishId && rating.orderId == orderId,
              );

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child:
                    userRating != null
                        ? InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => MenuItemReviewsScreen(
                                      dishId: dishId,
                                      orderId: orderId,
                                      dishName: name,
                                    ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${S.of(context).rated}: ",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),

                              ...List.generate(5, (index) {
                                return Icon(
                                  index < userRating.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 18,
                                );
                              }),
                              const SizedBox(width: 8),

                              Icon(
                                Icons.edit,
                                size: 14,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        )
                        : Center(
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => MenuItemReviewsScreen(
                                        dishId: dishId,
                                        orderId: orderId,
                                        dishName: name,
                                      ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.star_rate_rounded,
                              size: 20,
                              color: Colors.orange.shade900,
                            ),
                            label: Text(
                              S.of(context).rateDish,
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.orange.shade100,
                              elevation: 0,
                              foregroundColor: Colors.orange.shade900,
                              minimumSize: const Size(200, 30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
              );
            },
          ),
      ],
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
        _buildTimelineStep(
          S.of(context).buyerOrderDetails_timelineOrdered,
          isActive: true,
        ),
        _buildTimelineStep(
          S.of(context).buyerOrderDetails_timelineConfirmed,
          isActive:
              parseOrderStatus(order.status) == OrderStatus.confirmed ||
              parseOrderStatus(order.status) == OrderStatus.ready ||
              parseOrderStatus(order.status) == OrderStatus.completed,
        ),
        _buildTimelineStep(
          S.of(context).buyerOrderDetails_timelineReady,
          isActive:
              parseOrderStatus(order.status) == OrderStatus.ready ||
              parseOrderStatus(order.status) == OrderStatus.completed,
        ),

        _buildTimelineStep(
          S.of(context).buyerOrderDetails_timelineDelivered,
          isActive: parseOrderStatus(order.status) == OrderStatus.completed,
        ),
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
            color: isActive ? Colors.green : Colors.grey[300],
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
            color: isActive ? Colors.green : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showAddNoteDialog(BuildContext context, FullOrder order) {
    _noteController.text = order.buyerNote ?? '';

    showDialog(
      context: context,
      builder:
          (context) => Consumer<BuyerOrderProvider>(
            builder: (context, provider, _) {
              return AlertDialog(
                content: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomInputField(
                        controller: _noteController,
                        maxLines: 4,
                        maxLength: 1000,
                        labelText: S.of(context).buyerOrderDetails_noteLabel,
                        hintText: S.of(context).buyerOrderDetails_noteHint,
                        errorText: provider.error,
                      ),
                      if (provider.isProcessing)
                        const LinearProgressIndicator(),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(S.of(context).buyerOrderDetails_noteCancel),
                  ),
                  ElevatedButton(
                    onPressed:
                        provider.isProcessing
                            ? null
                            : () async {
                              try {
                                await provider.updateOrderNote(
                                  order.id,
                                  _noteController.text.trim(),
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  provider.getOrderById(order.id);
                                }
                              } on ApiFailure catch (e) {
                                _scaffoldMessengerShowSnackBar(
                                  e.message,
                                  color: Colors.red,
                                );
                              }
                            },
                    child: Text(S.of(context).buyerOrderDetails_noteSave),
                  ),
                ],
              );
            },
          ),
    );
  }

  Widget _buildNoteCard(String text, FullOrder order) {
    final canEdit =
        ![
          OrderStatus.cancelled.name,
          OrderStatus.completed.name,
        ].contains(order.status);

    return Card(
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.notes, size: 18, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text.isEmpty
                        ? S.of(context).buyerOrderDetails_noNotes
                        : text,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontStyle: text.isEmpty ? FontStyle.italic : null,
                    ),
                  ),
                ),
              ],
            ),
            if (canEdit) const SizedBox(height: 8),
            if (canEdit)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(S.of(context).buyerOrderDetails_editNote),
                  onPressed: () => _showAddNoteDialog(context, order),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueGrey[700],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationCode(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppConsts.secondaryAccentColor.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConsts.secondaryAccentColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            S.of(context).buyerOrderDetails_labelConfirmationCode.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppConsts.secondaryAccentColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            code,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              fontFamily: 'monospace',
              color: AppConsts.secondaryAccentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            S.of(context).buyerOrderDetails_showCodeToSeller,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
