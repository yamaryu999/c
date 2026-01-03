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
    // 1. Yoga Kimimaro (Black/Dark Grey) - MSYU
    MidasCardData(
      ownerNameEn: "YOGA KIMIMARO",
      ownerNameJp: "ヨガ キミマロ",
      idNumber: "0666-392-2272719",
      assetName: "MSYU", // Mashu
      themeGradient: const LinearGradient(
        colors: [Color(0xFF2A2A2A), Color(0xFF111111), Color(0xFF1C1C1C), Color(0xFF080808)],
        stops: [0.0, 0.4, 0.7, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      assetColor: const Color(0xFFD4AF37),
      emblemPainter: const MsyuEmblemPainter(),
    ),
    // 2. Mikuni Souichiro (Purple) - QFWK
    MidasCardData(
      ownerNameEn: "MIKUNI SOUICHIRO",
      ownerNameJp: "ミクニ ソウイチロウ",
      idNumber: "0666-392-3513129",
      assetName: "QFWK", // Q
      themeGradient: const LinearGradient(
        colors: [Color(0xFF3B1E40), Color(0xFF1A0B20), Color(0xFF2D1630), Color(0xFF100510)],
        stops: [0.0, 0.4, 0.7, 1.0],
         begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      assetColor: const Color(0xFFD4AF37), // Still Goldish for Asset Name
      emblemPainter: const QqwkEmblemPainter(),
    ),
    // 3. Jennifer Satou (Gold) - WW.TF (Georges?)
    MidasCardData(
      ownerNameEn: "JENNIFER SATOU",
      ownerNameJp: "ジェニファー サトウ",
      idNumber: "0666-392-3145233",
      assetName: "WW.TF", // Looks like WW.TF in image, or GEORGES in lore. Using Image text.
      themeGradient: const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFDAA520), Color(0xFFB8860B), Color(0xFFA0522D)],
         begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      assetColor: Colors.black87, // Dark text on Gold
      emblemPainter: const GeorgesEmblemPainter(),
      isDarkText: true,
    ),
    // 4. Senzaki Kou (Silver) - LILT
    MidasCardData(
      ownerNameEn: "SENZAKI KOU",
      ownerNameJp: "センノザ コウ",
      idNumber: "0666-392-1224740",
      assetName: "LILT", // Angel-like
      themeGradient: const LinearGradient(
        colors: [Color(0xFFE0E0E0), Color(0xFFB0B0B0), Color(0xFFD3D3D3), Color(0xFF808080)],
         begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      assetColor: const Color(0xFFDAA520),
      emblemPainter: const LiltEmblemPainter(),
      isDarkText: true,
      logoColor: const Color(0xFFB22222), // Red logo for Senzaki
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
  final String ownerNameEn;
  final String ownerNameJp;
  final String idNumber;
  final String assetName;
  final Gradient themeGradient;
  final Color assetColor;
  final CustomPainter emblemPainter;
  final bool isDarkText; // For Gold/Silver cards, text might need to be dark
  final Color logoColor;

  MidasCardData({
    required this.ownerNameEn,
    required this.ownerNameJp,
    required this.idNumber,
    required this.assetName,
    required this.themeGradient,
    required this.assetColor,
    required this.emblemPainter,
    this.isDarkText = false,
    this.logoColor = const Color(0xFF888888),
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
        vsync: this, duration: const Duration(seconds: 12)) // Slow rotation
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

    final textColor = widget.data.isDarkText ? Colors.black87 : Colors.white70;
    final nameColor = widget.data.isDarkText ? Colors.black : Colors.white;

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
            // 1. Background
            Positioned.fill(
              child: CustomPaint(
                painter: MidasCardBackgroundPainter(widget.data.themeGradient),
              ),
            ),
            
            // 2. Rotating Center Emblem (3D)
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: height * 0.75, 
                  height: height * 0.75,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // Perspective
                          ..rotateY(_controller.value * 2 * math.pi), // Y-Axis Rotation
                        child: child,
                      );
                    },
                    child: CustomPaint(
                        size: Size.infinite,
                        painter: widget.data.emblemPainter,
                    ),
                  ),
                ),
              ),
            ),

            // 3. Left Logo
            Positioned(
              left: width * 0.05,
              top: height * 0.25,
              bottom: height * 0.25,
              child: SizedBox(
                width: width * 0.15,
                child: CustomPaint(
                  painter: FinancialDistrictLogoPainter(color: widget.data.logoColor),
                ),
              ),
            ),

            // 4. Direction Arrow
            Positioned(
              left: 12,
              top: 12,
              child: CustomPaint(
                size: const Size(12, 12),
                painter: ArrowPainter(color: widget.data.isDarkText ? Colors.black : const Color(0xFFD4AF37)),
              ),
            ),

            // 5. Info Text
            Positioned(
              left: 16,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text(
                    widget.data.idNumber,
                    style: GoogleFonts.shareTechMono(
                      color: textColor,
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.data.ownerNameEn,
                    style: GoogleFonts.notoSans(
                      color: nameColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                   Text(
                    widget.data.ownerNameJp,
                     style: GoogleFonts.notoSansJp(
                      color: textColor,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),

            // 6. Asset Name
            Positioned(
              right: 16,
              bottom: 12,
              child: Text(
                widget.data.assetName,
                style: GoogleFonts.vt323(
                  color: widget.data.assetColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  shadows: widget.data.isDarkText ? [] : [
                    const Shadow(
                      color: Colors.black,
                      offset: Offset(1, 1),
                      blurRadius: 1,
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

// --------------------------------------------------------------------------
// Painters
// --------------------------------------------------------------------------

class MidasCardBackgroundPainter extends CustomPainter {
  final Gradient gradient;
  MidasCardBackgroundPainter(this.gradient);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Noise
    final noisePaint = Paint()..strokeWidth = 1.0;
    final random = math.Random(42);
    for (int i = 0; i < 4000; i++) {
        double dx = random.nextDouble() * size.width;
        double dy = random.nextDouble() * size.height;
        double opacity = random.nextDouble() * 0.15;
        noisePaint.color = (random.nextBool() ? Colors.white : Colors.black).withOpacity(opacity);
        canvas.drawPoints(ui.PointMode.points, [Offset(dx, dy)], noisePaint);
    }
  }

  @override
  bool shouldRepaint(MidasCardBackgroundPainter oldDelegate) => false;
}

class ArrowPainter extends CustomPainter {
  final Color color;
  ArrowPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(0, size.height/2);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }
  @override
  bool shouldRepaint(ArrowPainter oldDelegate) => false;
}

class FinancialDistrictLogoPainter extends CustomPainter {
  final Color color;
  FinancialDistrictLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final path = Path();
    
    path.moveTo(w * 0.2, h * 0.8);
    path.lineTo(w * 0.2, h * 0.2);
    path.moveTo(w * 0.5, h * 0.9);
    path.lineTo(w * 0.5, h * 0.1);
    path.moveTo(w * 0.1, h * 0.6);
    path.lineTo(w * 0.5, h * 0.4);
    path.lineTo(w * 0.9, h * 0.6);
    path.moveTo(w * 0.3, h * 0.3);
    path.quadraticBezierTo(w * 0.5, h * 0.5, w * 0.7, h * 0.3);

    final accentPath = Path()
      ..moveTo(w * 0.0, h * 0.1)
      ..lineTo(w * 0.15, h * 0.1)
      ..lineTo(w * 0.075, h * 0.25)
      ..close();
    
    canvas.drawPath(path, paint);
    canvas.drawPath(accentPath, Paint()..color = const Color(0xFFFFD700)..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- Specific Emblem Painters ---

// 1. MSYU (Yoga)
class MsyuEmblemPainter extends CustomPainter {
  const MsyuEmblemPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Hexagram
    final starPaint = Paint()
      ..shader = LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade100, Colors.grey.shade500])
          .createShader(Rect.fromCircle(center: center, radius: radius));
    
    drawStar(canvas, center, radius, starPaint);

    // Face
    final faceRadius = radius * 0.65;
    canvas.drawCircle(center, faceRadius, Paint()..color = const Color(0xFF111111));
    
    // Profile
    final facePaint = Paint()
      ..shader = LinearGradient(colors: [const Color(0xFFCFB53B), const Color(0xFFDAA520)])
          .createShader(Rect.fromCircle(center: center, radius: faceRadius));
    
    final path = Path();
    path.moveTo(center.dx, center.dy - faceRadius * 0.95);
    path.arcToPoint(Offset(center.dx, center.dy + faceRadius * 0.95), radius: Radius.circular(faceRadius*0.95), clockwise: false);
    
    // Simple profile
    path.quadraticBezierTo(center.dx - faceRadius * 0.3, center.dy, center.dx, center.dy - faceRadius * 0.95);
    path.close();
    canvas.drawPath(path, facePaint);
    
    // Details
    canvas.drawCircle(Offset(center.dx - faceRadius * 0.3, center.dy - faceRadius * 0.1), faceRadius * 0.08, Paint()..color = Colors.black);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. QFWK (Mikuni) - Octopus/Cthulhu
class QqwkEmblemPainter extends CustomPainter {
  const QqwkEmblemPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Background circle (Darker)
    canvas.drawCircle(center, radius, Paint()..color = Colors.black45);

    // Octopus Shape (Green/Purple iridescent)
    final octoPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF9C27B0), Color(0xFF00FF00)], // Purple to Green
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final path = Path();
    // Head
    path.addOval(Rect.fromCenter(center: Offset(center.dx, center.dy - radius * 0.3), width: radius * 0.8, height: radius * 0.8));
    
    // Tentacles (Simulated)
    final r = radius;
    path.moveTo(center.dx - r * 0.4, center.dy);
    path.quadraticBezierTo(center.dx - r * 0.8, center.dy + r * 0.5, center.dx - r * 0.3, center.dy + r * 0.8);
    path.moveTo(center.dx + r * 0.4, center.dy);
    path.quadraticBezierTo(center.dx + r * 0.8, center.dy + r * 0.5, center.dx + r * 0.3, center.dy + r * 0.8);
    
    // Fill
    canvas.drawPath(path, octoPaint);
    // Stroke
    canvas.drawPath(path, Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 2);
    
    // Eyes (Multiple)
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - radius * 0.15, center.dy - radius * 0.3), radius * 0.05, eyePaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.15, center.dy - radius * 0.3), radius * 0.05, eyePaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 3. WW.TF (Jennifer) - Big Moon
class GeorgesEmblemPainter extends CustomPainter {
  const GeorgesEmblemPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Large Moon filling the circle
    final moonPaint = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFFE6E6FA), Color(0xFF9370DB)]) // Lavender/Purple tint
      .createShader(Rect.fromCircle(center: center, radius: radius));
    
    final path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius * 0.9));
    canvas.drawPath(path, moonPaint);
    
    // Profile Cutter (Negative space or overlay)
    // Actually looking at image, it's a Gold background with a Purple Moon Face.
    // My Card Theme is Gold. The emblem is a Purple Moon.
    
    // Face details
    final detailPath = Path();
    // Large nose profile
    detailPath.moveTo(center.dx - radius * 0.5, center.dy - radius * 0.5);
    detailPath.quadraticBezierTo(center.dx, center.dy, center.dx - radius * 0.5, center.dy + radius * 0.5);
    
    canvas.drawPath(detailPath, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 4. LILT (Senzaki) - Skull & Pentagram
class LiltEmblemPainter extends CustomPainter {
  const LiltEmblemPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Hexagram (Purple/Pink lines)
    final starPaint = Paint()..color = const Color(0xFFDA70D6).withOpacity(0.5)..style = PaintingStyle.fill;
    drawStar(canvas, center, radius, starPaint);

    // Skull
    final skullPaint = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFF4B0082), Color(0xFF000000)])
       .createShader(Rect.fromCircle(center: center, radius: radius));
       
    final skullPath = Path();
    // Cranium
    skullPath.addOval(Rect.fromCenter(center: Offset(center.dx, center.dy - radius * 0.1), width: radius * 0.8, height: radius * 0.7));
    // Jaw
    skullPath.addRect(Rect.fromCenter(center: Offset(center.dx, center.dy + radius * 0.4), width: radius * 0.5, height: radius * 0.4));
    
    canvas.drawPath(skullPath, skullPaint);
    
    // Eye Sockets
    canvas.drawCircle(Offset(center.dx - radius * 0.2, center.dy), radius * 0.1, Paint()..color = Colors.white70);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Helper
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
