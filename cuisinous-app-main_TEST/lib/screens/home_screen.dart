import 'dart:async';
import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/routes/app_router.dart';
import 'package:cuisinous/data/models/food_store.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/providers/buyer_order_provider.dart';
import 'package:cuisinous/providers/cart_provider.dart';
import 'package:cuisinous/providers/category_provider.dart';
import 'package:cuisinous/providers/dish_provider.dart';
import 'package:cuisinous/providers/food_store_provider.dart';
import 'package:cuisinous/screens/food_store_detail_screen.dart';
import 'package:cuisinous/widgets/custom_button.dart';
import 'package:cuisinous/widgets/custom_header.dart';
import 'package:cuisinous/widgets/dish_filter_dialog.dart';
import 'package:cuisinous/widgets/recipe_card.dart';
import 'package:cuisinous/widgets/section_header.dart';
import 'package:cuisinous/widgets/vendor_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategoryName;
  String? _selectedCategoryId;

  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final foodStoreProvider = Provider.of<FoodStoreProvider>(
      context,
      listen: false,
    );
    final dishesProvider = Provider.of<DishProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    foodStoreProvider.fetchFoodStores(hasDishes: true);
    dishesProvider.searchDishes();
    categoryProvider.fetchCategories();

    Provider.of<CartProvider>(context, listen: false).fetchCart();
    Provider.of<BuyerOrderProvider>(context, listen: false).fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 240),
                _buildCategoriesSection(),
                const SizedBox(height: 24),
                if (_selectedCategoryName == null) ...[
                  _buildPopularRecipesSection(),
                  const SizedBox(height: 24),
                  _buildPopularChefsSection(),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
          _buildHeaderSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;
          if (user == null) {
            return const SizedBox.shrink();
          }
          return Consumer<DishProvider>(
            builder: (context, dishProvider, _) {
              return CustomHeader(
                username: "${user.firstName} ${user.lastName}",
                address: "",
                profileImageUrl: user.profileImageUrl,
                onNotificationPressed: () => _handleNotificationPress(),
                onSearchChanged: _handleSearch,
                filterOptions: const ['Option 1', 'Option 2', 'Option 3'],
                onFilterSelected: _handleFilterSelection,
                onFilterPressed: () => _showFilterDialog(context),
                hasActiveFilters: dishProvider.hasActiveFilters,
                headerBackgroundColor: AppConsts.backgroundColor,
                textColor: Colors.black,
                iconColor: Colors.black,
                searchBarColor: Colors.white.withAlpha(200),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      children: [
        SectionHeader(
          title: S.of(context).home_categories,
          buttonText: '',
          onPressed: () {},
          textColor: Colors.black,
          buttonTextColor: const Color(0xFFDC1D27),
        ),
        SizedBox(
          height: 40,
          width: double.infinity,
          child: Consumer<CategoryProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.categoriesError != null) {
                return Center(child: Text(provider.categoriesError!));
              }
              final categories = provider.categories;
              if (categories.isEmpty) {
                return Center(child: Text(S.of(context).home_noCategories));
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CustomButton(
                    type: ButtonType.elevated,
                    size: ButtonSize.medium,
                    shape: ButtonShape.rounded,
                    text:
                        Localizations.localeOf(context).languageCode == 'fr'
                            ? category.nameFr
                            : category.nameEn,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DishListScreen(
                                categoryId: category.id,
                                categoryName:
                                    Localizations.localeOf(
                                              context,
                                            ).languageCode ==
                                            'fr'
                                        ? category.nameFr
                                        : category.nameEn,
                              ),
                        ),
                      ).then((_) {
                        if (context.mounted) {
                          Provider.of<DishProvider>(
                            context,
                            listen: false,
                          ).clearFilters();
                          Provider.of<DishProvider>(
                            context,
                            listen: false,
                          ).searchDishes();
                        }
                      });
                    },
                    backgroundColor: const Color(0xFFDC1D27),
                    textColor: Colors.white,
                  );
                },
              );
            },
          ),
        ),
        if (_selectedCategoryName != null) ...[
          SectionHeader(
            title:
                '$_selectedCategoryName ${S.of(context).home_selectedRecipes}',
            buttonText: '',
            onPressed: () {},
            textColor: Colors.black,
            buttonTextColor: const Color(0xFFDC1D27),
          ),
          Consumer<DishProvider>(
            builder: (context, dishesProvider, _) {
              dishesProvider.searchDishes(
                categories:
                    _selectedCategoryId != null ? [_selectedCategoryId!] : null,
              );

              if (dishesProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (dishesProvider.error != null) {
                return Center(child: Text(dishesProvider.error!));
              }
              return SizedBox(
                height: 430,
                child: ListView.builder(
                  itemExtent: 250,
                  scrollDirection: Axis.vertical,
                  itemCount: dishesProvider.dishes.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final dish = dishesProvider.dishes[index];
                    return RecipeCard(
                      recipe: dish,
                      rating: dish.averageRating.toDouble(),
                      isFavorite: true,
                      onFavoritePressed: () => _handleFavorite(dish.id),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPopularRecipesSection() {
    return Column(
      children: [
        SectionHeader(
          title: S.of(context).home_popularRecipes,
          buttonText: S.of(context).home_seeAll,
          onPressed: () => _navigateToRecipesScreen(),
          textColor: Colors.black,
          buttonTextColor: const Color(0xFFDC1D27),
        ),
        Consumer<DishProvider>(
          builder: (context, dishesProvider, _) {
            if (dishesProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (dishesProvider.error != null) {
              return Center(child: Text(dishesProvider.error!));
            }
            if (dishesProvider.dishes.isEmpty) {
              return Center(child: Text(S.of(context).home_noRecipes));
            }
            return SizedBox(
              height: 200,
              child: ListView.builder(
                itemExtent: 340,
                scrollDirection: Axis.horizontal,
                itemCount: dishesProvider.dishes.take(5).length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final dish = dishesProvider.dishes[index];
                  return RecipeCard(
                    recipe: dish,
                    rating: dish.averageRating.toDouble(),
                    isFavorite: true,
                    onFavoritePressed: () => _handleFavorite(dish.id),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPopularChefsSection() {
    return Column(
      children: [
        SectionHeader(
          title: S.of(context).home_popularChefs,
          buttonText: '',
          onPressed: () => {},
          textColor: Colors.black,
          buttonTextColor: const Color(0xFFDC1D27),
        ),
        Consumer<FoodStoreProvider>(
          builder: (context, foodStoreProvider, _) {
            if (foodStoreProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (foodStoreProvider.error != null) {
              return Center(child: Text(foodStoreProvider.error!));
            }

            return SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: foodStoreProvider.foodStores.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final store = foodStoreProvider.foodStores[index];
                  return VendorCard(
                    vendorName: store.name,
                    avatarRadius: 35,
                    placeholderImage:
                        store.profileImageUrl != null
                            ? store.profileImageUrl!
                            : null,
                    onTap: () => _navigateToVendorProfile(store),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  String removeLeadingSlash(String input) {
    if (input.startsWith('/')) {
      return input.substring(1);
    }
    return input;
  }

  void _handleNotificationPress() {
    Navigator.of(context).pushNamed(AppRouter.notificationSeller);
  }

  void _handleSearch(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    if (query.isNotEmpty && query.length < 3) return;
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      Provider.of<DishProvider>(
        context,
        listen: false,
      ).searchDishes(search: query);
    });
  }

  void _handleFilterSelection(String filter) {}

  void _navigateToRecipesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DishListScreen()),
    );
  }

  void _navigateToVendorProfile(FoodStore store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodStoreDetailScreen(foodStore: store),
      ),
    );
  }

  void _handleFavorite(String dishId) {}

  void _showFilterDialog(BuildContext context) {
    final provider = context.read<DishProvider>();

    showDialog(
      context: context,
      builder:
          (context) => DishFilterDialog(
            initialMinPrice: provider.minPrice,
            initialMaxPrice: provider.maxPrice,
            initialCategories: provider.categories,

            initialSortBy: provider.sortBy,
            initialSortOrder: provider.sortOrder,
            onReset: () {
              provider.clearFilters();
            },
            onApply: ({
              search,
              minPrice,
              maxPrice,
              categories,
              ingredients,
              sortBy,
              sortOrder,
            }) {
              provider.setFilters(
                minPrice: minPrice,
                maxPrice: maxPrice,
                categories: categories,
                ingredients: ingredients,
                sortBy: sortBy,
                sortOrder: sortOrder,
              );
            },
          ),
    );
  }
}

class DishListScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const DishListScreen({super.key, this.categoryId, this.categoryName});

  @override
  State<DishListScreen> createState() => _DishListScreenState();
}

class _DishListScreenState extends State<DishListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dishProvider = context.read<DishProvider>();
      dishProvider.clearSearch();
      dishProvider.searchDishes(
        categories: widget.categoryId != null ? [widget.categoryId!] : null,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<DishProvider>().loadMoreDishes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConsts.backgroundColor,
        title: Text(widget.categoryName ?? S.of(context).home_allRecipes),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: _showFilterDialog,
                icon: Icon(Icons.filter_list),
              ),
              Consumer<DishProvider>(
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
        ],
      ),
      body: Consumer<DishProvider>(
        builder: (context, dishesProvider, _) {
          if (dishesProvider.isLoading && dishesProvider.dishes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dishesProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dishesProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => dishesProvider.searchDishes(
                          categories:
                              widget.categoryId != null
                                  ? [widget.categoryId!]
                                  : null,
                        ),
                    child: Text(S.of(context).dishList_retry),
                  ),
                ],
              ),
            );
          }

          if (dishesProvider.dishes.isEmpty) {
            return Center(child: Text(S.of(context).dishList_noRecipes));
          }

          return RefreshIndicator(
            onRefresh:
                () async => dishesProvider.searchDishes(
                  categories:
                      widget.categoryId != null ? [widget.categoryId!] : null,
                ),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  dishesProvider.dishes.length +
                  (dishesProvider.canLoadMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= dishesProvider.dishes.length) {
                  return dishesProvider.isLoading
                      ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const SizedBox.shrink();
                }

                final dish = dishesProvider.dishes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: RecipeCard(
                    recipe: dish,
                    rating: dish.averageRating.toDouble(),
                    isFavorite: true,
                    onFavoritePressed: () => {},
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    final provider = context.read<DishProvider>();

    showDialog(
      context: context,
      builder:
          (context) => DishFilterDialog(
            showSearch: true,
            initialSearch: provider.search,
            initialMinPrice: provider.minPrice,
            initialMaxPrice: provider.maxPrice,
            initialCategories: provider.categories,
            initialSortBy: provider.sortBy,
            initialSortOrder: provider.sortOrder,
            onReset: () {
              provider.clearFilters();

              provider.searchDishes(
                categories:
                    widget.categoryId != null ? [widget.categoryId!] : null,
              );
            },
            onApply: ({
              search,
              minPrice,
              maxPrice,
              categories,
              ingredients,
              sortBy,
              sortOrder,
            }) {
              provider.setFilters(
                search: search,
                minPrice: minPrice,
                maxPrice: maxPrice,
                categories:
                    categories ??
                    (widget.categoryId != null ? [widget.categoryId!] : null),
                ingredients: ingredients,
                sortBy: sortBy,
                sortOrder: sortOrder,
              );
            },
          ),
    );
  }
}
