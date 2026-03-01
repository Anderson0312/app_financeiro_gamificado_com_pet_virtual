import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

import '../domain/models/pet.dart';
import '../domain/models/pet_colors.dart';

class FullBodyDogWidget extends StatefulWidget {
  final PetMood mood;
  final double size;
  final PetColors? customColors;

  const FullBodyDogWidget({
    Key? key,
    required this.mood,
    this.size = 300.0,
    this.customColors,
  }) : super(key: key);

  @override
  State<FullBodyDogWidget> createState() => _FullBodyDogWidgetState();
}

class _FullBodyDogWidgetState extends State<FullBodyDogWidget> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _tailController;
  late AnimationController _jumpController;
  late AnimationController _blinkController;
  late AnimationController _tongueController;
  late Animation<double> _tailAnimation;
  Timer? _blinkTimer;
  Timer? _tongueTimer;

  // Variável para controlar a espessura do contorno globalmente (reduzido como no cat)
  final double _strokeW = 1.5; 

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _tailController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
    _tailAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(CurvedAnimation(parent: _tailController, curve: Curves.easeInOutSine));
    _jumpController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _blinkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _tongueController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _startBlinking();
    _startPanting();
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 4000), (timer) {
      if (math.Random().nextBool() && widget.mood != PetMood.sad && mounted) {
        _blinkController.forward().then((_) => _blinkController.reverse());
      }
    });
  }

  void _startPanting() {
    _tongueTimer = Timer.periodic(const Duration(milliseconds: 5000), (timer) {
      if (math.Random().nextBool() && widget.mood != PetMood.sad && mounted) {
        _tongueController.repeat(reverse: true, period: const Duration(milliseconds: 200));
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _tongueController.stop();
        });
      }
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _tongueTimer?.cancel();
    _breathingController.dispose();
    _tailController.dispose();
    _jumpController.dispose();
    _blinkController.dispose();
    _tongueController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FullBodyDogWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mood == PetMood.happy && oldWidget.mood != PetMood.happy) {
      _jumpController.forward(from: 0.0).then((_) => _jumpController.reverse());
      _tailController.duration = const Duration(milliseconds: 200);
    } else if (widget.mood == PetMood.sad) {
      _tailController.duration = const Duration(milliseconds: 1500);
    } else {
      _tailController.duration = const Duration(milliseconds: 500);
    }
    if(_tailController.isAnimating) _tailController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.customColors ?? PetColors.defaultDog;
    final mainColor = colors.primaryColor;
    final secondaryColor = colors.secondaryColor;
    final outlineColor = colors.outlineColor;
    
    bool showTongue = widget.mood == PetMood.happy;

    final headSize = widget.size * 0.6;
    final bodyWidth = widget.size * 0.5;
    final bodyHeight = widget.size * 0.55;

    return AnimatedBuilder(
      animation: Listenable.merge([_breathingController, _tailController, _jumpController, _blinkController, _tongueController]),
      builder: (context, child) {
        final jumpValue = Curves.elasticOut.transform(_jumpController.value);
        final jumpY = -45.0 * math.sin(jumpValue * math.pi);
        final breathScaleY = 1.0 + (_breathingController.value * 0.03);
        final breathScaleX = 1.0 + (_breathingController.value * 0.01);
        final jumpScaleY = 1.0 + (math.sin(jumpValue * math.pi) * 0.15);
        final jumpScaleX = 1.0 - (math.sin(jumpValue * math.pi) * 0.08);

        return Transform.translate(
          offset: Offset(0, jumpY),
          child: Transform.scale(
            scaleY: breathScaleY * jumpScaleY,
            scaleX: breathScaleX * jumpScaleX,
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: widget.size, height: widget.size,
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  // RABO
                  Positioned(
                    bottom: bodyHeight * 0.1,
                    right: widget.size * 0.1,
                    child: Transform.rotate(
                      angle: _tailAnimation.value * (widget.mood == PetMood.happy ? 3.5 : 1.0),
                      alignment: Alignment.bottomLeft,
                      child: CustomPaint(
                        size: const Size(50, 40),
                        painter: DogTailPainter(mainColor, outlineColor, _strokeW),
                      ),
                    ),
                  ),
                  // CORPO E PATAS
                  _buildBodyAndLegs(bodyWidth, bodyHeight, mainColor, secondaryColor, outlineColor),
                  
                  // CABEÇA DO CACHORRO
                  Positioned(
                    top: widget.size * 0.08,
                    child: Transform.translate(
                      offset: Offset(0, _breathingController.value * 4),
                      child: SizedBox(
                        width: headSize, height: headSize,
                        child: Stack(
                           alignment: Alignment.center,
                           clipBehavior: Clip.none,
                           children: [
                             // Orelhas Caídas
                             Positioned(top: headSize*0.1, left: -10, child: Transform.rotate(angle: 0.2 + (showTongue ? _tailAnimation.value : 0), child: _buildFloppyEar(mainColor, outlineColor, headSize))),
                             Positioned(top: headSize*0.1, right: -10, child: Transform.rotate(angle: -0.2 - (showTongue ? _tailAnimation.value : 0), child: _buildFloppyEar(mainColor, outlineColor, headSize))),
                             
                             // Formato da Cabeça
                             Container(
                                width: headSize, height: headSize * 0.85,
                                decoration: BoxDecoration(
                                  color: mainColor,
                                  borderRadius: BorderRadius.circular(headSize * 0.45),
                                  border: Border.all(color: outlineColor, width: _strokeW),
                                ),
                             ),
                             // Focinho
                             Positioned(
                               bottom: headSize * 0.1,
                               child: Container(
                                 width: headSize * 0.55, 
                                 height: headSize * 0.4, 
                                 decoration: BoxDecoration(
                                   color: secondaryColor, 
                                   borderRadius: BorderRadius.circular(30),
                                   border: Border.all(color: outlineColor, width: _strokeW * 0.8),
                                 ),
                               ),
                             ),

                             // Olhos (Estilo Kawaii)
                             Positioned(
                               top: headSize * 0.35, 
                               child: _buildKawaiiEyes(headSize),
                             ),

                             // Nariz e Boca
                              Positioned(
                                top: headSize * 0.58,
                                 child: Column(
                                   children: [
                                     Container(
                                       width: 18, height: 12, 
                                       decoration: BoxDecoration(
                                         color: const Color(0xFF2D1F1C), 
                                         borderRadius: BorderRadius.circular(8),
                                       ),
                                     ),
                                     const SizedBox(height: 5),
                                     // Língua (aparece se feliz OU se estiver animando "de vez em quando")
                                     if (showTongue || _tongueController.isAnimating)
                                       Transform.translate(
                                         offset: Offset(0, _tongueController.value * 3),
                                         child: Container(
                                           width: 22, height: 26, 
                                           decoration: BoxDecoration(
                                             color: Colors.pinkAccent[100], 
                                             borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)), 
                                             border: Border.all(color: outlineColor, width: _strokeW),
                                           ),
                                         ),
                                       )
                                     else
                                       CustomPaint(
                                         size: const Size(24, 10),
                                         painter: DogMouthPainter(outlineColor, _strokeW),
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

  Widget _buildFloppyEar(Color color, Color outline, double headSize) {
    return Container(
      width: headSize * 0.28, height: headSize * 0.55,
      decoration: BoxDecoration(
        color: color, 
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
          bottom: Radius.circular(40),
        ), 
        border: Border.all(color: outline, width: _strokeW),
      ),
    );
  }

  Widget _buildKawaiiEyes(double headSize) {
    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, child) {
        final blinkValue = _blinkController.value;
        final eyeHeight = 28.0 * (1.0 - blinkValue);
        final eyeWidth = 28.0;

        return SizedBox(
          width: headSize * 0.6,
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
        color: const Color(0xFF2D1F1C),
        borderRadius: BorderRadius.circular(width),
      ),
      child: height > 12 ? Stack(
        children: [
          Positioned(
            top: 4, left: 5,
            child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
          Positioned(
            bottom: 4, right: 5,
            child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ],
      ) : null,
    );
  }

  Widget _buildBodyAndLegs(double width, double height, Color main, Color belly, Color outline) {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
           Positioned(bottom: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildPaw(main, outline), SizedBox(width: width * 0.4), _buildPaw(main, outline)])),
           Positioned(bottom: 10, child: Container(width: width, height: height, decoration: BoxDecoration(color: main, borderRadius: const BorderRadius.vertical(top: Radius.circular(70), bottom: Radius.circular(30)), border: Border.all(color: outline, width: _strokeW)), child: Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.only(bottom: 5), child: Container(width: width * 0.7, height: height * 0.6, decoration: BoxDecoration(color: belly, borderRadius: BorderRadius.circular(40))))))),
        ],
      );
  }

  Widget _buildPaw(Color color, Color outline) => Container(
    width: 42, height: 22, 
    decoration: BoxDecoration(
      color: color, 
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(5)), 
      border: Border.all(color: outline, width: _strokeW),
    ),
    child: Stack(
      children: [
        Positioned(bottom: 4, left: 10, child: Container(width: 2, height: 6, color: outline.withOpacity(0.3))),
        Positioned(bottom: 4, left: 20, child: Container(width: 2, height: 8, color: outline.withOpacity(0.3))),
        Positioned(bottom: 4, left: 30, child: Container(width: 2, height: 6, color: outline.withOpacity(0.3))),
      ],
    ),
  );
}

class DogMouthPainter extends CustomPainter {
  final Color color;
  final double strokeW;
  DogMouthPainter(this.color, this.strokeW);

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

class DogTailPainter extends CustomPainter {
  final Color color;
  final Color outline;
  final double strokeW;
  DogTailPainter(this.color, this.outline, this.strokeW);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final paintOutline = Paint()..color = outline..strokeWidth = strokeW..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.1, size.width * 0.8, 0);
    path.quadraticBezierTo(size.width, size.height * 0.2, size.width * 0.9, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.6, size.width * 0.2, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, paintOutline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
