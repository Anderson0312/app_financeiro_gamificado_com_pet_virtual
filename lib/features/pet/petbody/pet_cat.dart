import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

// Lembre-se de ajustar o import do PetColors caso necessário no seu projeto
import '../domain/models/pet_colors.dart';

enum PetMood { idle, happy, sad }

class FullBodyCatWidget extends StatefulWidget {
  final PetMood mood;
  final double size;
  final PetColors? customColors;

  const FullBodyCatWidget({
    Key? key,
    required this.mood,
    this.size = 320,
    this.customColors,
  }) : super(key: key);

  @override
  State<FullBodyCatWidget> createState() => _FullBodyCatWidgetState();
}

class _FullBodyCatWidgetState extends State<FullBodyCatWidget> with TickerProviderStateMixin {
  late AnimationController _breath;
  late AnimationController _jump;
  late AnimationController _blink;
  late AnimationController _tail;
  Timer? _blinkTimer;

  // Espessura do contorno global
  final double _strokeW = 1.5; 

  @override
  void initState() {
    super.initState();

    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _jump = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );

    _tail = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _startBlinking();
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 3200), (timer) {
      if (mounted && math.Random().nextBool() && widget.mood != PetMood.sad) {
        _blink.forward().then((_) => _blink.reverse());
      }
    });
  }

  @override
  void dispose() {
    _breath.dispose();
    _jump.dispose();
    _blink.dispose();
    _tail.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FullBodyCatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mood == PetMood.happy && oldWidget.mood != PetMood.happy) {
      _jump.forward(from: 0).then((_) => _jump.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.customColors ?? PetColors.defaultCat;
    final outline = colors.outlineColor;
    
    final headH = widget.size * 0.56;
    final headW = widget.size * 0.68;
    final bodyH = widget.size * 0.59; // Aumentado em ~20% (de 0.49 para 0.59)
    final bodyW = widget.size * 0.44; // Reduzido em ~20% (de 0.55 para 0.44)

    return AnimatedBuilder(
      animation: Listenable.merge([_breath, _jump, _blink, _tail]),
      builder: (context, child) {
        final jumpY = -25 * math.sin(_jump.value * math.pi);
        final breathScale = 1 + (_breath.value * 0.03);

        return Transform.translate(
          offset: Offset(0, jumpY),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [

                /// TAIL
                Positioned(
                  bottom: widget.size * 0.06, // Mais para baixo, perto da base
                  right: widget.size * 0.1,  // Ligeiramente para a direita
                  child: _buildTail(colors.primaryColor, outline),
                ),

                /// BODY + PATINHAS
                Positioned(
                  bottom: widget.size * 0.05,
                  child: Transform.scale(
                    scaleY: breathScale,
                    child: _buildBodyWithPaws(bodyW, bodyH, colors.primaryColor, outline),
                  ),
                ),

                /// HEAD
                Positioned(
                  top: widget.size * 0.02, // Ajustado de 0.05 para 0.02 para subir a cabeça
                  child: Transform.translate(
                    offset: Offset(0, _breath.value * 4), 
                    child: SizedBox(
                      width: headW,
                      height: headH * 1.5, 
                      child: Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                    
                          /// EARS - POSICIONAMENTO CORRIGIDO
                          Positioned(
                            top: headH * -0.25, // Ajustado levemente para cima
                            left: -headW * 0.1, // 10% para fora da borda esquerda
                            child: _buildEar(colors.primaryColor, outline, true),
                          ),

                          Positioned(
                            top: headH * -0.25,
                            right: -headW * 0.1, // 10% para fora da borda direita
                            child: _buildEar(colors.primaryColor, outline, false),
                          ),

                          /// HEAD SHAPE
                          Positioned(
                            top: headH * 0.35,
                            child: Container(
                              width: headW,
                              height: headH,
                              decoration: BoxDecoration(
                                color: colors.primaryColor,
                                borderRadius: BorderRadius.circular(200),
                                border: Border.all(color: outline, width: _strokeW),
                              ),
                            ),
                          ),
                    
                          /// EYES
                          Positioned(
                            top: headH * 0.65,
                            child: SizedBox(
                              width: headW * 0.6,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildKawaiiEye(),
                                  _buildKawaiiEye(),
                                ],
                              ),
                            ),
                          ),
                    
                          /// WHISKERS
                          Positioned(
                            top: headH * 0.80,
                            child: SizedBox(
                              width: headW * 1.1,
                              child: Stack(
                                children: [
                                  _buildWhiskers(true, outline),
                                  _buildWhiskers(false, outline),
                                ],
                              ),
                            ),
                          ),
                    
                          /// NOSE + MOUTH (:3)
                          Positioned(
                            top: headH * 0.95,
                            child: Column(
                              children: [
                                Container(
                                  width: 10,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                CustomPaint(
                                  size: const Size(28, 12),
                                  painter: CatMouthPainter(outline, _strokeW),
                                )
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
        );
      },
    );
  }

  Widget _buildTail(Color color, Color outline) {
     return Transform.rotate(
       angle: 0.15 * math.sin(_tail.value * math.pi * 2), // Balanço um pouco maior
       alignment: Alignment.bottomCenter, // Rotação a partir da base
       child: CustomPaint(
         size: const Size(80, 50), // Mudado para ser mais horizontal e largo na base
         painter: CatTailPainter(color, outline, _strokeW),
       ),
     );
   }

  /// BODY + PATAS
  Widget _buildBodyWithPaws(double w, double h, Color color, Color outline) {
    return SizedBox(
      width: w * 1.2, 
      height: h,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
           // Patas Traseiras
           Positioned(bottom: -5, left: w * 0.15, child: _buildPaw(color, outline, 30, 20)),
           Positioned(bottom: -5, right: w * 0.15, child: _buildPaw(color, outline, 30, 20)),

          // Torso
          Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: outline, width: _strokeW),
            ),
            child: Stack(
              children: [
                Positioned(top: 25, left: 15, child: _spot()),
                Positioned(bottom: 35, right: 20, child: _spot()),
              ],
            ),
          ),

          // Patas Dianteiras
           Positioned(top: h * 0.4, left: w * 0.05, child: Transform.rotate(angle: 0.3, child: _buildPaw(color, outline, 22, 45))),
           Positioned(top: h * 0.4, right: w * 0.05, child: Transform.rotate(angle: -0.3, child: _buildPaw(color, outline, 22, 45))),
        ],
      ),
    );
  }

  Widget _buildPaw(Color color, Color outline, double w, double h) {
    return Container(
      width: w, height: h,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20), border: Border.all(color: outline, width: _strokeW)),
      child: Stack(
        children: [
          Positioned(bottom: 4, left: w * 0.2, child: Container(width: 2, height: 6, color: outline.withOpacity(0.5))),
          Positioned(bottom: 4, left: w * 0.45, child: Container(width: 2, height: 8, color: outline.withOpacity(0.5))),
          Positioned(bottom: 4, left: w * 0.7, child: Container(width: 2, height: 6, color: outline.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _spot() {
    return Container(
      width: 25, height: 16,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
    );
  }

  /// KAWAII EYE
  Widget _buildKawaiiEye() {
    return AnimatedBuilder(
      animation: _blink,
      builder: (context, child) {
        final height = 35 * (1 - _blink.value);
        return Container(
          width: 35,
          height: height < 2 ? 2 : height,
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(50)),
          child: height > 10 ? Stack(
            children: [
              Positioned(top: 5, left: 6, child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))),
              Positioned(bottom: 5, right: 6, child: Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))),
            ],
          ) : null,
        );
      },
    );
  }

  /// EARS (Com âncora ajustada para rotação natural)
  Widget _buildEar(Color color, Color outline, bool left) {
    double angle = 0.0;
    // Ângulos aumentados para inclinar mais para fora (sentido oposto)
    if (widget.mood == PetMood.happy) angle = left ? -0.3 : 0.3;
    else if (widget.mood == PetMood.sad) angle = left ? -0.8 : 0.8;
    else angle = left ? -0.5 : 0.5;

    return Transform.rotate(
      angle: angle,
      // Âncora na base da orelha: direita para a orelha esquerda, e esquerda para a orelha direita
      alignment: left ? Alignment.bottomRight : Alignment.bottomLeft,
      child: CustomPaint(
        size: const Size(90, 110), 
        painter: ThickEarPainter(color, outline, Colors.pink[100]!, _strokeW),
      ),
    );
  }

  /// WHISKERS
  Widget _buildWhiskers(bool left, Color color) {
    return Align(
      alignment: left ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        children: List.generate(
          3,
          (i) => Transform.translate(
            offset: Offset(0, math.sin((_breath.value + i) * 2 * math.pi) * 1.5),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: CustomPaint(
                size: const Size(45, 12),
                painter: CurvedWhiskerPainter(color, _strokeW, left),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CurvedWhiskerPainter extends CustomPainter {
  final Color color;
  final double strokeW;
  final bool left;

  CurvedWhiskerPainter(this.color, this.strokeW, this.left);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (left) {
      // começa na bochecha e sobe
      path.moveTo(size.width, size.height * 0.6);
      path.quadraticBezierTo(
        size.width * 0.5,
        -size.height * 0.4, // ponto acima
        0,
        size.height * 0.4,
      );
    } else {
      path.moveTo(0, size.height * 0.6);
      path.quadraticBezierTo(
        size.width * 0.5,
        -size.height * 0.4,
        size.width,
        size.height * 0.4,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- PAINTER PARA A CAUDA DO GATO ---
class CatTailPainter extends CustomPainter {
  final Color color;
  final Color outline;
  final double strokeW;

  CatTailPainter(this.color, this.outline, this.strokeW);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final paintOutline = Paint()
      ..color = outline
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Início da cauda na base (esquerda inferior)
    path.moveTo(size.width * 0.1, size.height * 0.9);
    
    // Curva principal da cauda para cima e para a direita
    path.quadraticBezierTo(
      size.width * 0.5,
      -size.height * 0.5, // Faz a cauda subir e curvar
      size.width * 0.9,
      size.height * 0.2,
    );
    
    // Ponta arredondada da cauda
    path.quadraticBezierTo(
      size.width,
      size.height * 0.4,
      size.width * 0.8,
      size.height * 0.6,
    );
    
    // Volta para a base, mantendo a espessura
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.3,
      0,
      size.height * 0.8,
    );
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, paintOutline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- PAINTER PARA A BOCA ":3" ---
class CatMouthPainter extends CustomPainter {
  final Color color;
  final double strokeW;
  CatMouthPainter(this.color, this.strokeW);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeW * 1.5 
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

// --- PAINTER PARA A ORELHA ---
class ThickEarPainter extends CustomPainter {
  final Color baseColor;
  final Color outlineColor;
  final Color innerPink;
  final double strokeW;

  ThickEarPainter(this.baseColor, this.outlineColor, this.innerPink, this.strokeW);

  @override
  void paint(Canvas canvas, Size size) {
    final paintBase = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;
      
    final paintPink = Paint()
      ..color = innerPink
      ..style = PaintingStyle.fill;

    final paintOutline = Paint()
      ..color = outlineColor
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height);
    path.quadraticBezierTo(size.width * 0.5, -size.height * 0.1, size.width * 0.9, size.height);
    path.close();

    final innerPath = Path();
    innerPath.moveTo(size.width * 0.3, size.height * 0.85);
    innerPath.quadraticBezierTo(size.width * 0.5, size.height * 0.2, size.width * 0.7, size.height * 0.85);
    innerPath.close();

    canvas.drawPath(path, paintBase);
    canvas.drawPath(innerPath, paintPink);
    canvas.drawPath(path, paintOutline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}