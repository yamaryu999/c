import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
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
      logoSizeRatio: 0.511, 
      glowColor: Colors.purpleAccent, // Mikuni theme
    ),
    // 2. Yoga Kimimaro
    MidasCardData(
      assetImagePath: "assets/card_yoga_v2.jpg",
      logoAssetPath: "assets/logo_yoga_precise.jpg",
      logoSizeRatio: 0.800,
      glowColor: Colors.amber, // Yoga theme (Gold/Amber)
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
  final Color glowColor;

  MidasCardData({
    required this.assetImagePath,
    required this.logoAssetPath,
    required this.logoSizeRatio,
    required this.glowColor,
  });
}

class MidasCard extends StatefulWidget {
  final MidasCardData data;
  const MidasCard({super.key, required this.data});

  @override
  State<MidasCard> createState() => _MidasCardState();
}

class _MidasCardState extends State<MidasCard>
    with TickerProviderStateMixin { // Changed to TickerProviderStateMixin for multiple controllers
  late AnimationController _rotationController;
  late AnimationController _glowController;
  late AnimationController _glareController;

  @override
  void initState() {
    super.initState();
    // Rotation Controller (Physics)
    _rotationController = AnimationController.unbounded(vsync: this);

    // Glow Controller (Breathing)
    _glowController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Glare Controller (Periodic Sweep)
    _glareController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4)
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _glowController.dispose();
    _glareController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _rotationController.value += details.delta.dy * 0.01;
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy * 0.01;
    final simulation = FrictionSimulation(0.1, _rotationController.value, velocity);
    _rotationController.animateWith(simulation);
  }
  
  void _onPanDown(DragDownDetails details) {
    _rotationController.stop();
  }

  @override
  Widget build(BuildContext context) {
    const double aspectRatio = 1.586;
    final double width = MediaQuery.of(context).size.width * 0.85;
    final double height = width / aspectRatio;

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
            
            // 2. Pulsing Glow (Behind Logo)
            Positioned.fill(
                child: Center(
                    child: AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                            // Pulse opacity and spread
                            return Container(
                                width: logoSize * 0.8,
                                height: logoSize * 0.8,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                        BoxShadow(
                                            color: widget.data.glowColor.withOpacity(0.3 + 0.3 * _glowController.value),
                                            blurRadius: 20 + 30 * _glowController.value,
                                            spreadRadius: 5 + 10 * _glowController.value,
                                        )
                                    ]
                                ),
                            );
                        }
                    )
                )
            ),

            // 3. Rotating Center Emblem (Interactive)
            Positioned.fill(
              child: GestureDetector(
                onPanDown: _onPanDown,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: SizedBox(
                    width: logoSize, 
                    height: logoSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Mask
                        Container(
                          width: logoSize, 
                          height: logoSize,
                          decoration: const BoxDecoration(
                            color: Colors.black, 
                            shape: BoxShape.circle,
                          ),
                        ),
                        
                        // Rotator
                        AnimatedBuilder(
                          animation: _rotationController,
                          builder: (context, child) {
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001) 
                                ..rotateX(_rotationController.value),
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
            
            // 4. Glare Overlay (Top Layer)
            Positioned.fill(
                child: IgnorePointer( // Don't block touches
                    child: AnimatedBuilder(
                        animation: _glareController,
                        builder: (context, child) {
                            // Sweep gradient across
                            return ShaderMask(
                                shaderCallback: (rect) {
                                    return LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                            Colors.white.withOpacity(0.0),
                                            Colors.white.withOpacity(0.2), // The shine
                                            Colors.white.withOpacity(0.0),
                                        ],
                                        stops: [
                                            _glareController.value - 0.2,
                                            _glareController.value,
                                            _glareController.value + 0.2,
                                        ],
                                        transform: const GradientRotation(0.5), // slight tilt
                                    ).createShader(rect);
                                },
                                blendMode: BlendMode.overlay, // Adds brightness
                                child: Container(
                                   color: Colors.transparent, // Needed for ShaderMask? 
                                   // Actually ShaderMask masks the child. We want to DRAW a gradient on top.
                                   // Better approach: Container with Gradient decoration + BlendMode
                                ),
                            );
                        },
                        // Alternative Glare Implementation: 
                        // A white container with gradient opacity that moves.
                        child: Container(),
                    ),
                ),
            ),
            // Let's try a simpler overlay approach for Glare that works reliably
             Positioned.fill(
                child: IgnorePointer(
                    child: AnimatedBuilder(
                        animation: _glareController,
                        builder: (context, child) {
                           // 0.0 to 1.0 sweep
                           // 4 seconds duration. Let's make it sweep quickly then wait.
                           // interval: 0.0-0.3 sweep, 0.3-1.0 wait
                           double t = _glareController.value;
                           double offset = -1.0 + (t * 3.0); // -1 to 2 range roughly
                           
                           return Container(
                               decoration: BoxDecoration(
                                   gradient: LinearGradient(
                                       begin: Alignment(-2.0 + offset, -1.0),
                                       end: Alignment(offset, 1.0),
                                       colors: [
                                           Colors.transparent,
                                           Colors.white.withOpacity(0.15),
                                           Colors.transparent,
                                       ],
                                       stops: const [0.0, 0.5, 1.0]
                                   ),
                               ),
                           );
                        }
                    )
                )
             )
          ],
        ),
      ),
    );
  }
}
