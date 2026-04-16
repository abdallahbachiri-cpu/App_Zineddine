import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/utils/map_marker_utils.dart';
import 'package:cuisinous/data/models/address.dart';
import 'package:cuisinous/data/models/food_store.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/food_store_provider.dart';

import 'package:cuisinous/widgets/network_image_widget.dart';
import 'package:cuisinous/widgets/recipe_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class FoodStoreDetailScreen extends StatefulWidget {
  final FoodStore foodStore;

  const FoodStoreDetailScreen({super.key, required this.foodStore});

  @override
  State<FoodStoreDetailScreen> createState() => _FoodStoreDetailScreenState();
}

class _FoodStoreDetailScreenState extends State<FoodStoreDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _selectedCategory;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _selectedCategory = S.of(context).foodStoreCategoryAll;
      _loadData();
      _isInit = false;
    }
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FoodStoreProvider>().fetchFoodStoreDishes(
          widget.foodStore.id,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        toolbarHeight: 50,
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
      body: SafeArea(
        bottom: true,
        top: false,
        child: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(),
                    const SizedBox(height: 16),
                  ]),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      unselectedLabelColor: Colors.grey[600],
                      labelColor: AppConsts.accentColor,
                      indicatorColor: AppConsts.accentColor,
                      dividerColor: Colors.transparent,
                      controller: _tabController,
                      tabs: [
                        Tab(text: S.of(context).foodStoreTabRecipes),
                        Tab(text: S.of(context).foodStoreTabAbout),
                        Tab(text: S.of(context).foodStoreTabGallery),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ],
          body: _buildTabViews(),
        ),
      ),
    );
  }

  Widget _buildRoundedBackButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0),

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

  Widget _buildHeader() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            child: ClipOval(
              child: NetworkImageWidget(
                imageUrl: widget.foodStore.profileImageUrl ?? '',
                fit: BoxFit.cover,
                width: 100,
                height: 100,
                errorIcon: Icons.storefront,
                errorIconSize: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.foodStore.name,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (widget.foodStore.address != null)
            Text(
              '${widget.foodStore.address!.street}, ${widget.foodStore.address!.city}, ${widget.foodStore.address!.country}',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          const SizedBox(height: 8),
          Consumer<FoodStoreProvider>(
            builder: (context, provider, child) {
              final count = provider.foodStoreDishes.length;
              return Text(
                '$count ${S.of(context).foodStoreRecipesCount}',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabViews() {
    return TabBarView(
      controller: _tabController,
      children: [_buildRecipesTab(), _buildAboutTab(), _buildGalleryTab()],
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.foodStore.description?.isNotEmpty ?? false)
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).foodStoreAboutUs,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.foodStore.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (widget.foodStore.description?.isNotEmpty ?? false)
            const SizedBox(height: 24),

          if (widget.foodStore.address != null)
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).foodStoreStoreInfo,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAddressSection(widget.foodStore.address!),
                    const SizedBox(height: 16),
                    _buildMiniMap(widget.foodStore),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniMap(FoodStore store) {
    if (store.address == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _navigateToMap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              AbsorbPointer(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      store.address!.latitude,
                      store.address!.longitude,
                    ),
                    zoom: 15,
                  ),
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  markers: {
                    Marker(
                      markerId: MarkerId(store.id),
                      position: LatLng(
                        store.address!.latitude,
                        store.address!.longitude,
                      ),
                      icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
                    ),
                  },
                  onMapCreated: (controller) {
                    _loadMarkerIcon(store);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BitmapDescriptor? _customMarkerIcon;

  Future<void> _loadMarkerIcon(FoodStore store) async {
    if (_customMarkerIcon == null) {
      final icon = await MapMarkerUtils.loadStoreMarkerIcon(
        store.profileImageUrl,
      );
      if (icon != null && mounted) {
        setState(() {
          _customMarkerIcon = icon;
        });
      }
    }
  }

  Future<void> _navigateToMap() async {
    if (widget.foodStore.address == null) return;
    await MapMarkerUtils.navigateToMap(
      context,
      widget.foodStore.address!.latitude,
      widget.foodStore.address!.longitude,
    );
  }

  Widget _buildAddressSection(Address address) {
    return Column(
      children: [
        _buildInfoRow(Icons.location_on, _formatAddress(address)),
        if (address.additionalDetails?.isNotEmpty ?? false)
          _buildInfoRow(Icons.info_outline, address.additionalDetails!),
      ],
    );
  }

  String _formatAddress(Address address) {
    final parts =
        [
          address.street,
          address.city,
          if (address.state?.isNotEmpty ?? false) address.state,
          address.zipCode,
          address.country,
        ].where((part) => part?.isNotEmpty ?? false).toList();

    return parts.join(', ');
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppConsts.accentColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryTab() {
    return Consumer<FoodStoreProvider>(
      builder: (context, provider, child) {
        if (provider.dishesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.dishesError != null) {
          return Center(child: Text(provider.dishesError!));
        }

        final allImages =
            provider.foodStoreDishes.expand((dish) => dish.gallery).toList();

        if (allImages.isEmpty) {
          return Center(child: Text(S.of(context).foodStoreNoImages));
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: allImages.length,
            itemBuilder:
                (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: NetworkImageWidget(
                    imageUrl: allImages[index].url,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12),
                    errorIcon: Icons.broken_image,
                  ),
                ),
          ),
        );
      },
    );
  }

  Widget _buildRecipesTab() {
    return Consumer<FoodStoreProvider>(
      builder: (context, provider, child) {
        if (provider.dishesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.dishesError != null) {
          return Center(child: Text(provider.dishesError!));
        }

        final dishes = provider.foodStoreDishes;

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: dishes.length,
                itemBuilder:
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: RecipeCard(
                        recipe: dishes[index],
                        rating: dishes[index].averageRating.toDouble(),
                        isFavorite: true,
                        onFavoritePressed: () => {},
                      ),
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppConsts.backgroundColor, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
