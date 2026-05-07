import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

import '../domain/models/pet.dart';
import '../domain/models/pet_colors.dart';

class FullBodyCapybaraWidget extends StatefulWidget {
  final PetMood mood;
  final double size;
  final PetColors? customColors;

  const FullBodyCapybaraWidget({
    Key? key,
    required this.mood,
    this.size = 300,
    this.customColors,
  }) : super(key: key);

  @override
  State<FullBodyCapybaraWidget> createState() => _FullBodyCapybaraWidgetState();
}

class _FullBodyCapybaraWidgetState extends State<FullBodyCapybaraWidget>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _blinkController;

  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _startBlinking();
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        if (math.Random().nextBool()) {
          _blinkController.forward().then((_) => _blinkController.reverse());
        }
      },
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _blinkController.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bodyHeight = widget.size;
    final double bodyWidth = widget.size * 0.65;
    final double headHeight = bodyHeight * 0.40;

    // Cores baseadas no estilo Kawaii/Sticker solicitado
    final outlineColor = const Color(0xFF4A3728); // Marrom escuro uniforme
    final baseColor = widget.customColors?.primaryColor ?? const Color(0xFFD2A679); // Marrom claro quente
    final shadowColor = const Color(0xFFB88A5C); // Marrom ligeiramente mais escuro
    final snoutColor = const Color(0xFFA67B5B); // Marrom médio para o focinho
    final cheekColor = const Color(0xFFFFA6B9); // Rosa coral suave
    final eyeColor = const Color(0xFF332211); // Marrom bem escuro para olhos e narinas

    return AnimatedBuilder(
      animation: Listenable.merge([
        _breathingController,
        _blinkController,
      ]),
      builder: (context, _) {
        final breathScale = 1 + (_breathingController.value * 0.02);

        return Transform.scale(
          scaleY: breathScale,
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: bodyWidth * 1.2,
            height: bodyHeight * 1.1,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                /// ORELHAS (Top of head, slightly to sides)
                Positioned(
                  top: bodyHeight * 0.05,
                  left: bodyWidth * 0.22,
                  child: _buildEar(baseColor, outlineColor, headHeight),
                ),
                Positioned(
                  top: bodyHeight * 0.05,
                  right: bodyWidth * 0.22,
                  child: _buildEar(baseColor, outlineColor, headHeight),
                ),

                /// PERNAS (Short and wide, 10% height)
                Positioned(
                  bottom: 0,
                  left: bodyWidth * 0.32,
                  child: _buildLeg(baseColor, outlineColor, bodyHeight),
                ),
                Positioned(
                  bottom: 0,
                  right: bodyWidth * 0.32,
                  child: _buildLeg(baseColor, outlineColor, bodyHeight),
                ),

                /// CORPO OVAL (Wider bottom, thinning top)
                Positioned(
                  bottom: bodyHeight * 0.05,
                  child: Container(
                    width: bodyWidth,
                    height: bodyHeight * 0.95,
                    decoration: BoxDecoration(
                      color: baseColor,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.15),
                          baseColor,
                          shadowColor
                        ],
                        stops: const [0, 0.7, 1],
                        radius: 0.9,
                        center: const Alignment(0, -0.1),
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.elliptical(bodyWidth * 0.45, bodyHeight * 0.45),
                        topRight: Radius.elliptical(bodyWidth * 0.45, bodyHeight * 0.45),
                        bottomLeft: Radius.elliptical(bodyWidth * 0.5, bodyHeight * 0.3),
                        bottomRight: Radius.elliptical(bodyWidth * 0.5, bodyHeight * 0.3),
                      ),
                      border: Border.all(color: outlineColor, width: 3.5),
                    ),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        /// BOCHECHAS ROSADAS
                        Positioned(
                          top: headHeight * 0.6,
                          left: bodyWidth * 0.08,
                          child: _buildCheek(cheekColor),
                        ),
                        Positioned(
                          top: headHeight * 0.6,
                          right: bodyWidth * 0.08,
                          child: _buildCheek(cheekColor),
                        ),

                        /// OLHOS KAWAII (Simple circles, no shine)
                        Positioned(
                          top: headHeight * 0.45,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildEye(eyeColor, bodyWidth),
                              SizedBox(width: bodyWidth * 0.25), // Espaço de ~1 olho
                              _buildEye(eyeColor, bodyWidth),
                            ],
                          ),
                        ),

                        /// FOCINHO GRANDE OVAL
                        Positioned(
                          top: headHeight * 0.52,
                          child: Container(
                            width: bodyWidth * 0.6,
                            height: headHeight * 0.45,
                            decoration: BoxDecoration(
                              color: snoutColor,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: outlineColor, width: 2.5),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Narinas inclinadas
                                Positioned(
                                  top: 10,
                                  left: bodyWidth * 0.18,
                                  child: _nostril(eyeColor),
                                ),
                                Positioned(
                                  top: 10,
                                  right: bodyWidth * 0.18,
                                  child: _nostril(eyeColor),
                                ),
                                // Boca em Y
                                const Positioned(
                                  bottom: 8,
                                  child: _Mouth(),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// BRAÇOS (Short and rounded, 25% height)
                Positioned(
                  bottom: bodyHeight * 0.25,
                  left: bodyWidth * 0.1,
                  child: _buildArm(baseColor, outlineColor, bodyHeight),
                ),
                Positioned(
                  bottom: bodyHeight * 0.25,
                  right: bodyWidth * 0.1,
                  child: _buildArm(baseColor, outlineColor, bodyHeight),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEar(Color base, Color outline, double headHeight) {
    final earSize = headHeight * 0.10; // Altura da orelha ≈ 10% da altura da cabeça
    return Container(
      width: earSize * 1.3,
      height: earSize,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(earSize * 0.5),
        border: Border.all(color: outline, width: 2.5),
      ),
      child: Center(
        child: Container(
          width: earSize * 0.5,
          height: earSize * 0.4,
          decoration: BoxDecoration(
            color: const Color(0xFF4A3728).withOpacity(0.5), // Marrom mais escuro interno
            borderRadius: BorderRadius.circular(earSize * 0.2),
          ),
        ),
      ),
    );
  }

  Widget _buildEye(Color color, double headWidth) {
    final size = headWidth * 0.06; // Diâmetro de 6% da largura da cabeça
    return Container(
      width: size,
      height: size * (1 - _blinkController.value),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildCheek(Color color) {
    return Container(
      width: 24,
      height: 12,
      decoration: BoxDecoration(
        color: color.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _nostril(Color color) {
    return Transform.rotate(
      angle: 0.2,
      child: Container(
        width: 5,
        height: 8,
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  Widget _buildLeg(Color base, Color outline, double totalHeight) {
    final legHeight = totalHeight * 0.12;
    return Container(
      width: 45,
      height: legHeight,
      decoration: BoxDecoration(
        color: base,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15), top: Radius.circular(5)),
        border: Border.all(color: outline, width: 3.5),
      ),
      alignment: Alignment.bottomCenter,
      child: const Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: _Feet(isArm: false),
      ),
    );
  }

  Widget _buildArm(Color base, Color outline, double totalHeight) {
    final armHeight = totalHeight * 0.25;
    return Container(
      width: 32,
      height: armHeight,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: outline, width: 3.5),
      ),
      alignment: Alignment.bottomCenter,
      child: const Padding(
        padding: EdgeInsets.only(bottom: 6),
        child: _Feet(isArm: true),
      ),
    );
  }
}

class _Feet extends StatelessWidget {
  final bool isArm;
  const _Feet({required this.isArm});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 10),
      painter: _ClawPainter(isArm: isArm),
    );
  }
}

class _ClawPainter extends CustomPainter {
  final bool isArm;
  _ClawPainter({required this.isArm});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A3728)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final spacing = size.width / 4;
    for (int i = 1; i <= 3; i++) {
      double x = i * spacing;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height * (isArm ? 0.8 : 1.0)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Mouth extends StatelessWidget {
  const _Mouth();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 12),
      painter: _MouthPainter(),
    );
  }
}

class _MouthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A3728)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Linha vertical curta (Y stem)
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width / 2, size.height * 0.3);

    // Curva inferior (V / U shape)
    path.moveTo(size.width * 0.2, size.height * 0.6);
    path.quadraticBezierTo(size.width / 2, size.height, size.width * 0.8, size.height * 0.6);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}