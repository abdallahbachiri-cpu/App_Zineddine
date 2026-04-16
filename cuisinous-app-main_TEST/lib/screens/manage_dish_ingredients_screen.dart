import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/data/models/dish_ingredient.dart';
import 'package:cuisinous/data/models/ingredient.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/dish_ingredients_provider.dart';
import 'package:cuisinous/providers/dish_provider.dart';
import 'package:cuisinous/providers/ingredients_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageDishIngredientsScreen extends StatefulWidget {
  final String dishId;
  final bool isEditing;

  const ManageDishIngredientsScreen({
    super.key,
    required this.dishId,
    required this.isEditing,
  });

  @override
  State<ManageDishIngredientsScreen> createState() =>
      _ManageDishIngredientsScreenState();
}

class _ManageDishIngredientsScreenState
    extends State<ManageDishIngredientsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeData() {
    context.read<DishIngredientsProvider>().fetchDishIngredients(widget.dishId);
    context.read<IngredientsProvider>().fetchIngredients(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: true,
        top: false,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppConsts.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppConsts.primaryColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.isEditing
            ? S.of(context).manageDishIngredients_editTitle
            : S.of(context).manageDishIngredients_title,
        style: const TextStyle(
          color: AppConsts.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer2<DishIngredientsProvider, IngredientsProvider>(
      builder: (context, dishIngredientsProvider, ingredientsProvider, _) {
        if (dishIngredientsProvider.isDishLoading) {
          return const _LoadingView();
        }

        if (dishIngredientsProvider.dishError != null) {
          return _ErrorView(
            error: dishIngredientsProvider.dishError!,
            onRetry: () => _initializeData(),
          );
        }

        return Column(
          children: [
            _buildDishInfo(),
            if (dishIngredientsProvider.dishIngredients.isEmpty)
              Expanded(
                child: _EmptyStateView(
                  isEditing: widget.isEditing,
                  onLinkIngredients: _showIngredientManagementDialog,
                  onManageGlobal: _showGlobalIngredientManagement,
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    _buildHeader(dishIngredientsProvider),
                    Expanded(
                      child: _buildIngredientsList(dishIngredientsProvider),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(DishIngredientsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).manageDishIngredients_ingredientsTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppConsts.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.dishIngredients.length} ${S.of(context).manageDishIngredients_linkedIngredients} • ${S.of(context).manageDishIngredients_total}: \$${_calculateTotalValue(provider.dishIngredients).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConsts.secondaryAccentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildSortButton(),
            ],
          ),
          const SizedBox(height: 12),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 12.0,

      runSpacing: 12.0,

      alignment: WrapAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _showIngredientManagementDialog,
          icon: const Icon(Icons.link),
          label: Text(S.of(context).manageDishIngredients_linkIngredients),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConsts.secondaryAccentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _showGlobalIngredientManagement,
          icon: const Icon(Icons.manage_accounts),
          label: Text(S.of(context).manageDishIngredients_manageIngredients),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppConsts.secondaryAccentColor,
            side: const BorderSide(color: AppConsts.secondaryAccentColor),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSortButton() {
    return Consumer<DishIngredientsProvider>(
      builder: (context, provider, _) {
        return PopupMenuButton<String>(
          icon: const Icon(Icons.sort, color: AppConsts.primaryColor),
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'name',
                  child: Row(
                    children: [
                      const Icon(Icons.sort_by_alpha),
                      const SizedBox(width: 8),
                      Text(S.of(context).manageDishIngredients_sortByName),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'price',
                  child: Row(
                    children: [
                      const Icon(Icons.attach_money),
                      const SizedBox(width: 8),
                      Text(S.of(context).manageDishIngredients_sortByPrice),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'type',
                  child: Row(
                    children: [
                      const Icon(Icons.category),
                      const SizedBox(width: 8),
                      Text(S.of(context).manageDishIngredients_sortByType),
                    ],
                  ),
                ),
              ],
          onSelected: (value) => _sortIngredients(provider, value),
        );
      },
    );
  }

  void _sortIngredients(DishIngredientsProvider provider, String sortBy) {
    final ingredients = List<DishIngredient>.from(provider.dishIngredients);

    switch (sortBy) {
      case 'name':
        ingredients.sort(
          (a, b) => a.ingredientNameEn.toLowerCase().compareTo(
            b.ingredientNameEn.toLowerCase(),
          ),
        );
        break;
      case 'price':
        ingredients.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'type':
        ingredients.sort((a, b) {
          if (a.isSupplement == b.isSupplement) {
            return a.ingredientNameEn.toLowerCase().compareTo(
              b.ingredientNameEn.toLowerCase(),
            );
          }
          return a.isSupplement ? -1 : 1;
        });
        break;
    }

    provider.updateSortedIngredients(ingredients);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          S
              .of(context)
              .manageDishIngredients_sortedBy(
                sortBy.replaceFirst(sortBy[0], sortBy[0].toUpperCase()),
              ),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: AppConsts.secondaryAccentColor,
      ),
    );
  }

  Widget _buildIngredientsList(DishIngredientsProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.dishIngredients.length,
      itemBuilder: (context, index) {
        final ingredient = provider.dishIngredients[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    ingredient.isSupplement
                        ? AppConsts.accentColor.withAlpha(25)
                        : AppConsts.secondaryAccentColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                ingredient.isSupplement ? Icons.add_circle : Icons.restaurant,
                color:
                    ingredient.isSupplement
                        ? AppConsts.accentColor
                        : AppConsts.secondaryAccentColor,
                size: 20,
              ),
            ),
            title: Text(
              ingredient.ingredientNameEn,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.isSupplement
                      ? 'Price: \$${ingredient.price.toStringAsFixed(2)}'
                      : 'Free',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color:
                        ingredient.isSupplement
                            ? null
                            : AppConsts.secondaryAccentColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        ingredient.isSupplement
                            ? AppConsts.accentColor.withAlpha(25)
                            : AppConsts.secondaryAccentColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ingredient.isSupplement ? 'Supplement' : 'Standard',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          ingredient.isSupplement
                              ? AppConsts.accentColor
                              : AppConsts.secondaryAccentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // IconButton(
                //   icon: const Icon(
                //     Icons.edit,
                //     color: AppConsts.secondaryAccentColor,
                //   ),
                //   onPressed: () => _showEditDialogForExisting(ingredient),
                // ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppConsts.accentColor),
                  onPressed: () => _deleteIngredient(ingredient),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showIngredientManagementDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _IngredientManagementSheet(dishId: widget.dishId),
    );
  }

  void _showGlobalIngredientManagement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _GlobalIngredientManagementSheet(),
    );
  }

  void _showEditDialogForExisting(DishIngredient existingIngredient) {
    showDialog(
      context: context,
      builder:
          (context) => _EditIngredientDialog(
            dishId: widget.dishId,
            existingIngredient: existingIngredient,
          ),
    );
  }

  Future<void> _deleteIngredient(DishIngredient di) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(S.of(context).manageDishIngredients_deleteTitle),
            content: Text(
              'Are you sure you want to remove "${di.ingredientNameEn}" from this dish?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(S.of(context).manageDishIngredients_deleteCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppConsts.accentColor,
                ),
                child: Text(S.of(context).manageDishIngredients_deleteConfirm),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final provider = context.read<DishIngredientsProvider>();
      await provider.removeDishIngredient(
        dishId: widget.dishId,
        ingredientId: di.ingredientId,
      );

      if (provider.dishError == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context).manageDishIngredients_ingredientRemovedSuccessfully,
            ),
            backgroundColor: AppConsts.secondaryAccentColor,
          ),
        );
      }
    }
  }

  Widget _buildDishInfo() {
    return Consumer<DishProvider>(
      builder: (context, dishProvider, _) {
        final dish = dishProvider.selectedDish;
        if (dish == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
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
                          dish.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppConsts.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateTotalValue(List<DishIngredient> ingredients) {
    return ingredients.fold(0.0, (sum, ingredient) => sum + ingredient.price);
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppConsts.accentColor),
          ),
          SizedBox(height: 16),
          Text(
            S.of(context).manageDishIngredients_loadingIngredients,
            style: TextStyle(color: AppConsts.primaryColor, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppConsts.accentColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppConsts.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppConsts.primaryColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(S.of(context).manageDishIngredients_retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConsts.accentColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onLinkIngredients;
  final VoidCallback onManageGlobal;

  const _EmptyStateView({
    required this.isEditing,
    required this.onLinkIngredients,
    required this.onManageGlobal,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppConsts.accentColor.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 64,
                color: AppConsts.accentColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isEditing
                  ? S.of(context).manageDishIngredients_emptyEditing
                  : S.of(context).manageDishIngredients_emptyDefault,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppConsts.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).manageDishIngredients_linkIngredientsHint,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12.0,

              runSpacing: 12.0,

              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onLinkIngredients,
                  icon: const Icon(Icons.link),
                  label: Text(
                    S.of(context).manageDishIngredients_linkIngredients,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConsts.secondaryAccentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onManageGlobal,
                  icon: const Icon(Icons.manage_accounts),
                  label: Text(
                    S.of(context).manageDishIngredients_manageIngredients,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConsts.secondaryAccentColor,
                    side: const BorderSide(
                      color: AppConsts.secondaryAccentColor,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (isEditing) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).manageDishIngredients_finishEditing),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IngredientManagementSheet extends StatefulWidget {
  final String dishId;

  const _IngredientManagementSheet({required this.dishId});

  @override
  State<_IngredientManagementSheet> createState() =>
      __IngredientManagementSheetState();
}

class __IngredientManagementSheetState
    extends State<_IngredientManagementSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final bool _showCreateForm = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              _buildHandle(),
              _buildHeader(),
              _buildSearchBar(),
              if (_showCreateForm) _buildCreateForm(),
              Expanded(child: _buildIngredientsList()),
            ],
          ),

          Consumer<IngredientsProvider>(
            builder: (context, provider, child) {
              if (provider.error != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.error!),
                      backgroundColor: AppConsts.accentColor,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                  provider.clearError();
                });
              }
              return const SizedBox.shrink();
            },
          ),

          Consumer<DishIngredientsProvider>(
            builder: (context, provider, child) {
              if (provider.dishError != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.dishError!),
                      backgroundColor: AppConsts.accentColor,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                  provider.clearDishError();
                });
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            S.of(context).manageDishIngredients_linkIngredientsToDish,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppConsts.primaryColor,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: S.of(context).manageDishIngredients_searchIngredientsToLink,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return _CreateIngredientDialog();
  }

  Widget _buildIngredientsList() {
    return Consumer2<IngredientsProvider, DishIngredientsProvider>(
      builder: (context, ingredientsProvider, dishIngredientsProvider, _) {
        if (ingredientsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final linkedIds =
            dishIngredientsProvider.dishIngredients
                .map((di) => di.ingredientId)
                .toSet();

        final availableIngredients =
            ingredientsProvider.ingredients
                .where(
                  (ing) =>
                      ing.nameEn.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) &&
                      !linkedIds.contains(ing.id),
                )
                .toList();

        if (availableIngredients.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  S.of(context).manageDishIngredients_searchEmpty,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: availableIngredients.length,
          itemBuilder: (context, index) {
            final ingredient = availableIngredients[index];
            return _AvailableIngredientTile(
              ingredient: ingredient,
              onSelect: () => _selectIngredient(ingredient),
            );
          },
        );
      },
    );
  }

  void _selectIngredient(Ingredient ingredient) async {
    final provider = context.read<DishIngredientsProvider>();

    // Default values for standard ingredients
    final price = 0.0;

    await provider.addDishIngredient(
      dishId: widget.dishId,
      ingredientId: ingredient.id,
      price: price,
      isSupplement: false,
    );

    if (provider.dishError == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).manageDishIngredients_ingredientAddedSuccessfully,
          ),
          backgroundColor: AppConsts.secondaryAccentColor,
        ),
      );
    }
  }
}

