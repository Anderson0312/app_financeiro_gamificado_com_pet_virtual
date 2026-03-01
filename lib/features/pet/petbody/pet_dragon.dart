import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

import '../domain/models/pet.dart';
import '../domain/models/pet_colors.dart';

class FullBodyDragonWidget extends StatefulWidget {
  final PetMood mood;
  final double size;
  final PetColors? customColors;

  const FullBodyDragonWidget({
    Key? key,
    required this.mood,
    this.size = 300.0,
    this.customColors,
  }) : super(key: key);

  @override
  State<FullBodyDragonWidget> createState() => _FullBodyDragonWidgetState();
}

class _FullBodyDragonWidgetState extends State<FullBodyDragonWidget> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _tailController;
  late AnimationController _jumpController;
  late AnimationController _blinkController;
  late AnimationController _wingsController;
  late AnimationController _fireController;
  late AnimationController _smokeController;
  late AnimationController _shineController;
  late Animation<double> _tailAnimation;
  Timer? _blinkTimer;
  Timer? _fireTimer;

  // Espessura do contorno global
  final double _strokeW = 1.5; 

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _tailController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _tailAnimation = Tween<double>(begin: -0.15, end: 0.15).animate(CurvedAnimation(parent: _tailController, curve: Curves.easeInOutSine));
    _jumpController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _blinkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _startBlinking();

    _wingsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);

    _fireController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _smokeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat();
    _shineController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat();

    _startFireRoutine();
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 3000), (timer) {
      if (math.Random().nextBool() && widget.mood != PetMood.sad && mounted) {
        _blinkController.forward().then((_) => _blinkController.reverse());
      }
    });
  }

  void _startFireRoutine() {
    _fireTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted && widget.mood == PetMood.happy && math.Random().nextBool()) {
        _fireController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _fireTimer?.cancel();
    _breathingController.dispose(); 
    _tailController.dispose(); 
    _jumpController.dispose(); 
    _blinkController.dispose();
    _wingsController.dispose();
    _fireController.dispose();
    _smokeController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FullBodyDragonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mood == PetMood.happy) {
      if (oldWidget.mood != PetMood.happy) _jumpController.forward(from: 0.0).then((_) => _jumpController.reverse());
      _wingsController.duration = const Duration(milliseconds: 300);
    } else if (widget.mood == PetMood.sad) {
       _wingsController.duration = const Duration(milliseconds: 1500);
    } else {
       _wingsController.duration = const Duration(milliseconds: 800);
    }
    if(_wingsController.isAnimating) _wingsController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.customColors ?? PetColors.defaultDragon;
    final mainColor = colors.primaryColor;
    final bellyColor = colors.secondaryColor;
    final outlineColor = colors.outlineColor;
    
    final headSize = widget.size * 0.6;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _breathingController, 
        _tailController, 
        _jumpController, 
        _blinkController, 
        _wingsController,
        _fireController,
        _smokeController,
        _shineController,
      ]),
      builder: (context, child) {
        final jumpValue = Curves.elasticOut.transform(_jumpController.value);
        final jumpY = -50.0 * math.sin(jumpValue * math.pi);
        final breathScaleY = 1.0 + (_breathingController.value * 0.02);
        final breathScaleX = 1.0 + (_breathingController.value * 0.01);
        final jumpScaleY = 1.0 + (math.sin(jumpValue * math.pi) * 0.1);
        final jumpScaleX = 1.0 - (math.sin(jumpValue * math.pi) * 0.05);

        return Transform.translate(
          offset: Offset(0, jumpY),
          child: Transform.scale(
            scaleY: breathScaleY * jumpScaleY, scaleX: breathScaleX * jumpScaleX, alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: widget.size, height: widget.size,
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: widget.size * 0.25, 
                    left: widget.size * 0.02, 
                    child: CustomPaint(
                      size: const Size(120, 100),
                      painter: DragonWingPainter(mainColor, outlineColor, _strokeW, true, _wingsController.value),
                    ),
                  ),
                  Positioned(
                    top: widget.size * 0.25, 
                    right: widget.size * 0.02, 
                    child: CustomPaint(
                      size: const Size(120, 100),
                      painter: DragonWingPainter(mainColor, outlineColor, _strokeW, false, _wingsController.value),
                    ),
                  ),

                  Positioned(
                    bottom: widget.size * 0.15,
                    right: widget.size * 0.05,
                    child: CustomPaint(
                      size: const Size(100, 120),
                      painter: DragonTailPainter(mainColor, outlineColor, _strokeW, _tailController.value),
                    ),
                  ),

                  _buildBodyWithScales(mainColor, bellyColor, outlineColor),

                  Positioned(
                    top: widget.size * 0.05,
                    child: Transform.translate(
                      offset: Offset(0, _breathingController.value * 4),
                      child: SizedBox(
                        width: headSize, height: headSize,
                        child: Stack(
                           alignment: Alignment.center,
                           clipBehavior: Clip.none,
                           children: [
                             Positioned(top: -headSize * 0.1, left: headSize * 0.15, child: _buildHorn(Colors.amber[200]!, outlineColor, headSize)),
                             Positioned(top: -headSize * 0.1, right: headSize * 0.15, child: _buildHorn(Colors.amber[200]!, outlineColor, headSize)),
                             
                             Container(
                               width: headSize, 
                               height: headSize * 0.85, 
                               decoration: BoxDecoration(
                                 color: mainColor, 
                                 borderRadius: BorderRadius.circular(headSize * 0.45), 
                                 border: Border.all(color: outlineColor, width: _strokeW),
                               ),
                             ),

                             Positioned(
                               top: headSize * 0.35,
                               child: _buildKawaiiEyes(headSize),
                             ),

                             Positioned(
                               bottom: headSize * 0.25,
                               child: Stack(
                                 alignment: Alignment.center,
                                 clipBehavior: Clip.none,
                                 children: [
                                   Row(
                                     children: [
                                       _nostril(outlineColor),
                                       const SizedBox(width: 20),
                                       _nostril(outlineColor),
                                     ],
                                   ),
                                   if (widget.mood != PetMood.sad)
                                     Positioned(
                                       top: -10,
                                       child: CustomPaint(
                                         size: const Size(40, 40),
                                         painter: SmokePainter(_smokeController.value),
                                       ),
                                     ),
                                 ],
                               ),
                             ),

                             Positioned(
                               bottom: headSize * 0.05,
                               child: Stack(
                                 alignment: Alignment.topCenter,
                                 clipBehavior: Clip.none,
                                 children: [
                                   if (_fireController.isAnimating)
                                     Positioned(
                                       top: 5,
                                       child: CustomPaint(
                                         size: const Size(120, 180),
                                         painter: FireBreathPainter(_fireController.value),
                                       ),
                                     ),
                                   CustomPaint(
                                     size: const Size(28, 12),
                                     painter: DragonMouthPainter(outlineColor, _strokeW),
                                   ),
                                 ],
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
          ),
        );
      },
    );
  }

  Widget _buildHorn(Color color, Color outline, double headSize) => Container(
    width: headSize * 0.15, 
    height: headSize * 0.25, 
    decoration: BoxDecoration(
      color: color, 
      borderRadius: const BorderRadius.vertical(top: Radius.circular(5), bottom: Radius.circular(15)), 
      border: Border.all(color: outline, width: _strokeW),
    ),
  );

  Widget _nostril(Color color) => Container(
    width: 4, height: 4, 
    decoration: BoxDecoration(color: color.withOpacity(0.5), shape: BoxShape.circle),
  );

  Widget _buildKawaiiEyes(double headSize) {
    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, child) {
        final blinkValue = _blinkController.value;
        final eyeHeight = 32.0 * (1.0 - blinkValue);
        final eyeWidth = 32.0;

        return SizedBox(
          width: headSize * 0.65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _kawaiiEye(eyeWidth, eyeHeight),
              _kawaiiEye(eyeWidth, eyeHeight),
            ],
          ),
        );
      },
    );
  }

  Widget _kawaiiEye(double width, double height) {
    return Container(
      width: width,
      height: height < 2 ? 2 : height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(width),
      ),
      child: height > 12 ? Stack(
        children: [
          Positioned(
            top: 4, left: 6,
            child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
          Positioned(
            bottom: 4, right: 6,
            child: Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ],
      ) : null,
    );
  }

  Widget _buildBodyWithScales(Color main, Color belly, Color outline) {
      return Positioned(
        bottom: 20, 
        child: Container(
          width: 150, height: 170, 
          decoration: BoxDecoration(
            color: main, 
            borderRadius: BorderRadius.circular(60), 
            border: Border.all(color: outline, width: _strokeW),
          ), 
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 10,
                child: Container(
                  width: 100, height: 130, 
                  decoration: BoxDecoration(
                    color: belly, 
                    borderRadius: BorderRadius.circular(45),
                    border: Border.all(color: outline.withOpacity(0.2), width: 1),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: ScalesShinePainter(_shineController.value),
                ),
              ),
              Positioned(
                bottom: -5,
                child: Row(
                  children: [
                    _buildDragonPaw(main, outline),
                    const SizedBox(width: 60),
                    _buildDragonPaw(main, outline),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildDragonPaw(Color color, Color outline) => Container(
    width: 35, height: 20,
    decoration: BoxDecoration(
      color: color, 
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: outline, width: _strokeW),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (i) => Container(width: 2, height: 6, color: outline.withOpacity(0.4))),
    ),
  );
}

class DragonMouthPainter extends CustomPainter {
  final Color color;
  final double strokeW;
  DragonMouthPainter(this.color, this.strokeW);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.25, size.height, size.width / 2, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.75, size.height, size.width, size.height * 0.2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DragonTailPainter extends CustomPainter {
  final Color color;
  final Color outline;
  final double strokeW;
  final double animation;
  DragonTailPainter(this.color, this.outline, this.strokeW, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final paintOutline = Paint()..color = outline..strokeWidth = strokeW..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

    final path = Path();
    final wave = math.sin(animation * math.pi * 2) * 15;
    
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2 + wave, size.height * 0.4, size.width * 0.6 + wave, 0);
    path.lineTo(size.width * 0.9 + wave, size.height * 0.1);
    path.lineTo(size.width * 0.7 + wave, size.height * 0.3);
    path.lineTo(size.width * 0.8 + wave, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.3 + wave, size.height * 0.7, 0, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, paintOutline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DragonWingPainter extends CustomPainter {
  final Color color;
  final Color outline;
  final double strokeW;
  final bool isLeft;
  final double flap;
  DragonWingPainter(this.color, this.outline, this.strokeW, this.isLeft, this.flap);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final paintOutline = Paint()..color = outline..strokeWidth = strokeW..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

    final flapEffect = math.sin(flap * math.pi) * 20;
    final path = Path();
    
    if (isLeft) {
      path.moveTo(size.width, size.height);
      path.quadraticBezierTo(-flapEffect, size.height * 0.8, 0, flapEffect);
      path.quadraticBezierTo(size.width * 0.5, size.height * 0.2 + flapEffect, size.width, size.height * 0.5);
    } else {
      path.moveTo(0, size.height);
      path.quadraticBezierTo(size.width + flapEffect, size.height * 0.8, size.width, flapEffect);
      path.quadraticBezierTo(size.width * 0.5, size.height * 0.2 + flapEffect, 0, size.height * 0.5);
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, paintOutline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FireBreathPainter extends CustomPainter {
  final double animation;
  FireBreathPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42);
    for (int i = 0; i < 15; i++) {
      final p = (animation + rand.nextDouble()) % 1.0;
      final x = size.width / 2 + (rand.nextDouble() - 0.5) * size.width * p;
      final y = p * size.height;
      final radius = (1.0 - p) * 25;
      
      final paint = Paint()
        ..color = Color.lerp(Colors.yellow, Colors.red, p)!.withOpacity(1.0 - p)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SmokePainter extends CustomPainter {
  final double animation;
  SmokePainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity((1.0 - animation) * 0.3)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 3; i++) {
      final offset = (animation + (i * 0.3)) % 1.0;
      final y = size.height * (1.0 - offset);
      final radius = offset * 15;
      canvas.drawCircle(Offset(size.width * 0.2, y), radius, paint);
      canvas.drawCircle(Offset(size.width * 0.8, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ScalesShinePainter extends CustomPainter {
  final double animation;
  ScalesShinePainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0),
          Colors.white.withOpacity(0.4),
          Colors.white.withOpacity(0),
        ],
        stops: [
          (animation - 0.2).clamp(0, 1),
          animation.clamp(0, 1),
          (animation + 0.2).clamp(0, 1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
