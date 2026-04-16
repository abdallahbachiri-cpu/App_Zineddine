import 'package:carousel_slider/carousel_slider.dart';
import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/routes/app_router.dart';
import 'package:cuisinous/data/models/category.dart';
import 'package:cuisinous/data/models/dish.dart';
import 'package:cuisinous/data/models/media.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/data/models/allergen.dart';
import 'package:cuisinous/providers/category_provider.dart';
import 'package:cuisinous/providers/dish_provider.dart';
import 'package:cuisinous/providers/vendor_rating_provider.dart';
import 'package:cuisinous/providers/vendor_allergen_provider.dart';
import 'package:cuisinous/widgets/custom_button.dart';
import 'package:cuisinous/widgets/network_image_widget.dart';
import 'package:cuisinous/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MenuItemDetailScreen extends StatefulWidget {
  final String dishId;

  const MenuItemDetailScreen({super.key, required this.dishId});

  @override
  State<MenuItemDetailScreen> createState() => _MenuItemDetailScreenState();
}

class _MenuItemDetailScreenState extends State<MenuItemDetailScreen> {
  late SellerDishProvider _dishProvider;
  late VendorRatingProvider _ratingProvider;

  @override
  void initState() {
    super.initState();
    _dishProvider = context.read<SellerDishProvider>();
    _ratingProvider = context.read<VendorRatingProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dishProvider.getDishById(widget.dishId);
      _ratingProvider.fetchDishRatings(widget.dishId);
    });
  }

  @override
  void dispose() {
    _dishProvider.clearSelection(notify: false);
    _ratingProvider.clearSelectedRating(notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SellerDishProvider, VendorRatingProvider>(
      builder: (context, dishProvider, ratingProvider, _) {
        if (dishProvider.isLoading) {
          return const Scaffold(
            body: SafeArea(
              bottom: true,
              top: false,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (dishProvider.error != null) {
          return Scaffold(
            appBar: AppBar(backgroundColor: AppConsts.backgroundColor),
            body: SafeArea(
              bottom: true,
              top: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(dishProvider.error!),
                    ElevatedButton(
                      onPressed: () => dishProvider.getDishById(widget.dishId),
                      child: Text(S.of(context).dishManagement_retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (dishProvider.selectedDish == null) {
          return const Scaffold(
            body: SafeArea(
              bottom: true,
              top: false,
              child: Center(child: Text('Dish not found')),
            ),
          );
        }

        final Dish dish = dishProvider.selectedDish!;
        final ratings = ratingProvider.dishRatings;
        final avgRating =
            ratings.isNotEmpty
                ? ratings.map((r) => r.rating).reduce((a, b) => a + b) /
                    ratings.length
                : 0.0;

        return Scaffold(
          appBar: AppBar(
            title: Text(dish.name),
            backgroundColor: AppConsts.backgroundColor,
          ),
          backgroundColor: AppConsts.backgroundColor,
          body: SafeArea(
            bottom: true,
            top: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dish.gallery.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 250,
                          viewportFraction: 1.0,
                          enableInfiniteScroll: false,
                        ),
                        items:
                            dish.gallery.map((Media media) {
                              return NetworkImageWidget(
                                imageUrl: media.url,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(15),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                dish.name,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppConsts.primaryColor,
                                ),
                              ),
                            ),
                            if (avgRating > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(200),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      avgRating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${ratings.length})',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    dish.available
                                        ? Colors.green
                                        : Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    dish.available
                                        ? Icons.check_circle
                                        : Icons.block,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dish.available
                                        ? S.of(context).dishDetailAvailable
                                        : S.of(context).dishDetailUnavailable,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dish.foodStoreName,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: AppConsts.secondaryTextColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (dish.description != null)
                          Text(
                            dish.description!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context).dishDetail_categories,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConsts.primaryColor,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ManageDishCategoriesScreen(
                                          dishId: dish.id,
                                          isEditing: true,
                                          initialCategories:
                                              dish.categories ?? [],
                                          allCategories: [],
                                        ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.add, size: 24),
                            ),
                          ],
                        ),
                        if (dish.categories != null &&
                            dish.categories!.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                dish.categories!
                                    .map(
                                      (cat) => Chip(
                                        label: Text(cat.nameEn),
                                        backgroundColor: const Color(
                                          0xFFDC1D27,
                                        ).withOpacity(0.1),
                                        labelStyle: const TextStyle(
                                          color: Color(0xFFDC1D27),
                                        ),
                                        side: BorderSide.none,
                                      ),
                                    )
                                    .toList(),
                          ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context).dishDetail_ingredients,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConsts.primaryColor,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.manageDishIngredients,
                                  arguments: {
                                    'dishId': dish.id,
                                    'isEditing': false,
                                  },
                                );
                              },
                              icon: Icon(Icons.add, size: 24),
                            ),
                          ],
                        ),
                        if (dish.ingredients != null &&
                            dish.ingredients!.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                dish.ingredients!
                                    .map(
                                      (ing) => Chip(
                                        label: Text(ing.ingredientNameEn),
                                        backgroundColor: const Color(
                                          0xFF347928,
                                        ).withOpacity(0.1),
                                        labelStyle: const TextStyle(
                                          color: Color(0xFF347928),
                                        ),
                                        side: BorderSide.none,
                                      ),
                                    )
                                    .toList(),
                          ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context).dishDetail_allergens,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConsts.primaryColor,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ManageDishAllergensScreen(
                                          dishId: dish.id,
                                        ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.add, size: 24),
                            ),
                          ],
                        ),
                        if (dish.allergens != null &&
                            dish.allergens!.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dish.allergens!.length,
                            itemBuilder: (context, index) {
                              final allergen = dish.allergens![index];
                              return Card(
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 8.0),
                                child: ListTile(
                                  title: Text(
                                    Localizations.localeOf(
                                              context,
                                            ).languageCode ==
                                            'fr'
                                        ? allergen.allergenNameFr
                                        : allergen.allergenNameEn,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle:
                                      allergen.specification != null
                                          ? Text(allergen.specification!)
                                          : null,
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      context
                                          .read<VendorAllergenProvider>()
                                          .removeAllergenFromDish(
                                            dish.id,
                                            allergen.allergenId,
                                          );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        if (ratings.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            S.of(context).dishDetail_reviews,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppConsts.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ratings.length,
                            itemBuilder: (context, index) {
                              final rating = ratings[index];
                              return Card(
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 12.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  rating.buyerName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Row(
                                                  children: List.generate(5, (
                                                    index,
                                                  ) {
                                                    return Icon(
                                                      index < rating.rating
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      color: Colors.amber,
                                                      size: 20,
                                                    );
                                                  }),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            DateFormat(
                                              'MMM dd, yyyy',
                                            ).format(rating.createdAt),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (rating.comment != null &&
                                          rating.comment!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(rating.comment!),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              S.of(context).dishDetail_basePrice,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '\$${dish.price.toStringAsFixed(2)}',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Text(
                              S.of(context).dishDetail_totalPrice,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontSize: 24,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '\$${(dish.price + (dish.ingredients?.fold(0.0, (sum, item) => sum! + item.price) ?? 0)).toStringAsFixed(2)}',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      type: ButtonType.iconText,
                      size: ButtonSize.large,
                      shape: ButtonShape.rounded,
                      borderRadius: 10,
                      backgroundColor:
                          dish.available ? Colors.orange : Colors.green,
                      textColor: Colors.white,
                      padding: EdgeInsetsDirectional.symmetric(vertical: 10),
                      onPressed: () async {
                        if (dish.available) {
                          await dishProvider.deactivateDish(dish.id);
                        } else {
                          await dishProvider.activateDish(dish.id);
                        }

                        if (context.mounted) {
                          if (dishProvider.error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(dishProvider.error!),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            );
                            dishProvider.clearError();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  dish.available
                                      ? S
                                          .of(context)
                                          .dishManagement_dishDeactivated
                                      : S
                                          .of(context)
                                          .dishManagement_dishActivated,
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                      text:
                          dish.available
                              ? S.of(context).dishManagement_deactivate
                              : S.of(context).dishManagement_activate,
                      icon: dish.available ? Icons.block : Icons.check_circle,
                      iconColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      type: ButtonType.iconText,
                      size: ButtonSize.large,
                      shape: ButtonShape.rounded,
                      borderRadius: 10,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      padding: EdgeInsetsDirectional.symmetric(vertical: 10),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.editDish,
                          arguments: dish.id,
                        );
                      },
                      text: S.of(context).dishDetail_editButton,
                      icon: Icons.edit,
                      iconColor: AppConsts.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ManageDishCategoriesScreen extends StatefulWidget {
  final String dishId;
  final bool isEditing;
  final List<Category> initialCategories;
  final List<Category> allCategories;

  const ManageDishCategoriesScreen({
    super.key,
    required this.dishId,
    required this.isEditing,
    this.initialCategories = const [],
    this.allCategories = const [],
  });

  @override
  State<ManageDishCategoriesScreen> createState() =>
      _ManageDishCategoriesScreenState();
}

class _ManageDishCategoriesScreenState
    extends State<ManageDishCategoriesScreen> {
  late List<Category> _selectedCategories;

  @override
  void initState() {
    super.initState();

    _selectedCategories = List<Category>.from(widget.initialCategories);
    if (widget.allCategories.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CategoryProvider>().fetchCategories();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final availableCategories =
        widget.allCategories.isNotEmpty
            ? widget.allCategories
            : provider.categories;

    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConsts.backgroundColor,
        title: Text(
          widget.isEditing
              ? S.of(context).manageCategoriesEditTitle
              : S.of(context).manageCategoriesTitle,
        ),
        actions: widget.isEditing ? [_buildEditModeActions()] : null,
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: _buildBody(availableCategories, provider),
      ),
      floatingActionButton: _buildFAB(availableCategories),
    );
  }

  Widget _buildBody(
    List<Category> availableCategories,
    CategoryProvider provider,
  ) {
    if (_selectedCategories.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      itemCount: _selectedCategories.length,
      itemBuilder: (context, idx) {
        final cat = _selectedCategories[idx];
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: ListTile(
            title: Text(
              cat.nameEn,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(cat.type),
            trailing:
                widget.isEditing
                    ? IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () {
                        setState(() => _selectedCategories.removeAt(idx));
                        provider.removeDishCategory(widget.dishId, cat.id);
                        context.read<SellerDishProvider>().updateSelectedDish(
                          _selectedCategories.toList(),
                        );
                      },
                    )
                    : null,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.isEditing
                ? S.of(context).manageCategoriesEmptyEditing
                : S.of(context).manageCategoriesEmptyDefault,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.add, color: Colors.black),
            label: Text(
              S.of(context).manageCategoriesAddButton,
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () => _showCategoryDialog(),
          ),
          if (widget.isEditing) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              child: Text(
                S.of(context).manageCategoriesFinishEditing,
                style: TextStyle(color: AppConsts.secondaryAccentColor),
              ),
              onPressed:
                  () => {
                    context.read<SellerDishProvider>().updateSelectedDish(
                      _selectedCategories.toList(),
                    ),
                    Navigator.pop(context),
                  },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFAB(List<Category> availableCategories) {
    return FloatingActionButton(
      onPressed: () => _showCategoryDialog(),
      backgroundColor: Colors.white,
      foregroundColor: AppConsts.primaryColor,
      child: const Icon(Icons.add),
    );
  }

  Widget _buildEditModeActions() {
    return PopupMenuButton<String>(
      itemBuilder:
          (_) => [
            PopupMenuItem(
              value: 'save',
              child: Text(S.of(context).manageCategoriesSaveChanges),
            ),
            PopupMenuItem(
              value: 'cancel',
              child: Text(S.of(context).manageCategoriesDiscardChanges),
            ),
          ],
      onSelected: (v) {
        if (v == 'save') Navigator.pop(context, _selectedCategories);
        if (v == 'cancel') Navigator.pop(context);
      },
    );
  }

  void _showCategoryDialog() {
    final provider = context.read<CategoryProvider>();
    final existingIds = _selectedCategories.map((c) => c.id).toSet();
    final list =
        widget.allCategories.isNotEmpty
            ? widget.allCategories
            : provider.categories;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(S.of(context).manageCategoriesSelectTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 300,
                  width: double.maxFinite,
                  child: ListView(
                    children:
                        list
                            .where((cat) => !existingIds.contains(cat.id))
                            .map(
                              (cat) => ListTile(
                                title: Text(cat.nameEn),
                                subtitle: Text(cat.type),
                                onTap: () {
                                  setState(() => _selectedCategories.add(cat));
                                  provider.addDishCategory(
                                    widget.dishId,
                                    cat.id,
                                  );
                                  context
                                      .read<SellerDishProvider>()
                                      .updateSelectedDish(
                                        _selectedCategories.toList(),
                                      );
                                  Navigator.pop(context);
                                },
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  S.of(context).manageCategoriesCancel,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}

class ManageDishAllergensScreen extends StatefulWidget {
  final String dishId;

  const ManageDishAllergensScreen({super.key, required this.dishId});

  @override
  State<ManageDishAllergensScreen> createState() =>
      _ManageDishAllergensScreenState();
}

class _ManageDishAllergensScreenState extends State<ManageDishAllergensScreen> {
  final _specificationController = TextEditingController();
  Allergen? _selectedAllergen;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorAllergenProvider>().getAllergens();
    });
  }

  @override
  void dispose() {
    _specificationController.dispose();
    super.dispose();
  }

  Future<void> _addAllergen() async {
    if (_selectedAllergen == null) return;
    if (_selectedAllergen!.requiresSpecification &&
        _specificationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).validationRequired),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final provider = context.read<VendorAllergenProvider>();
    await provider.addAllergenToDish(
      widget.dishId,
      _selectedAllergen!.id,
      specification:
          _specificationController.text.isNotEmpty
              ? _specificationController.text
              : null,
    );

    if (mounted) {
      if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConsts.backgroundColor,
        title: Text(S.of(context).manageAllergensTitle),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Consumer<VendorAllergenProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.allergens.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final dishProvider = context.read<SellerDishProvider>();
                    final currentAllergenIds =
                        dishProvider.selectedDish?.allergens
                            ?.map((a) => a.allergenId)
                            .toSet() ??
                        {};

                    final availableAllergens =
                        provider.allergens
                            .where((a) => !currentAllergenIds.contains(a.id))
                            .toList();

                    if (availableAllergens.isEmpty) {
                      return Center(
                        child: Text(S.of(context).manageAllergensEmpty),
                      );
                    }

                    Allergen? effectiveSelectedValue = _selectedAllergen;
                    if (effectiveSelectedValue != null &&
                        !availableAllergens.any(
                          (a) => a.id == effectiveSelectedValue!.id,
                        )) {
                      effectiveSelectedValue = null;
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Autocomplete<Allergen>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return availableAllergens;
                            }
                            return availableAllergens.where((Allergen option) {
                              final query = textEditingValue.text.toLowerCase();
                              return option.nameFr.toLowerCase().contains(
                                    query,
                                  ) ||
                                  option.nameEn.toLowerCase().contains(query);
                            });
                          },
                          displayStringForOption:
                              (Allergen option) =>
                                  Localizations.localeOf(
                                            context,
                                          ).languageCode ==
                                          'fr'
                                      ? option.nameFr
                                      : option.nameEn,
                          onSelected: (Allergen selection) {
                            setState(() {
                              _selectedAllergen = selection;
                              _specificationController.clear();
                            });
                          },
                          fieldViewBuilder: (
                            context,
                            textEditingController,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            return ListenableBuilder(
                              listenable: focusNode,
                              builder: (context, child) {
                                return CustomInputField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  labelText:
                                      S.of(context).manageAllergensSelect,
                                  hintText: S.of(context).manageAllergensSelect,
                                  radius: 16,
                                  suffixIcon:
                                      focusNode.hasFocus
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                  onSuffixTap: () {
                                    if (focusNode.hasFocus) {
                                      focusNode.unfocus();
                                    } else {
                                      focusNode.requestFocus();
                                    }
                                  },
                                  onChanged: (value) {
                                    if (_selectedAllergen != null) {
                                      setState(() {
                                        _selectedAllergen = null;
                                      });
                                    }
                                  },
                                );
                              },
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Material(
                                  elevation: 4.0,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: constraints.maxWidth,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    constraints: const BoxConstraints(
                                      maxHeight: 200,
                                    ),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder: (
                                        BuildContext context,
                                        int index,
                                      ) {
                                        final Allergen option = options
                                            .elementAt(index);
                                        return ListTile(
                                          title: Text(
                                            Localizations.localeOf(
                                                      context,
                                                    ).languageCode ==
                                                    'fr'
                                                ? option.nameFr
                                                : option.nameEn,
                                          ),
                                          onTap: () => onSelected(option),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                if (_selectedAllergen != null) ...[
                  const SizedBox(height: 16),
                  if (_selectedAllergen!.requiresSpecification) ...[
                    CustomInputField(
                      controller: _specificationController,
                      labelText: S.of(context).manageAllergensSpecification,
                      hintText: S.of(context).manageAllergensSpecificationHint,
                      radius: 16,
                      validator:
                          (value) =>
                              value?.isEmpty ?? true
                                  ? S.of(context).validationRequired
                                  : null,
                    ),
                  ] else ...[
                    CustomInputField(
                      controller: _specificationController,
                      labelText:
                          S.of(context).manageAllergensSpecificationOptional,
                      hintText: S.of(context).manageAllergensSpecificationHint,
                      radius: 16,
                    ),
                  ],
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: Consumer<VendorAllergenProvider>(
                    builder:
                        (context, provider, _) => CustomButton(
                          type: ButtonType.elevated,
                          size: ButtonSize.large,
                          shape: ButtonShape.rounded,
                          borderRadius: 10,
                          backgroundColor: AppConsts.secondaryAccentColor,
                          textColor: Colors.white,
                          text: S.of(context).addButton,
                          isLoading: provider.isLoading,
                          onPressed: _addAllergen,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
