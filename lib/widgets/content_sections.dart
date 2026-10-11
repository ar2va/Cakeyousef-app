import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/catalog_models.dart';
import '../screens/product_detail_screen.dart';
import '../state/products_repository.dart';
import '../theme/app_colors.dart';
import '../utils/app_nav.dart';
import '../utils/network_image.dart';
import 'home_pair_slider.dart';
import 'section_header.dart';

class ProductsSection extends StatefulWidget {
  const ProductsSection({super.key});

  @override
  State<ProductsSection> createState() => _ProductsSectionState();
}

class _ProductsSectionState extends State<ProductsSection> {
  final _repo = ProductsRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repo,
      builder: (context, _) {
        final products = _repo.homePreview;
        return Column(
          children: [
            SectionHeader(
              title: 'محصولات فیزیکی',
              onSeeAll: () => MainTabScope.go(context, 3),
            ),
            const SizedBox(height: 12),
            if (_repo.loading && !_repo.hasData)
              const SizedBox(
                height: 160,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.gold600),
                ),
              )
            else if (_repo.error != null && !_repo.hasData)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    Text(
                      _repo.error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warm400,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _repo.load(force: true),
                      child: Text(
                        'تلاش مجدد',
                        style:
                            GoogleFonts.vazirmatn(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              )
            else if (!_repo.hasData)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  'محصولی برای نمایش نیست',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warm400,
                  ),
                ),
              )
            else
              HomePairSlider(
                itemCount: products.length,
                height: 236,
                autoPlay: true,
                autoInterval: const Duration(seconds: 5),
                itemBuilder: (context, index) =>
                    _HomeProductCard(product: products[index]),
              ),
          ],
        );
      },
    );
  }
}

class _HomeProductCard extends StatelessWidget {
  final ShopProductDto product;

  const _HomeProductCard({required this.product});

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.warm200.withValues(alpha: 0.45)),
      ),
      child: InkWell(
        onTap: () => _open(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 11,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: AppColors.creamDark),
                  if (product.imageUrl.isNotEmpty)
                    AppNetworkImage(
                      url: product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x14000000),
                          Color(0x00000000),
                          Color(0x66000000),
                        ],
                        stops: [0, 0.45, 1],
                      ),
                    ),
                  ),
                  if (product.category.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (!product.inStock)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ناموجود',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark900,
                        height: 1.35,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${product.priceLabel} تومان',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gold700,
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
}
