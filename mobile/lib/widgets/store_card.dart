import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/data/models/food_store.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/dish_provider.dart';
import 'package:cuisinous/screens/store_detail_screen.dart';
import 'package:cuisinous/widgets/recipe_card.dart';
import 'package:cuisinous/widgets/vendor_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoreCard extends StatelessWidget {
  final FoodStore store;

  const StoreCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VendorCard(
            layoutType: VendorCardLayout.avatarWithNameAndAddressOnRight,
            vendorName: store.name,
            vendorAddress: store.address?.street,
            placeholderImage:
                store.profileImageUrl != null
                    ? AppConsts.apiBaseUrl + store.profileImageUrl!
                    : null,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => StoreDetailScreen(foodStore: store),
                  ),
                ),
          ),
          const SizedBox(height: 8),
          Consumer<DishProvider>(
            builder: (context, dishesProvider, _) {
              if (dishesProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (dishesProvider.error != null) {
                return Center(child: Text(dishesProvider.error!));
              }
              if (dishesProvider.dishes.isEmpty) {
                return Center(
                  child: Text(S.of(context).foodStoreMap_noRecipes),
                );
              }

              return SizedBox(
                height: 200,
                child: ListView.builder(
                  itemExtent: 380,
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      dishesProvider.dishes
                          .where((x) => x.foodStoreId == store.id)
                          .take(5)
                          .length,

                  itemBuilder: (context, index) {
                    final dishes =
                        dishesProvider.dishes
                            .where((x) => x.foodStoreId == store.id)
                            .toList();
                    final dish = dishes[index];
                    return RecipeCard(
                      recipe: dish,
                      rating: dish.averageRating.toDouble(),
                      isFavorite: true,
                      onFavoritePressed: () => {},
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
