import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart'; // Import for physics simulations
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
    // 1. Mikuni Souichiro
    MidasCardData(
      assetImagePath: "assets/card_mikuni_v2.jpg",
      logoAssetPath: "assets/logo_mikuni_precise.jpg",
      logoSizeRatio: 0.511, // Calculated by OpenCV
    ),
    // 2. Yoga Kimimaro
    MidasCardData(
      assetImagePath: "assets/card_yoga_v2.jpg",
      logoAssetPath: "assets/logo_yoga_precise.jpg",
      logoSizeRatio: 0.800, // Calculated by Threshold method
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
  final double logoSizeRatio;

  MidasCardData({
    required this.assetImagePath,
    required this.logoAssetPath,
    required this.logoSizeRatio,
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
    // Unbounded controller to allow infinite spinning
    _controller = AnimationController.unbounded(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    // Touch control: Map vertical drag to rotation
    // Sensitivity factor: how much angle changes per pixel dragged
    // 0.01 radians per pixel seems reasonable
    _controller.value += details.delta.dy * 0.01;
  }

  void _onPanEnd(DragEndDetails details) {
    // Inertia: Use FrictionSimulation
    // velocity is pixels/second. We need to convert it to radians/second same as above sensitivity.
    final velocity = details.velocity.pixelsPerSecond.dy * 0.01;
    
    // Friction coefficient: Lower = slides longer. 
    // 0.5 feels like a good bearing.
    final simulation = FrictionSimulation(0.1, _controller.value, velocity);
    
    _controller.animateWith(simulation);
  }
  
  void _onPanDown(DragDownDetails details) {
    // Stop animation immediately on touch
    _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    const double aspectRatio = 1.586;
    final double width = MediaQuery.of(context).size.width * 0.85;
    final double height = width / aspectRatio;

    // Use specific ratio for logo size
    final double logoSize = height * widget.data.logoSizeRatio;

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
            
            // 2. Rotating Center Emblem (Interactive)
            // Wrap in GestureDetector for touch
            Positioned.fill(
              child: GestureDetector(
                onPanDown: _onPanDown,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                behavior: HitTestBehavior.opaque, // Catch touches
                child: Center(
                  child: SizedBox(
                    width: logoSize, 
                    height: logoSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Mask to hide the photo's emblem
                        Container(
                          width: logoSize, 
                          height: logoSize,
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
                                ..rotateX(_controller.value), // Physics driven value as Angle
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
            ),
          ],
        ),
      ),
    );
  }
}
