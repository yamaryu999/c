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

  // Data for the 4 Cards
  final List<MidasCardData> cards = [
    // 1. Yoga Kimimaro (Black)
    MidasCardData(
      assetImagePath: "assets/card_yoga.jpg",
      emblemPainter: const MsyuEmblemPainter(),
    ),
    // 2. Mikuni Souichiro (Purple)
    MidasCardData(
      assetImagePath: "assets/card_mikuni.jpg",
      emblemPainter: const QqwkEmblemPainter(),
    ),
    // 3. Jennifer Satou (Gold)
    MidasCardData(
      assetImagePath: "assets/card_jennifer.jpg",
      emblemPainter: const GeorgesEmblemPainter(),
    ),
    // 4. Senzaki Kou (Silver)
    MidasCardData(
      assetImagePath: "assets/card_senzaki.jpg",
      emblemPainter: const LiltEmblemPainter(),
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
  final CustomPainter emblemPainter;

  MidasCardData({
    required this.assetImagePath,
    required this.emblemPainter,
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
            
            // 2. Rotating Center Emblem (3D)
            // We adding a black circle behind it to hide the static logo in the photo
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: height * 0.75, 
                  height: height * 0.75,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Mask to hide the photo's emblem
                      Container(
                        width: height * 0.65, 
                        height: height * 0.65,
                        decoration: const BoxDecoration(
                          color: Colors.black, // or dark grey depending on card
                          shape: BoxShape.circle,
                        ),
                      ),
                      
                      // The Animated Emblem
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // Perspective
                              ..rotateX(_controller.value * 2 * math.pi), // X-Axis Rotation (Vertical flip)
                            child: child,
                          );
                        },
                        child: CustomPaint(
                            size: Size.infinite,
                            painter: widget.data.emblemPainter,
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

// --------------------------------------------------------------------------
// Painters (Kept same as before roughly)
// --------------------------------------------------------------------------

class MsyuEmblemPainter extends CustomPainter {
  const MsyuEmblemPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    final starPaint = Paint()
      ..shader = LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade100, Colors.grey.shade500])
          .createShader(Rect.fromCircle(center: center, radius: radius));
    
    drawStar(canvas, center, radius, starPaint);

    final faceRadius = radius * 0.65;
    canvas.drawCircle(center, faceRadius, Paint()..color = const Color(0xFF111111));
    
    final facePaint = Paint()
      ..shader = LinearGradient(colors: [const Color(0xFFCFB53B), const Color(0xFFDAA520)])
          .createShader(Rect.fromCircle(center: center, radius: faceRadius));
    
    final path = Path();
    path.moveTo(center.dx, center.dy - faceRadius * 0.95);
    path.arcToPoint(Offset(center.dx, center.dy + faceRadius * 0.95), radius: Radius.circular(faceRadius*0.95), clockwise: false);
    path.quadraticBezierTo(center.dx - faceRadius * 0.3, center.dy, center.dx, center.dy - faceRadius * 0.95);
    path.close();
    canvas.drawPath(path, facePaint);
    canvas.drawCircle(Offset(center.dx - faceRadius * 0.3, center.dy - faceRadius * 0.1), faceRadius * 0.08, Paint()..color = Colors.black);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QqwkEmblemPainter extends CustomPainter {
  const QqwkEmblemPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    canvas.drawCircle(center, radius, Paint()..color = Colors.black45);

    final octoPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF9C27B0), Color(0xFF00FF00)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final path = Path();
    path.addOval(Rect.fromCenter(center: Offset(center.dx, center.dy - radius * 0.3), width: radius * 0.8, height: radius * 0.8));
    final r = radius;
    path.moveTo(center.dx - r * 0.4, center.dy);
    path.quadraticBezierTo(center.dx - r * 0.8, center.dy + r * 0.5, center.dx - r * 0.3, center.dy + r * 0.8);
    path.moveTo(center.dx + r * 0.4, center.dy);
    path.quadraticBezierTo(center.dx + r * 0.8, center.dy + r * 0.5, center.dx + r * 0.3, center.dy + r * 0.8);
    
    canvas.drawPath(path, octoPaint);
    canvas.drawPath(path, Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 2);
    
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - radius * 0.15, center.dy - radius * 0.3), radius * 0.05, eyePaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.15, center.dy - radius * 0.3), radius * 0.05, eyePaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GeorgesEmblemPainter extends CustomPainter {
  const GeorgesEmblemPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    final moonPaint = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFFE6E6FA), Color(0xFF9370DB)])
      .createShader(Rect.fromCircle(center: center, radius: radius));
    
    final path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius * 0.9));
    canvas.drawPath(path, moonPaint);
    
    final detailPath = Path();
    detailPath.moveTo(center.dx - radius * 0.5, center.dy - radius * 0.5);
    detailPath.quadraticBezierTo(center.dx, center.dy, center.dx - radius * 0.5, center.dy + radius * 0.5);
    canvas.drawPath(detailPath, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LiltEmblemPainter extends CustomPainter {
  const LiltEmblemPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final starPaint = Paint()..color = const Color(0xFFDA70D6).withOpacity(0.5)..style = PaintingStyle.fill;
    drawStar(canvas, center, radius, starPaint);

    final skullPaint = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFF4B0082), Color(0xFF000000)])
       .createShader(Rect.fromCircle(center: center, radius: radius));
       
    final skullPath = Path();
    skullPath.addOval(Rect.fromCenter(center: Offset(center.dx, center.dy - radius * 0.1), width: radius * 0.8, height: radius * 0.7));
    skullPath.addRect(Rect.fromCenter(center: Offset(center.dx, center.dy + radius * 0.4), width: radius * 0.5, height: radius * 0.4));
    
    canvas.drawPath(skullPath, skullPaint);
    canvas.drawCircle(Offset(center.dx - radius * 0.2, center.dy), radius * 0.1, Paint()..color = Colors.white70);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path1 = Path();
    for (int i = 0; i < 3; i++) {
        double angle = -math.pi / 2 + (i * 2 * math.pi / 3);
        double x = center.dx + radius * math.cos(angle);
        double y = center.dy + radius * math.sin(angle);
        if (i == 0) path1.moveTo(x, y); else path1.lineTo(x, y);
    }
    path1.close();
    
    final path2 = Path();
    for (int i = 0; i < 3; i++) {
        double angle = -math.pi / 2 + (i * 2 * math.pi / 3) + math.pi;
        double x = center.dx + radius * math.cos(angle);
        double y = center.dy + radius * math.sin(angle);
        if (i == 0) path2.moveTo(x, y); else path2.lineTo(x, y);
    }
    path2.close();
    
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
}
