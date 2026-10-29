import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cashew_store/core/constants/app_colors.dart';
import 'package:cashew_store/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:cashew_store/features/cart/presentation/cubit/cart_state.dart';
import 'package:cashew_store/features/home/data/models/product_model.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _selectedVariantIndex = 0;
  int _quantity = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  ProductVariantModel get _currentVariant {
    if (widget.product.variants.isNotEmpty &&
        _selectedVariantIndex < widget.product.variants.length) {
      return widget.product.variants[_selectedVariantIndex];
    }
    return ProductVariantModel(
      id: 'default',
      productId: widget.product.id,
      variantName: 'Standard',
      sku: 'STD',
      price: widget.product.displayPrice,
      compareAtPrice: widget.product.displayComparePrice,
      stockQuantity: 10,
    );
  }

  List<String> get _displayImages {
    final urls = widget.product.allImageUrls;
    if (urls.isNotEmpty) return urls;
    return [
      'https://images.unsplash.com/photo-1509912760195-450949d8a571',
      'https://images.unsplash.com/photo-1599785209707-a456fc1337bb',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final images = _displayImages;
    final variant = _currentVariant;
    final hasCompare = variant.compareAtPrice != null && variant.compareAtPrice! > variant.price;
    final discountPercent = hasCompare
        ? (((variant.compareAtPrice! - variant.price) / variant.compareAtPrice!) * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.product.categoryName ?? 'Product Details',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary),
                    onPressed: () {
                      context.push('/cart');
                    },
                  ),
                  if (cartState.totalItemCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            '${cartState.totalItemCount}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Slider with PageView & Indicator
            _buildImageSlider(images),

            const SizedBox(height: 16),

            // 2. Product Information Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag & Stock Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.product.categoryName ?? 'Cashews',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            variant.stockQuantity > 0 ? Icons.check_circle : Icons.error,
                            size: 14,
                            color: variant.stockQuantity > 0 ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            variant.stockQuantity > 0 ? 'In Stock (${variant.stockQuantity} left)' : 'Out of Stock',
                            style: TextStyle(
                              color: variant.stockQuantity > 0 ? AppColors.success : AppColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Product Title
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Rating Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7E6),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFFD591)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 14, color: AppColors.warning),
                            SizedBox(width: 4),
                            Text(
                              '4.9',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD46B08),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '128 ratings & reviews',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹${variant.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      if (hasCompare) ...[
                        const SizedBox(width: 10),
                        Text(
                          '₹${variant.compareAtPrice!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$discountPercent% OFF',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Text(
                    'Inclusive of all taxes',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 16),

                  // Pack Size / Variant Selector
                  if (widget.product.variants.isNotEmpty) ...[
                    const Text(
                      'Select Pack Size',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(widget.product.variants.length, (index) {
                          final v = widget.product.variants[index];
                          final isSelected = index == _selectedVariantIndex;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedVariantIndex = index;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary.withOpacity(0.25),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      v.variantName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₹${v.price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected ? Colors.white.withOpacity(0.9) : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              padding: EdgeInsets.zero,
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 32),
                              alignment: Alignment.center,
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: _quantity < variant.stockQuantity
                                  ? () => setState(() => _quantity++)
                                  : null,
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 16),

                  // Description / Details
                  const Text(
                    'Product Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (widget.product.description != null && widget.product.description!.isNotEmpty)
                        ? widget.product.description!
                        : 'Handpicked and carefully processed high-grade cashews with unmatched crunch, natural sweetness, and richness. Nitrogen-flushed packaging ensures farm-fresh crunch in every bite.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Trust Badges
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBadge(Icons.verified_outlined, '100% Pure'),
                        _buildBadge(Icons.local_shipping_outlined, 'Free Delivery'),
                        _buildBadge(Icons.eco_outlined, 'Farm Fresh'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Spacing for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),

      // 3. Bottom Action Bar with Total Price, Add to Cart & Buy Now Buttons
      bottomNavigationBar: _buildBottomActionBar(variant),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // Image Slider with Page Indicator
  Widget _buildImageSlider(List<String> images) {
    return Container(
      height: 300,
      width: double.infinity,
      color: const Color(0xFFFBF8F2),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final url = images[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFF9E6),
                      const Color(0xFFFFE7BA).withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: const Color(0xFFFFD591), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.eco_rounded,
                              size: 58,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            widget.product.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Photo ${index + 1} of ${images.length} • Grade W180 Premium',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (url.startsWith('http'))
                        Image.network(
                          url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Indicator Dots
          Positioned(
            bottom: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final isSelected = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // Image Counter Pill (e.g. 1/3)
          Positioned(
            top: 24,
            right: 28,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentPage + 1}/${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Action Bar with Add to Cart and Buy Buttons
  Widget _buildBottomActionBar(ProductVariantModel variant) {
    final totalPrice = variant.price * _quantity;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Total Price Summary
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Price',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                Text(
                  '₹${totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Add To Cart Button
            Expanded(
              child: OutlinedButton(
                onPressed: variant.stockQuantity > 0 ? () => _handleAddToCart(variant) : null,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_shopping_cart, size: 18, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Add to Cart',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Buy Now Button
            Expanded(
              child: ElevatedButton(
                onPressed: variant.stockQuantity > 0 ? () => _handleBuyNow(variant) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt, size: 18, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Buy Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddToCart(ProductVariantModel variant) {
    context.read<CartCubit>().addToCart(widget.product, variant, quantity: _quantity);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Added $_quantity x ${widget.product.name} (${variant.variantName}) to cart!',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.amberAccent,
          onPressed: () {
            context.push('/cart');
          },
        ),
      ),
    );
  }

  void _handleBuyNow(ProductVariantModel variant) {
    context.read<CartCubit>().addToCart(widget.product, variant, quantity: _quantity);
    _showCartSummarySheet(context, isInstantBuy: true);
  }

  void _showCartSummarySheet(BuildContext context, {bool isInstantBuy = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isInstantBuy ? 'Proceed to Checkout' : 'Your Shopping Cart',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (cartState.items.isNotEmpty)
                          TextButton(
                            onPressed: () => context.read<CartCubit>().clearCart(),
                            child: const Text('Clear All', style: TextStyle(color: AppColors.error, fontSize: 13)),
                          )
                        else
                          Text(
                            '${cartState.totalItemCount} items',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.border),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: cartState.items.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Center(
                                child: Text('Your cart is empty'),
                              ),
                            )
                          : Builder(builder: (context) {
                              final displayedItems = cartState.items.take(2).toList();
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: displayedItems.length,
                                    separatorBuilder: (_, __) => const Divider(color: AppColors.border),
                                    itemBuilder: (context, i) {
                                      final item = displayedItems[i];
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF9F6F0),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.shopping_bag_outlined,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        title: Text(
                                          item.product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${item.variant.variantName} • ₹${item.variant.price.toStringAsFixed(0)} each',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline, size: 18, color: AppColors.primary),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                              onPressed: () {
                                                if (item.id != null) {
                                                  if (item.quantity > 1) {
                                                    context.read<CartCubit>().updateQuantity(item.id!, item.quantity - 1);
                                                  } else {
                                                    context.read<CartCubit>().removeCartItem(item.id!);
                                                  }
                                                }
                                              },
                                            ),
                                            Text(
                                              '${item.quantity}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primary),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                              onPressed: () {
                                                if (item.id != null) {
                                                  context.read<CartCubit>().updateQuantity(item.id!, item.quantity + 1);
                                                }
                                              },
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '₹${item.totalPrice.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                              onPressed: () {
                                                if (item.id != null) {
                                                  context.read<CartCubit>().removeCartItem(item.id!);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  if (cartState.items.length > 2) ...[
                                    const SizedBox(height: 10),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(sheetContext).pop();
                                        context.push('/cart');
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight.withValues(alpha: 0.35),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.primaryLight),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'View More (${cartState.items.length - 2} more ${cartState.items.length - 2 == 1 ? "item" : "items"})',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryDark,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primaryDark),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            }),
                    ),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '₹${cartState.subtotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: cartState.items.isEmpty
                            ? null
                            : () {
                                Navigator.of(sheetContext).pop();
                                context.push('/cart');
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isInstantBuy ? 'Complete Purchase Now' : 'View Full Cart & Checkout',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
