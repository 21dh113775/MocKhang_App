// user/pages/home/sections/banner_section.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class BannerSection extends StatefulWidget {
  const BannerSection({Key? key}) : super(key: key);

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  int _currentBannerIndex = 0;

  // Dữ liệu mẫu cho banner
  final List<Map<String, dynamic>> _bannerItems = [
    {
      'image': 'assets/banner.png',
      'title': 'Khuyến mãi lớn',
      'subtitle': 'Giảm đến 30% cho đơn hàng đầu tiên',
      'route': '/discount',
    },
    {
      'image': 'assets/banner1.png',
      'title': 'Bộ sưu tập mới',
      'subtitle': 'Phong thủy cho năm mới',
      'route': '/collection',
    },
    {
      'image': 'assets/banner.png',
      'title': 'Miễn phí vận chuyển',
      'subtitle': 'Cho đơn hàng trên 500.000đ',
      'route': '/shipping',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 180,
            viewportFraction: 0.92,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            onPageChanged: (index, reason) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
          ),
          items:
              _bannerItems.map((banner) {
                return Builder(
                  builder: (BuildContext context) {
                    return _BannerItem(banner: banner);
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: 10),
        // Dots indicator
        DotsIndicator(
          dotsCount: _bannerItems.length,
          position: _currentBannerIndex.toDouble(),
          decorator: DotsDecorator(
            size: const Size.square(8.0),
            activeSize: const Size(18.0, 8.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            color: Colors.grey[400]!,
            activeColor: Colors.brown,
          ),
        ),
      ],
    );
  }
}

class _BannerItem extends StatelessWidget {
  final Map<String, dynamic> banner;

  const _BannerItem({Key? key, required this.banner}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Xử lý khi nhấn vào banner
        Navigator.pushNamed(context, banner['route']);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // Banner image
              Image.asset(
                banner['image'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.brown[100],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.brown,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              // Banner gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              // Banner text
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      banner['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      banner['subtitle'],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
