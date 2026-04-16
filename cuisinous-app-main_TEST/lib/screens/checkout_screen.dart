import 'package:cuisinous/core/constants/app_consts.dart';

import 'package:cuisinous/data/models/cart.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/core/enums/navigation_item.dart';
import 'package:cuisinous/providers/buyer_order_provider.dart';
import 'package:cuisinous/providers/cart_provider.dart';
import 'package:cuisinous/providers/navigation_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final Cart cart;
  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _refreshCart() {
    context.read<CartProvider>().fetchCart();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _handlePayment() async {
    final orderProvider = context.read<BuyerOrderProvider>();

    try {
      await orderProvider.checkout(null);
      _refreshCart();

      if (!mounted) return;

      if (orderProvider.error != null) {
        _showSnackBar(
          orderProvider.error ?? S.of(context).checkout_errorMessage,
          isError: true,
        );
        return;
      }

      _showSnackBar(S.of(context).checkout_successMessage);
      if (mounted) {
        context.read<BuyerOrderProvider>().fetchOrders();
        context.read<NavigationProvider>().setNavigationItem(
          NavigationItem.orders,
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      _showSnackBar(
        orderProvider.error ?? S.of(context).checkout_errorMessage,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConsts.backgroundColor,
        title: Text(S.of(context).checkout_title),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.of(context).checkout_yourOrder,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _MiniCartWidget(cart: widget.cart),
              const SizedBox(height: 20),
              const Spacer(),
              Consumer<BuyerOrderProvider>(
                builder: (context, orderProvider, _) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed:
                        widget.cart.dishes.isEmpty || orderProvider.isProcessing
                            ? null
                            : _handlePayment,
                    child:
                        orderProvider.isProcessing
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(
                              S.of(context).checkout_placeOrder,
                              style: const TextStyle(fontSize: 18),
                            ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniCartWidget extends StatelessWidget {
  final Cart? cart;
  const _MiniCartWidget({required this.cart});

  @override
  Widget build(BuildContext context) {
    if (cart == null || cart!.dishes.isEmpty) {
      return Text(S.of(context).cart_emptyTitle);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ...cart!.dishes.map(
              (dish) => _CartItemRow(
                name: dish.dish.name,
                quantity: dish.quantity,
                price: dish.dish.price * dish.quantity,
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).buyerOrderDetails_labelSubtotal,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${cart!.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (cart!.appliedTaxes != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tax ${cart!.appliedTaxes!.rates.entries.map((e) => '${e.key}: ${(e.value * 100).toStringAsFixed(3).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "")}%').join(', ')}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${(cart!.taxTotal ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
            if (cart!.grossTotal != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).cart_total,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${cart!.grossTotal!.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final String name;
  final int quantity;
  final double price;

  const _CartItemRow({
    required this.name,
    required this.quantity,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$name x$quantity'),
          Text('\$${price.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
