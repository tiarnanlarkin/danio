import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/shop_directory.dart';
import '../theme/app_theme.dart';

class ShopStreetScreen extends StatefulWidget {
  const ShopStreetScreen({super.key});

  @override
  State<ShopStreetScreen> createState() => _ShopStreetScreenState();
}

class _ShopStreetScreenState extends State<ShopStreetScreen> {
  String? _selectedRegion;
  String? _selectedCategory;

  List<ShopEntry> get _filteredShops {
    var shops = ShopDirectory.all;
    
    if (_selectedRegion != null) {
      shops = shops.where((s) => s.region == _selectedRegion).toList();
    }
    
    if (_selectedCategory != null) {
      shops = shops.where((s) => 
          s.categories.any((c) => c == _selectedCategory)).toList();
    }
    
    return shops;
  }

  @override
  Widget build(BuildContext context) {
    final shops = _filteredShops;
    
    // Group by region
    final grouped = <String, List<ShopEntry>>{};
    for (final shop in shops) {
      grouped.putIfAbsent(shop.region, () => []).add(shop);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Street'),
      ),
      body: Column(
        children: [
          // Disclosure banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: AppColors.info.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.info),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'External links to aquarium shops. We don\'t receive commissions unless marked.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
          
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Region filter
                _FilterChip(
                  label: _selectedRegion ?? 'All Regions',
                  isActive: _selectedRegion != null,
                  onTap: () => _showRegionPicker(),
                ),
                const SizedBox(width: 8),
                // Category filter
                _FilterChip(
                  label: _selectedCategory ?? 'All Categories',
                  isActive: _selectedCategory != null,
                  onTap: () => _showCategoryPicker(),
                ),
                if (_selectedRegion != null || _selectedCategory != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => setState(() {
                      _selectedRegion = null;
                      _selectedCategory = null;
                    }),
                    child: const Text('Clear'),
                  ),
                ],
              ],
            ),
          ),
          
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${shops.length} ${shops.length == 1 ? 'shop' : 'shops'}',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Shop list
          Expanded(
            child: shops.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.store_outlined, size: 64, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        Text('No shops match your filters', style: AppTypography.bodyMedium),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() {
                            _selectedRegion = null;
                            _selectedCategory = null;
                          }),
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, index) {
                      final region = grouped.keys.elementAt(index);
                      final regionShops = grouped[region]!;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index > 0) const SizedBox(height: 16),
                          _RegionHeader(region: region),
                          const SizedBox(height: 8),
                          ...regionShops.map((shop) => _ShopCard(shop: shop)),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showRegionPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Regions'),
              trailing: _selectedRegion == null 
                  ? const Icon(Icons.check, color: AppColors.primary) 
                  : null,
              onTap: () {
                setState(() => _selectedRegion = null);
                Navigator.pop(ctx);
              },
            ),
            ...ShopDirectory.regions.map((region) => ListTile(
              title: Text(region),
              trailing: _selectedRegion == region 
                  ? const Icon(Icons.check, color: AppColors.primary) 
                  : null,
              onTap: () {
                setState(() => _selectedRegion = region);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Categories'),
                trailing: _selectedCategory == null 
                    ? const Icon(Icons.check, color: AppColors.primary) 
                    : null,
                onTap: () {
                  setState(() => _selectedCategory = null);
                  Navigator.pop(ctx);
                },
              ),
              ...ShopDirectory.categories.map((category) => ListTile(
                leading: Icon(_categoryIcon(category), color: AppColors.textSecondary),
                title: Text(category),
                trailing: _selectedCategory == category 
                    ? const Icon(Icons.check, color: AppColors.primary) 
                    : null,
                onTap: () {
                  setState(() => _selectedCategory = category);
                  Navigator.pop(ctx);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fish': return Icons.set_meal;
      case 'plants': return Icons.grass;
      case 'shrimp': return Icons.pest_control;
      case 'equipment': return Icons.build;
      case 'food': return Icons.restaurant;
      case 'medication': return Icons.medication;
      case 'tanks': return Icons.crop_square;
      case 'hardscape': return Icons.landscape;
      case 'co2': return Icons.bubble_chart;
      case 'aquascaping': return Icons.park;
      case 'information': return Icons.info;
      default: return Icons.store;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textPrimary,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionHeader extends StatelessWidget {
  final String region;

  const _RegionHeader({required this.region});

  String get _flag {
    switch (region) {
      case 'UK': return '🇬🇧';
      case 'US': return '🇺🇸';
      case 'EU': return '🇪🇺';
      case 'Global': return '🌍';
      default: return '🏪';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(_flag, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(region, style: AppTypography.headlineSmall),
      ],
    );
  }
}

class _ShopCard extends StatelessWidget {
  final ShopEntry shop;

  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _launchUrl(shop.url),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(shop.name, style: AppTypography.labelLarge),
                  ),
                  Icon(Icons.open_in_new, size: 16, color: AppColors.textHint),
                ],
              ),
              if (shop.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  shop.description!,
                  style: AppTypography.bodySmall,
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: shop.categories.map((cat) => _CategoryTag(category: cat)).toList(),
              ),
              if (shop.isAffiliate) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.handshake, size: 12, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        'Affiliate link',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _CategoryTag extends StatelessWidget {
  final String category;

  const _CategoryTag({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(category, style: AppTypography.bodySmall),
    );
  }
}
