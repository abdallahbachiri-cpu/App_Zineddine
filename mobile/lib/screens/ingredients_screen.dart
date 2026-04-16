import 'package:cuisinous/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ingredients_provider.dart';

class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen({super.key});

  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends State<IngredientsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IngredientsProvider>().fetchIngredients();
    });

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<IngredientsProvider>().loadMoreIngredients();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).ingredients_title)),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Consumer<IngredientsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.ingredients.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null && provider.ingredients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchIngredients(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (provider.error != null && provider.ingredients.isNotEmpty) {
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

            if (provider.ingredients.isEmpty) {
              return Center(child: Text(S.of(context).ingredients_empty));
            }

            return RefreshIndicator(
              onRefresh: () => provider.fetchIngredients(refresh: true),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: provider.ingredients.length + 1,
                itemBuilder: (context, index) {
                  if (index < provider.ingredients.length) {
                    final ingredient = provider.ingredients[index];
                    return ListTile(
                      title: Text(ingredient.nameEn),
                      subtitle: Text(ingredient.nameFr),
                    );
                  }

                  return provider.canLoadMore
                      ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const SizedBox();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