class _GlobalIngredientManagementSheet extends StatefulWidget {
  const _GlobalIngredientManagementSheet();

  @override
  State<_GlobalIngredientManagementSheet> createState() =>
      __GlobalIngredientManagementSheetState();
}

class __GlobalIngredientManagementSheetState
    extends State<_GlobalIngredientManagementSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              _buildHandle(),
              _buildHeader(),
              _buildSearchBar(),
              Expanded(child: _buildIngredientsList()),
            ],
          ),

          Consumer<IngredientsProvider>(
            builder: (context, provider, child) {
              if (provider.error != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.error!),
                      backgroundColor: AppConsts.accentColor,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                  provider.clearError();
                });
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            S.of(context).manageDishIngredients_ingredientManagement,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppConsts.primaryColor,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _showCreateIngredientDialog,
            icon: const Icon(Icons.add),
            label: Text(S.of(context).manageDishIngredients_createNew),
            style: TextButton.styleFrom(
              foregroundColor: AppConsts.secondaryAccentColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateIngredientDialog() {
    showDialog(
      context: context,
      builder: (context) => const _CreateIngredientDialog(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: S.of(context).manageDishIngredients_searchYourIngredients,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildIngredientsList() {
    return Consumer<IngredientsProvider>(
      builder: (context, ingredientsProvider, _) {
        if (ingredientsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredIngredients =
            ingredientsProvider.ingredients
                .where(
                  (ing) => ing.nameEn.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                )
                .toList();

        if (filteredIngredients.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? S
                          .of(context)
                          .manageDishIngredients_noIngredientsInLibrary
                      : S.of(context).manageDishIngredients_searchEmpty,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    S
                        .of(context)
                        .manageDishIngredients_createYourFirstIngredient,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredIngredients.length,
          itemBuilder: (context, index) {
            final ingredient = filteredIngredients[index];
            return _GlobalIngredientTile(
              ingredient: ingredient,
              onEdit: () => _editIngredient(ingredient),
              onDelete: () => _deleteIngredient(ingredient),
            );
          },
        );
      },
    );
  }

  void _editIngredient(Ingredient ingredient) {
    showDialog(
      context: context,
      builder: (context) => _EditGlobalIngredientDialog(ingredient: ingredient),
    );
  }

  Future<void> _deleteIngredient(Ingredient ingredient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              S.of(context).manageDishIngredients_deleteIngredientTitle,
            ),
            content: Text(
              S
                  .of(context)
                  .manageDishIngredients_deleteIngredientContent(
                    ingredient.nameEn,
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(S.of(context).manageDishIngredients_deleteCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppConsts.accentColor,
                ),
                child: Text(S.of(context).manageDishIngredients_deleteConfirm),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final provider = context.read<IngredientsProvider>();
      final success = await provider.deleteIngredient(ingredient.id);

      if (success && provider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context).manageDishIngredients_ingredientDeletedSuccessfully,
            ),
            backgroundColor: AppConsts.secondaryAccentColor,
          ),
        );
      }
    }
  }
}

