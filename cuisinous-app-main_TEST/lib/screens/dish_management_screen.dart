import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/routes/app_router.dart';
import 'package:cuisinous/data/models/dish.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/dish_provider.dart';
import 'package:cuisinous/screens/dish_detail_screen.dart';
import 'package:cuisinous/widgets/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DishManagementScreen extends StatefulWidget {
  const DishManagementScreen({super.key});

  @override
  State<DishManagementScreen> createState() => _DishManagementScreenState();
}

class _DishManagementScreenState extends State<DishManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerDishProvider>().fetchDishes();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(S.of(context).dishManagement_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<SellerDishProvider>().fetchDishes(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConsts.backgroundColor,
        foregroundColor: Colors.black,
        heroTag: 'add_dish',
        onPressed: () => _showDishForm(context, null),
        child: const Icon(Icons.add),
      ),
      body: Consumer<SellerDishProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.dishes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  ElevatedButton(
                    onPressed: () => provider.fetchDishes(),
                    child: Text(S.of(context).dishManagement_retry),
                  ),
                ],
              ),
            );
          }

          if (provider.dishes.isEmpty) {
            return Center(child: Text(S.of(context).dishManagement_empty));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.dishes.length,
            itemBuilder: (context, index) {
              final dish = provider.dishes[index];
              return Dismissible(
                key: Key(dish.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  if (dish.available) {
                    await provider.deactivateDish(dish.id);
                  } else {
                    await provider.activateDish(dish.id);
                  }

                  if (context.mounted) {
                    if (provider.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.error!),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                      provider.clearError();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            dish.available
                                ? S.of(context).dishManagement_dishDeactivated
                                : S.of(context).dishManagement_dishActivated,
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }

                  return false;
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: dish.available ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        dish.available ? Icons.block : Icons.check_circle,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dish.available
                            ? S.of(context).dishManagement_deactivate
                            : S.of(context).dishManagement_activate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  child: ListTile(
                    leading:
                        dish.gallery.isNotEmpty
                            ? NetworkImageWidget(
                              imageUrl: dish.gallery.first.url,
                              width: 50,
                              height: 50,
                              borderRadius: BorderRadius.circular(8),
                              fit: BoxFit.cover,
                            )
                            : const Icon(Icons.fastfood),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(dish.name)),
                        if (!dish.available)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              S.of(context).dishManagement_inactive,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text('\$${dish.price.toStringAsFixed(2)}'),
                    trailing: SizedBox(
                      width: 50,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDelete(context, dish.id),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => _showDishForm(context, dish),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String dishId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(S.of(context).dishManagement_deleteTitle),
            content: Text(S.of(context).dishManagement_deleteContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).dishManagement_deleteCancel),
              ),
              TextButton(
                onPressed: () async {
                  final provider = context.read<SellerDishProvider>();
                  await provider.deleteDish(dishId);
                  if (context.mounted) {
                    if (provider.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.error!),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                      provider.clearError();
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(S.of(context).dishManagement_deleteConfirm),
              ),
            ],
          ),
    );
  }

  void _showDishForm(BuildContext context, Dish? dish) {
    if (dish == null) {
      Navigator.pushNamed(context, AppRouter.createDish);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DishDetailScreen(dishId: dish.id),
        ),
      );
    }
  }
}
