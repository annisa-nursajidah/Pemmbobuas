import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/service_model.dart';
import '../../services/firebase_service.dart';
import '../../widgets/service_card.dart';
import '../service/service_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<ServiceModel> _allServices = [];
  List<ServiceModel> _filteredServices = [];
  List<String> _categories = ['Semua'];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final services = await _firebaseService.getAllServices();
      final categories = await _firebaseService.getCategories();
      setState(() {
        _allServices = services;
        _filteredServices = services;
        _categories = ['Semua', ...categories];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredServices = _allServices.where((s) {
        final matchSearch =
            s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.mitraName.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchCategory =
            _selectedCategory == 'Semua' || s.category == _selectedCategory;
        return matchSearch && matchCategory;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title: const Text('Jelajah Layanan'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isGridView = !_isGridView),
            icon: Icon(
              _isGridView
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
            ),
            tooltip: _isGridView ? 'Tampilan List' : 'Tampilan Grid',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Container(
              color: AppColors.primaryBlue,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  _searchQuery = val;
                  _applyFilter();
                },
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Cari layanan atau nama mitra...',
                  fillColor: AppColors.white,
                  filled: true,
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textHint),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              color: AppColors.textHint),
                          onPressed: () {
                            _searchController.clear();
                            _searchQuery = '';
                            _applyFilter();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Category Filter
            Container(
              height: 48,
              color: AppColors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      _applyFilter();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentBlue
                            : AppColors.surfaceGrey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Result info
            if (!_isLoading)
              Container(
                width: double.infinity,
                color: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '${_filteredServices.length} layanan ditemukan',
                  style: AppTextStyles.bodySmall,
                ),
              ),

            const SizedBox(height: 8),

            // List / Grid
            Expanded(
              child: _isLoading
                  ? _buildShimmerList()
                  : _filteredServices.isEmpty
                      ? _buildEmptyState()
                      : _isGridView
                          ? _buildGridView()
                          : _buildListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ServiceCard(
            service: _filteredServices[index],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ServiceDetailScreen(service: _filteredServices[index]),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        final s = _filteredServices[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceDetailScreen(service: s),
            ),
          ),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    s.imageUrl,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 110,
                      color: AppColors.lightBlue,
                      child: const Icon(Icons.image_outlined,
                          color: AppColors.textHint),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium
                            .copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.starYellow, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            s.mitraRating.toStringAsFixed(1),
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Mulai Rp ${_formatPrice(s.price)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accentBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          const Icon(Icons.search_off_rounded,
              size: 80, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            'Tidak ada layanan\nyang cocok dengan pencarian',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              _searchController.clear();
              _searchQuery = '';
              _selectedCategory = 'Semua';
              _applyFilter();
            },
            child: const Text('Reset Filter'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}jt';
    }
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}