class _EditGlobalIngredientDialog extends StatefulWidget {
  final Ingredient ingredient;

  const _EditGlobalIngredientDialog({required this.ingredient});

  @override
  State<_EditGlobalIngredientDialog> createState() =>
      __EditGlobalIngredientDialogState();
}

class __EditGlobalIngredientDialogState
    extends State<_EditGlobalIngredientDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameFrController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameEnController = TextEditingController(text: widget.ingredient.nameEn);
    _nameFrController = TextEditingController(text: widget.ingredient.nameFr);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        S.of(context).manageDishIngredients_editIngredientTitle,
        style: TextStyle(
          color: AppConsts.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameEnController,
              decoration: InputDecoration(
                labelText: S.of(context).manageDishIngredients_nameEnLabel,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppConsts.secondaryAccentColor),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return S.of(context).manageDishIngredients_nameValidation;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameFrController,
              decoration: InputDecoration(
                labelText: S.of(context).manageDishIngredients_nameFrLabel,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppConsts.secondaryAccentColor),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return S.of(context).manageDishIngredients_nameValidation;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            S.of(context).manageDishIngredients_cancel,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateIngredient,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConsts.secondaryAccentColor,
            foregroundColor: Colors.white,
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Text(S.of(context).manageDishIngredients_update),
        ),
      ],
    );
  }

  Future<void> _updateIngredient() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final provider = context.read<IngredientsProvider>();
      await provider.updateIngredient(
        id: widget.ingredient.id,
        nameEn: _nameEnController.text,
        nameFr: _nameFrController.text,
      );

      if (provider.error == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context).manageDishIngredients_ingredientUpdatedSuccessfully,
            ),
            backgroundColor: AppConsts.secondaryAccentColor,
          ),
        );
      }

      setState(() => _isLoading = false);
    }
  }
}

