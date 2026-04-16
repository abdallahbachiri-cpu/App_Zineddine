import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/widgets/network_image_widget.dart';
import 'package:cuisinous/data/models/cart.dart';
import 'package:cuisinous/data/models/cart_dish.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/cart_provider.dart';
import 'package:cuisinous/screens/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          S.of(context).cart_title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<CartProvider>().fetchCart(),
            tooltip: S.of(context).cart_refreshTooltip,
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            if (provider.cart == null) {
              return _ErrorState(
                error: provider.error!,
                onRetry: provider.fetchCart,
              );
            }

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

          if (provider.cart == null || provider.cart!.dishes.isEmpty) {
            return const _EmptyState();
          }

          final cart = provider.cart!;

          return Stack(
            children: [
              ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                itemCount: cart.dishes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final dish = cart.dishes[index];
                  return CartItemWidget(dish: dish);
                },
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _CheckoutBar(cart: cart),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final Cart cart;

  const _CheckoutBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CartProvider>();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppConsts.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).cart_total,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '\$ ${cart.totalPrice.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.shopping_cart_checkout_rounded),
            label: Text(S.of(context).cart_checkoutButton),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConsts.secondaryAccentColor,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed:
                provider.isProcessing || cart.dishes.isEmpty
                    ? null
                    : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(cart: cart),
                        ),
                      );
                    },
          ),
        ],
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartDish dish;

  const CartItemWidget({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CartProvider>();
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        color: AppConsts.backgroundColor,
        elevation: 2,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withAlpha(25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NetworkImageWidget(
                    imageUrl:
                        dish.dish.gallery.isNotEmpty
                            ? dish.dish.gallery.first.url
                            : '',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12),
                  ),

                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dish.dish.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$ ${dish.dishUnitPrice.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black.withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: AppConsts.accentColor,
                    onPressed:
                        provider.isProcessing
                            ? null
                            : () => provider.removeDishFromCart(dish.id),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 80),
                  const Spacer(),
                  _QuantitySelector(
                    currentQuantity: dish.quantity,
                    onChanged:
                        (newQuantity) =>
                            provider.updateDishQuantity(dish.id, newQuantity),
                    maxQuantity: CartProvider.MAX_DISH_QUANTITY,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int currentQuantity;
  final Function(int) onChanged;
  final int maxQuantity;

  const _QuantitySelector({
    required this.currentQuantity,
    required this.onChanged,
    required this.maxQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppConsts.accentColor.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded),
            color: Colors.black,
            iconSize: 20,
            onPressed:
                currentQuantity > 1
                    ? () => onChanged(currentQuantity - 1)
                    : null,
          ),
          Text(
            currentQuantity.toString(),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            color: Colors.black,
            iconSize: 20,
            onPressed:
                currentQuantity < maxQuantity
                    ? () => onChanged(currentQuantity + 1)
                    : null,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 24),
          Text(
            S.of(context).cart_emptyTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).cart_emptySubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(S.of(context).cart_errorTryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
