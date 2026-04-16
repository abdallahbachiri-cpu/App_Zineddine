import 'package:cuisinous/core/constants/app_consts.dart';

import 'package:cuisinous/widgets/network_image_widget.dart';
import 'package:cuisinous/data/models/category.dart';
import 'package:cuisinous/data/models/dish.dart';
import 'package:cuisinous/data/models/dish_ingredient.dart';
import 'package:cuisinous/data/models/rating.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/data/models/dish_allergen.dart';
import 'package:cuisinous/providers/cart_provider.dart';
import 'package:cuisinous/providers/dish_provider.dart';
import 'package:cuisinous/providers/food_store_provider.dart';
import 'package:cuisinous/providers/buyer_rating_provider.dart';
import 'package:cuisinous/screens/store_detail_screen.dart';
import 'package:cuisinous/widgets/app_bar_icon_button.dart';
import 'package:cuisinous/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cuisinous/core/enums/navigation_item.dart';
import 'package:cuisinous/providers/navigation_provider.dart';

class RecipeScreen extends StatefulWidget {
  final String recipeId;

  const RecipeScreen({super.key, required this.recipeId});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DishProvider>().clearSelection();
      context.read<BuyerRatingProvider>().clearSelectedRatings();

      context.read<DishProvider>().getDishDetails(widget.recipeId);
      context.read<BuyerRatingProvider>().fetchDishRatings(widget.recipeId);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildRoundedBackButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 16),

      child: SizedBox(
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        toolbarHeight: 70,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.transparent,

        flexibleSpace: Align(
          alignment: Alignment.bottomLeft,
          child: _buildRoundedBackButton(),
        ),
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: AppConsts.backgroundColor,
      bottomNavigationBar: const _AddToCartButton(),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Consumer<DishProvider>(
          builder: (context, dishProvider, _) {
            if (dishProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (dishProvider.error != null) {
              return Center(child: Text(dishProvider.error!));
            }

            final dish = dishProvider.selectedDish;
            if (dish == null) {
              return Center(child: Text(S.of(context).recipe_empty));
            }

            return _RecipeContent(dish: dish);
          },
        ),
      ),
    );
  }
}

class _RecipeContent extends StatefulWidget {
  final Dish dish;

  const _RecipeContent({required this.dish});

  @override
  State<_RecipeContent> createState() => _RecipeContentState();
}