class _GlobalIngredientTile extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GlobalIngredientTile({
    required this.ingredient,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConsts.secondaryAccentColor.withAlpha(25),
          child: Text(
            ingredient.nameEn[0].toUpperCase(),
            style: const TextStyle(
              color: AppConsts.secondaryAccentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          ingredient.nameEn,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppConsts.primaryColor,
          ),
        ),
        subtitle: Text(
          ingredient.nameFr,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(
                Icons.edit,
                color: AppConsts.secondaryAccentColor,
              ),
              tooltip: S.of(context).manageDishIngredients_editTooltip,
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, color: AppConsts.accentColor),
              tooltip: S.of(context).manageDishIngredients_deleteTooltip,
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateIngredientDialog extends StatefulWidget {
  const _CreateIngredientDialog();

  @override
  State<_CreateIngredientDialog> createState() =>
      __CreateIngredientDialogState();
}

class __CreateIngredientDialogState extends State<_CreateIngredientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameEnController = TextEditingController();
  final _nameFrController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        S.of(context).manageIngredients_createTitle,
        style: const TextStyle(
          color: AppConsts.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameEnController,
              decoration: InputDecoration(
                labelText: S.of(context).manageDishIngredients_nameEnLabel,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppConsts.secondaryAccentColor),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return S.of(context).manageDishIngredients_nameValidation;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameFrController,
              decoration: InputDecoration(
                labelText: S.of(context).manageDishIngredients_nameFrLabel,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppConsts.secondaryAccentColor),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return S.of(context).manageDishIngredients_nameValidation;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            S.of(context).manageDishIngredients_cancel,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createIngredient,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConsts.secondaryAccentColor,
            foregroundColor: Colors.white,
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Text(S.of(context).manageDishIngredients_create),
        ),
      ],
    );
  }

  Future<void> _createIngredient() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final provider = context.read<IngredientsProvider>();
      await provider.createIngredient(
        nameEn: _nameEnController.text,
        nameFr: _nameFrController.text,
      );

      if (provider.error == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context).manageDishIngredients_ingredientCreatedSuccessfully,
            ),
            backgroundColor: AppConsts.secondaryAccentColor,
          ),
        );
      }

      setState(() => _isLoading = false);
    }
  }
}

