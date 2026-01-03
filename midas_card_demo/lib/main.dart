import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
// Note: Add google_fonts: ^6.1.0 to your pubspec.yaml
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
        body: Center(
          child: MidasCard(),
        ),
      ),
    );
  }
}

class MidasCard extends StatefulWidget {
  const MidasCard({super.key});

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
        vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Credit card standard aspect ratio
    const double aspectRatio = 1.586;
    // Base width (responsive)
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
          BoxShadow(
            color: const Color(0xFF1A1A1A).withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: -2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // 1. Background Texture & Gradient
            Positioned.fill(
              child: CustomPaint(
                painter: MidasCardBackgroundPainter(),
              ),
            ),
            
            // 2. Center Emblem (Behind Glow + Rotating Symbol)
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: height * 0.75, // Emblem size relative to card height
                  height: height * 0.75,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow
                          /*
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.1 +
                                      0.05 * sin(_controller.value * 2 * pi)),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          */
                          // Rotating Element
                          Transform.rotate(
                            angle: _controller.value * 2 * math.pi,
                            child: CustomPaint(
                              size: Size.infinite,
                              painter: MidasEmblemPainter(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // 3. Left Logo (ADA / Financial District)
            Positioned(
              left: width * 0.05,
              top: height * 0.25,
              bottom: height * 0.25,
              child: SizedBox(
                width: width * 0.15,
                child: CustomPaint(
                  painter: FinancialDistrictLogoPainter(),
                ),
              ),
            ),

            // 4. Direction Arrow (Top Left)
            Positioned(
              left: 12,
              top: 12,
              child: CustomPaint(
                size: const Size(12, 12),
                painter: ArrowPainter(),
              ),
            ),

            // 5. Bottom Left Text (ID & Name)
            Positioned(
              left: 16,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text(
                    '0666-392-2272719',
                    style: GoogleFonts.shareTechMono(
                      color: Colors.white70,
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'YOGA KIMIMARO',
                    style: GoogleFonts.notoSans( // Fallback sans
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                   Text(
                    'ヨガ キミマロ',
                     style: GoogleFonts.notoSansJp(
                      color: Colors.white54,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),

            // 6. Bottom Right Text (Asset Name)
            Positioned(
              right: 16,
              bottom: 12,
              child: Text(
                'MSYU',
                style: GoogleFonts.vt323( // Pixel-like font
                  color: const Color(0xFFD4AF37), // Goldish
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  shadows: [
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
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Base Dark Gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF2A2A2A),
        const Color(0xFF111111),
        const Color(0xFF1C1C1C),
        const Color(0xFF080808),
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // 2. Noise Texture Simulation
    // We draw random tiny specs to simulate the matte metal surface
    final noisePaint = Paint()..strokeWidth = 1.0;
    final random = math.Random(42); // Fixed seed for stability

    for (int i = 0; i < 4000; i++) {
        double dx = random.nextDouble() * size.width;
        double dy = random.nextDouble() * size.height;
        double opacity = random.nextDouble() * 0.15;
        // Mix of white and black noise
        noisePaint.color = (random.nextBool() ? Colors.white : Colors.black).withOpacity(opacity);
        canvas.drawPoints(ui.PointMode.points, [Offset(dx, dy)], noisePaint);
    }
    
    // 3. Subtle Metallic Sheen (Sweep)
    // Adds a diagonal lighting strip
    final sheenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.05),
          Colors.transparent,
        ],
        stops: const [0.3, 0.5, 0.7],
      ).createShader(rect)
      ..blendMode = BlendMode.overlay;
      
    canvas.drawRect(rect, sheenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(0, size.height/2);
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, Paint()..color = const Color(0xFFD4AF37)); // Gold Arrow
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class FinancialDistrictLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // "ADA" or "AVA" style abstract logo
    // It looks like an 'M' combined with 'A' intertwined.
    final paint = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Approximate structure: Three verticals intertwined
    final path = Path();
    
    // Left vertical-ish
    path.moveTo(w * 0.2, h * 0.8);
    path.lineTo(w * 0.2, h * 0.2);
    
    // Middle components
    path.moveTo(w * 0.5, h * 0.9);
    path.lineTo(w * 0.5, h * 0.1);
    
    // Connected angular strokes
    path.moveTo(w * 0.1, h * 0.6);
    path.lineTo(w * 0.5, h * 0.4);
    path.lineTo(w * 0.9, h * 0.6);
    
    // Another crossing
    path.moveTo(w * 0.3, h * 0.3);
    path.quadraticBezierTo(w * 0.5, h * 0.5, w * 0.7, h * 0.3);

    // Accent Triangle
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

class MidasEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // --- 1. Glow Effect (Behind) ---
    /*
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    glowPaint.color = Colors.amber.withOpacity(0.2);
    canvas.drawCircle(center, radius * 0.9, glowPaint);
    */

    // --- 2. Hexagram (Six-pointed star) ---
    // Two equilateral triangles
    final starPaint = Paint()
      ..color = const Color(0xFFC0C0C0) // Silver/Grey base
      ..style = PaintingStyle.fill;
      
    // Create specific shader for metallic look on star
    final starGradient = LinearGradient(
      colors: [Colors.grey.shade400, Colors.grey.shade100, Colors.grey.shade500],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    starPaint.shader = starGradient.createShader(Rect.fromCircle(center: center, radius: radius));

    final pathTriangle1 = Path();
    final pathTriangle2 = Path();

    // Triangle pointing up
    final rStar = radius; // Star radius
    for (int i = 0; i < 3; i++) {
        double angle = -math.pi / 2 + (i * 2 * math.pi / 3);
        double x = center.dx + rStar * math.cos(angle);
        double y = center.dy + rStar * math.sin(angle);
        if (i == 0) pathTriangle1.moveTo(x, y);
        else pathTriangle1.lineTo(x, y);
    }
    pathTriangle1.close();

    // Triangle pointing down
    for (int i = 0; i < 3; i++) {
        double angle = -math.pi / 2 + (i * 2 * math.pi / 3) + math.pi;
        double x = center.dx + rStar * math.cos(angle);
        double y = center.dy + rStar * math.sin(angle);
        if (i == 0) pathTriangle2.moveTo(x, y);
        else pathTriangle2.lineTo(x, y);
    }
    pathTriangle2.close();

    // Draw Star
    // We compose them using generic drawPath
    canvas.drawPath(pathTriangle1, starPaint);
    canvas.drawPath(pathTriangle2, starPaint);
    
    // Stroke for definition
    final strokePaint = Paint()
       ..color = Colors.black.withOpacity(0.8)
       ..style = PaintingStyle.stroke
       ..strokeWidth = 1.5;
    canvas.drawPath(pathTriangle1, strokePaint);
    canvas.drawPath(pathTriangle2, strokePaint);


    // --- 3. The Face (Sun/Moon Mask) ---
    // Circular bounds inside the star
    final faceRadius = rStar * 0.65;
    final faceRect = Rect.fromCircle(center: center, radius: faceRadius);
    
    // Face background (Dark circle)
    final faceBgPaint = Paint()..color = const Color(0xFF111111);
    canvas.drawCircle(center, faceRadius, faceBgPaint);

    // The Gold Face (Crescent / Profile)
    final facePaint = Paint();
    final faceGradient = LinearGradient(
      colors: [const Color(0xFFCFB53B), const Color(0xFFDAA520), const Color(0xFFB8860B)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    facePaint.shader = faceGradient.createShader(faceRect);

    final facePath = Path();
    // Draw a crescent moon shape with a profile
    // Start top
    facePath.moveTo(center.dx, center.dy - faceRadius * 0.95);
    
    // Outer arc (Left side of the face)
    facePath.arcToPoint(
        Offset(center.dx, center.dy + faceRadius * 0.95),
        radius: Radius.circular(faceRadius * 0.95),
        clockwise: false,
    );
    
    // Inner profile (The "Face")
    // Bottom chin -> mouth -> nose -> forehead
    // Simple stylized curve for now
    facePath.quadraticBezierTo(
        center.dx - faceRadius * 0.2, 
        center.dy + faceRadius * 0.5, 
        center.dx - faceRadius * 0.1, // Jaw
        center.dy + faceRadius * 0.3
    );
     facePath.quadraticBezierTo(
        center.dx + faceRadius * 0.2, // Nose tip x
        center.dy + faceRadius * 0.1, 
        center.dx - faceRadius * 0.1, // Nose bridge
        center.dy - faceRadius * 0.2
    );
    facePath.quadraticBezierTo(
        center.dx - faceRadius * 0.3,
        center.dy - faceRadius * 0.5,
        center.dx,
        center.dy - faceRadius * 0.95
    );
    facePath.close();

    canvas.drawPath(facePath, facePaint);
    
    // Face Details (Eye, Swirl)
    final detailPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
       
    // Eye
    canvas.drawCircle(Offset(center.dx - faceRadius * 0.3, center.dy - faceRadius * 0.1), faceRadius * 0.08, detailPaint);
    
    // Mouth/Swirl lines (Iconic curling mustache/beard)
    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
   final swirlPath = Path();
   swirlPath.moveTo(center.dx - faceRadius * 0.1, center.dy + faceRadius * 0.3); // Under nose
   // Spiral
   swirlPath.cubicTo(
       center.dx + faceRadius * 0.1, center.dy + faceRadius * 0.4, 
       center.dx + faceRadius * 0.1, center.dy + faceRadius * 0.6,
       center.dx - faceRadius * 0.1, center.dy + faceRadius * 0.6
   );
   canvas.drawPath(swirlPath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
