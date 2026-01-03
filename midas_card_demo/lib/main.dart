import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MidasCardApp());
}

class MidasCardApp extends StatelessWidget {
  const MidasCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const Scaffold(
        body: MidasCardPageView(),
      ),
    );
  }
}

class MidasCardPageView extends StatefulWidget {
  const MidasCardPageView({super.key});

  @override
  State<MidasCardPageView> createState() => _MidasCardPageViewState();
}

class _MidasCardPageViewState extends State<MidasCardPageView> {
  final PageController _pageController = PageController(viewportFraction: 0.9);

  // Data for the 2 Specific Cards
  final List<MidasCardData> cards = [
    // 1. Mikuni Souichiro (Purple)
    MidasCardData(
      assetImagePath: "assets/card_mikuni_v2.jpg",
      logoAssetPath: "assets/logo_mikuni_v2.jpg",
    ),
    // 2. Yoga Kimimaro (Black) - Note: Yoga is often the 'protagonist' card
    MidasCardData(
      assetImagePath: "assets/card_yoga_v2.jpg",
      logoAssetPath: "assets/logo_yoga_v2.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: PageView.builder(
          controller: _pageController,
          itemCount: cards.length,
          itemBuilder: (context, index) {
            return Center(
              child: MidasCard(data: cards[index]),
            );
          },
        ),
      ),
    );
  }
}

class MidasCardData {
  final String assetImagePath;
  final String logoAssetPath;

  MidasCardData({
    required this.assetImagePath,
    required this.logoAssetPath,
  });
}

class MidasCard extends StatefulWidget {
  final MidasCardData data;
  const MidasCard({super.key, required this.data});

  @override
  State<MidasCard> createState() => _MidasCardState();
}

class _MidasCardState extends State<MidasCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 12)) 
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double aspectRatio = 1.586;
    final double width = MediaQuery.of(context).size.width * 0.85;
    final double height = width / aspectRatio;

    // Logo size relative to card height.
    // Based on the cropped images, the new v2 images are single cards.
    // The logo is a central feature.
    final double logoSize = height * 0.75;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // 1. Image Background
            Positioned.fill(
              child: Image.asset(
                widget.data.assetImagePath,
                fit: BoxFit.cover,
              ),
            ),
            
            // 2. Rotating Center Emblem (Real Image)
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: logoSize, 
                  height: logoSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Mask to hide the photo's emblem
                      Container(
                        width: logoSize * 0.9, 
                        height: logoSize * 0.9,
                        decoration: const BoxDecoration(
                          color: Colors.black, // Dark mask
                          shape: BoxShape.circle,
                        ),
                      ),
                      
                      // The Animated Emblem Image
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // Perspective
                              ..rotateX(_controller.value * 2 * math.pi), // Vertical rotation
                            child: child,
                          );
                        },
                        child: ClipOval(
                          child: Image.asset(
                            widget.data.logoAssetPath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