class _AvailableIngredientTile extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onSelect;

  const _AvailableIngredientTile({
    required this.ingredient,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConsts.secondaryAccentColor.withAlpha(25),
          child: Text(
            ingredient.nameEn[0].toUpperCase(),
            style: const TextStyle(
              color: AppConsts.secondaryAccentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          ingredient.nameEn,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppConsts.primaryColor,
          ),
        ),
        subtitle: Text(
          ingredient.nameFr,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link, color: AppConsts.secondaryAccentColor),
            const SizedBox(width: 4),
            Text(
              S.of(context).manageDishIngredients_link,
              style: const TextStyle(
                color: AppConsts.secondaryAccentColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        onTap: onSelect,
      ),
    );
  }
}

class _EditIngredientDialog extends StatefulWidget {
  final String dishId;
  final DishIngredient? existingIngredient;

  const _EditIngredientDialog({required this.dishId, this.existingIngredient});

  @override
  State<_EditIngredientDialog> createState() => __EditIngredientDialogState();
}

class __EditIngredientDialogState extends State<_EditIngredientDialog> {
  late final TextEditingController _priceController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.existingIngredient?.price.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AlertDialog(
          title: Text(
            widget.existingIngredient != null
                ? S.of(context).manageDishIngredients_editDialogEdit
                : S.of(context).manageDishIngredients_editDialogAdd,
            style: const TextStyle(
              color: AppConsts.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIngredientField(),
              const SizedBox(height: 16),
              _buildPriceField(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: Text(S.of(context).manageDishIngredients_deleteCancel),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConsts.secondaryAccentColor,
                foregroundColor: Colors.white,
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(S.of(context).manageDishIngredients_noteSave),
            ),
          ],
        ),

        Consumer<DishIngredientsProvider>(
          builder: (context, provider, child) {
            if (provider.dishError != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.dishError!),
                    backgroundColor: AppConsts.accentColor,
                    duration: const Duration(seconds: 4),
                  ),
                );
                provider.clearDishError();
              });
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildIngredientField() {
    return TextField(
      controller: TextEditingController(
        text: widget.existingIngredient?.ingredientNameEn,
      ),
      readOnly: true,
      decoration: InputDecoration(
        labelText: S.of(context).manageDishIngredients_editDialogIngredient,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildPriceField() {
    return TextField(
      controller: _priceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      enabled: true,
      decoration: InputDecoration(
        labelText: S.of(context).manageDishIngredients_price,
        prefixText: '\$',
        hintText: S.of(context).manageDishIngredients_enterPriceEg250,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Future<void> _saveChanges() async {
    final price = double.tryParse(_priceController.text) ?? 0;

    setState(() => _isLoading = true);

    final provider = context.read<DishIngredientsProvider>();

    try {
      if (widget.existingIngredient != null) {
        await provider.updateDishIngredient(
          dishId: widget.dishId,
          ingredientId: widget.existingIngredient!.ingredientId,
          price: price,
          isSupplement: false,
          available: true,
        );
      }

      if (provider.dishError == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingIngredient != null
                  ? S
                      .of(context)
                      .manageDishIngredients_ingredientUpdatedSuccessfully
                  : S
                      .of(context)
                      .manageDishIngredients_ingredientAddedSuccessfully,
            ),
            backgroundColor: AppConsts.secondaryAccentColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