class _RecipeContentState extends State<_RecipeContent> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FoodStoreProvider>().getFoodStoreById(
          widget.dish.foodStoreId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: _MainImage(
                imageUrl:
                    widget.dish.gallery.isNotEmpty
                        ? widget.dish.gallery[0].url
                        : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.dish.name,
                        softWrap: true,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),

                    const _DishRatingSummary(),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.dish.categories?.isNotEmpty ?? false) ...[
                  _Categories(categories: widget.dish.categories),
                  const SizedBox(height: 16),
                ],
                _Section(
                  title: S.of(context).recipe_description,
                  trailing: null,
                  child: Text(
                    widget.dish.description ??
                        S.of(context).recipe_noDescription,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
                if (widget.dish.gallery.length > 1) ...[
                  const SizedBox(height: 16),
                  _PhotoGallery(gallery: widget.dish.gallery),
                ],
                if (widget.dish.ingredients?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 16),
                  _Section(
                    title: S.of(context).recipe_ingredients,
                    child: _IngredientsList(
                      ingredients: widget.dish.ingredients,
                    ),
                  ),
                  if (widget.dish.allergens?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 16),
                    _Section(
                      title: S.of(context).dishDetail_allergens,
                      child: _AllergensList(allergens: widget.dish.allergens),
                    ),
                  ],
                ],
                Consumer<BuyerRatingProvider>(
                  builder: (context, ratingProvider, _) {
                    if (ratingProvider.isDishLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final ratings = ratingProvider.dishRatings;
                    if (ratings.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        const SizedBox(height: 16),
                        _Section(
                          title: S.of(context).recipe_reviews,
                          child: _ReviewsList(ratings: ratings),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                _Section(
                  title: S.of(context).recipe_vendor,
                  child: _VendorCard(dish: widget.dish),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainImage extends StatelessWidget {
  final String? imageUrl;
  const _MainImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child:
          imageUrl != null
              ? NetworkImageWidget(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                errorIcon: Icons.error,
              )
              : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 64, color: Colors.grey),
              ),
    );
  }
}

class _PhotoGallery extends StatelessWidget {
  final List<dynamic> gallery;
  const _PhotoGallery({required this.gallery});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).recipe_gallery,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: gallery.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NetworkImageWidget(
                    imageUrl: gallery[index].url,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(8),
                    errorIcon: Icons.error,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AppBarIconButton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  final List<Category>? categories;
  const _Categories({this.categories});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          categories
              ?.map(
                (category) => Chip(
                  label: Text(category.nameEn),
                  backgroundColor: const Color(0xFFDC1D27).withOpacity(0.1),
                  labelStyle: const TextStyle(color: Color(0xFFDC1D27)),
                  side: BorderSide.none,
                ),
              )
              .toList() ??
          [],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _Section({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _DishRatingSummary extends StatelessWidget {
  const _DishRatingSummary();

  @override
  Widget build(BuildContext context) {
    return Consumer<BuyerRatingProvider>(
      builder: (context, ratingProvider, _) {
        final ratings = ratingProvider.dishRatings;
        if (ratings.isEmpty) return const SizedBox.shrink();

        final avgRating =
            ratings.map((r) => r.rating).reduce((a, b) => a + b) /
            ratings.length;
        return Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              avgRating.toStringAsFixed(1),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Text(
              '(${ratings.length})',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        );
      },
    );
  }
}

class _IngredientsList extends StatelessWidget {
  final List<DishIngredient>? ingredients;
  const _IngredientsList({this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          ingredients
              ?.map(
                (ingredient) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC1D27),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ingredient.ingredientNameEn,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList() ??
          [],
    );
  }
}

class _VendorCard extends StatelessWidget {
  final Dish dish;
  const _VendorCard({required this.dish});

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodStoreProvider>(
      builder: (context, foodStoreProvider, _) {
        if (foodStoreProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (foodStoreProvider.selectedFoodStore == null) {
          return const SizedBox.shrink();
        }
        final location = dish.foodStoreAddress;
        return Card(
          color: Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: ClipOval(
                child: NetworkImageWidget(
                  imageUrl: dish.foodStoreProfileImageUrl ?? '',
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                  errorIcon: Icons.storefront,
                  errorIconSize: 25,
                ),
              ),
            ),
            title: Text(dish.foodStoreName),
            subtitle: Text(location?.street ?? ''),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => StoreDetailScreen(
                        foodStore: foodStoreProvider.selectedFoodStore!,
                      ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _AddToCartButton extends StatefulWidget {
  const _AddToCartButton();

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton> {
  bool _isItemAdded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<DishProvider, CartProvider>(
      builder: (context, dishProvider, cartProvider, _) {
        final dish = dishProvider.selectedDish;

        if (dish == null && _isItemAdded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _isItemAdded = false);
          });
        }

        final bool showGoToCart = _isItemAdded;

        final String buttonText;
        final Color backgroundColor;
        final Color textColor;
        final VoidCallback? onPressed;

        if (showGoToCart) {
          buttonText = S.of(context).goToCart;
          backgroundColor = Colors.orange.shade200;
          textColor = Colors.black;
          onPressed = () {
            context.read<NavigationProvider>().setNavigationItem(
              NavigationItem.cart,
            );
            Navigator.popUntil(context, (route) => route.isFirst);
          };
        } else {
          buttonText =
              (dishProvider.isLoading || dish == null)
                  ? S.of(context).recipe_addToCart
                  : '${S.of(context).recipe_addToCart} \$${dish.price.toStringAsFixed(2)}';

          backgroundColor = const Color(0xFF347928);
          textColor = Colors.white;

          final bool isButtonEnabled = !dishProvider.isLoading && dish != null;

          if (!dishProvider.isLoading && dish == null) {
            return const SizedBox.shrink();
          }

          onPressed =
              isButtonEnabled
                  ? () async {
                    try {
                      await cartProvider.addDishToCart(dish.id, 1);
                      if (context.mounted) {
                        setState(() {
                          _isItemAdded = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${S.of(context).recipe_addedToCart} ${dish.name}',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                  : null;
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 12),
            child: CustomButton(
              type: ButtonType.elevated,
              size: ButtonSize.large,
              shape: ButtonShape.rounded,
              isLoading: cartProvider.isProcessing && !showGoToCart,
              text: buttonText,
              onPressed: onPressed,
              backgroundColor: backgroundColor,
              textColor: textColor,
            ),
          ),
        );
      },
    );
  }
}

class _ReviewsList extends StatelessWidget {
  final List<Rating> ratings;
  const _ReviewsList({required this.ratings});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ratings.map((rating) => _ReviewCard(rating: rating)).toList(),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Rating rating;
  const _ReviewCard({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rating.buyerName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      _RatingStars(rating: rating.rating.toDouble()),
                    ],
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(rating.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            if (rating.comment != null && rating.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(rating.comment!),
            ],
          ],
        ),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  final double rating;
  const _RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }
}

class _AllergensList extends StatelessWidget {
  final List<DishAllergen>? allergens;
  const _AllergensList({this.allergens});

  @override
  Widget build(BuildContext context) {
    if (allergens == null || allergens!.isEmpty) return const SizedBox.shrink();

    return Column(
      children:
          allergens!.map((allergen) {
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                title: Text(
                  Localizations.localeOf(context).languageCode == 'fr'
                      ? allergen.allergenNameFr
                      : allergen.allergenNameEn,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle:
                    allergen.specification != null
                        ? Text(allergen.specification!)
                        : null,
              ),
            );
          }).toList(),
    );
  }
}
