import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/category_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DishFilterDialog extends StatefulWidget {
  final bool showSearch;
  final String? initialSearch;
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final List<String> initialCategories;

  final String initialSortBy;
  final String initialSortOrder;
  final Function({
    String? search,
    double? minPrice,
    double? maxPrice,
    List<String>? categories,

    String? sortBy,
    String? sortOrder,
  })
  onApply;
  final VoidCallback onReset;

  const DishFilterDialog({
    super.key,
    this.showSearch = false,
    this.initialSearch,
    this.initialMinPrice,
    this.initialMaxPrice,
    required this.initialCategories,

    required this.initialSortBy,
    required this.initialSortOrder,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<DishFilterDialog> createState() => _DishFilterDialogState();
}

class _DishFilterDialogState extends State<DishFilterDialog> {
  late String _search;
  late double? _minPrice;
  late double? _maxPrice;
  late List<String> _selectedCategories;

  late String _sortBy;
  late String _sortOrder;

  String _categorySearchQuery = '';
  final TextEditingController _categorySearchController =
      TextEditingController();

  final _sortOptions = ['price', 'cachedAverageRating'];
  final _sortOrders = ['ASC', 'DESC'];

  @override
  void initState() {
    super.initState();
    _search = widget.initialSearch ?? '';
    _minPrice = widget.initialMinPrice;
    _maxPrice = widget.initialMaxPrice;
    _selectedCategories = List.from(widget.initialCategories);

    _sortBy = widget.initialSortBy;
    if (!_sortOptions.contains(_sortBy)) {
      _sortBy = _sortOptions.first;
    }
    _sortOrder = widget.initialSortOrder;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories(limit: 100);
    });
  }

  @override
  void dispose() {
    _categorySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      title: Text(S.of(context).home_filterTitle),
      content: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppConsts.backgroundColor,

            onPrimary: Colors.black,
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: const TextStyle(color: Colors.black),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.black,
            selectionColor: AppConsts.backgroundColor,
            selectionHandleColor: Colors.black,
          ),
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showSearch) ...[
                  TextFormField(
                    initialValue: _search,
                    decoration: InputDecoration(
                      labelText: S.of(context).buyerOrders_searchLabel,
                      hintText: S.of(context).buyerOrders_searchHint,

                      labelStyle: const TextStyle(color: Colors.black),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    onChanged: (value) => _search = value,
                  ),
                  const SizedBox(height: 16),
                ],

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _minPrice?.toString(),
                        decoration: InputDecoration(
                          labelText: S.of(context).buyerOrders_filterMinPrice,
                          prefixText: '\$',
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged:
                            (value) => _minPrice = double.tryParse(value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _maxPrice?.toString(),
                        decoration: InputDecoration(
                          labelText: S.of(context).buyerOrders_filterMaxPrice,
                          prefixText: '\$',
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged:
                            (value) => _maxPrice = double.tryParse(value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text(
                  S.of(context).home_categories,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: _categorySearchController,
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.black,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  cursorColor: Colors.black,
                  onChanged: (value) {
                    setState(() {
                      _categorySearchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 8),

                Consumer<CategoryProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading && provider.categories.isEmpty) {
                      return const LinearProgressIndicator();
                    }

                    final isFrench =
                        Localizations.localeOf(context).languageCode == 'fr';
                    final filteredCategories =
                        provider.categories.where((category) {
                          final name =
                              isFrench ? category.nameFr : category.nameEn;
                          return name.toLowerCase().contains(
                            _categorySearchQuery,
                          );
                        }).toList();

                    if (filteredCategories.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'No categories found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }

                    return Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children:
                              filteredCategories.map((category) {
                                final isSelected = _selectedCategories.contains(
                                  category.id,
                                );
                                final name =
                                    isFrench
                                        ? category.nameFr
                                        : category.nameEn;
                                return FilterChip(
                                  label: Text(name),
                                  labelStyle: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.black
                                            : Colors.black,
                                  ),
                                  selected: isSelected,
                                  backgroundColor: Colors.grey[200],
                                  selectedColor: AppConsts.backgroundColor,
                                  checkmarkColor: Colors.black,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedCategories.add(category.id);
                                      } else {
                                        _selectedCategories.remove(category.id);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _sortBy,
                        decoration: InputDecoration(
                          labelText: S.of(context).orderFilter_labelSortBy,
                        ),
                        items:
                            _sortOptions.map((s) {
                              String label = s;
                              if (s == 'price') {
                                label = S.of(context).home_sortPrice;
                              } else if (s == 'cachedAverageRating') {
                                label = S.of(context).home_sortRating;
                              }

                              return DropdownMenuItem(
                                value: s,
                                child: Text(label),
                              );
                            }).toList(),
                        onChanged:
                            (value) =>
                                setState(() => _sortBy = value ?? _sortBy),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _sortOrder,
                        decoration: InputDecoration(
                          labelText: S.of(context).orderFilter_labelSortOrder,
                        ),
                        items:
                            _sortOrders.map((s) {
                              final label =
                                  s == 'ASC'
                                      ? S.of(context).orderFilter_optionAsc
                                      : S.of(context).orderFilter_optionDesc;
                              return DropdownMenuItem(
                                value: s,
                                child: Text(label),
                              );
                            }).toList(),
                        onChanged:
                            (value) => setState(
                              () => _sortOrder = value ?? _sortOrder,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            widget.onReset();
            Navigator.pop(context);
          },
          child: Text(
            S.of(context).buyerOrders_filterReset,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConsts.backgroundColor,
            foregroundColor: Colors.black,
            shadowColor: Colors.grey.withAlpha(80),
            elevation: 2,
          ),
          onPressed: () {
            widget.onApply(
              search: widget.showSearch ? _search : null,
              minPrice: _minPrice,
              maxPrice: _maxPrice,
              categories: _selectedCategories,

              sortBy: _sortBy,
              sortOrder: _sortOrder,
            );
            Navigator.pop(context);
          },
          child: Text(S.of(context).buyerOrders_filterApply),
        ),
      ],
    );
  }
}
