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
                  // CAMADA 0: ASAS (Chibi Style - Mais para fora)
                  Positioned(
                    top: widget.size * 0.28, 
                    left: -widget.size * 0.22, 
                    child: CustomPaint(
                      size: Size(widget.size * 0.6, widget.size * 0.5), // Tamanho aumentado para destaque
                      painter: DragonWingPainter(mainColor, outlineColor, _strokeW, true, _wingsController.value),
                    ),
                  ),
                  Positioned(
                    top: widget.size * 0.28, 
                    right: -widget.size * 0.22, 
                    child: CustomPaint(
                      size: Size(widget.size * 0.6, widget.size * 0.5), // Tamanho aumentado para destaque
                      painter: DragonWingPainter(mainColor, outlineColor, _strokeW, false, _wingsController.value),
                    ),
                  ),

                  // CAMADA 1: RABO (Estilo SVG - Lado Esquerdo - Parado no chão)
                  Positioned(
                    top: widget.size * 0.25, // Encostado no chão
                    left: -widget.size * -0.5, 
                    child: CustomPaint(
                      size: Size(widget.size * 0.6, widget.size * 0.6),
                      painter: DragonTailPainter(mainColor, bellyColor, outlineColor, _strokeW, true),
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
                             // Chifres Pontudos (Dragon Style - Ajustados)
                             Positioned(
                               top: -headSize * 0.22, 
                               left: headSize * 0.12, // Um pouco mais para dentro
                               child: _buildPointyHorn(Colors.amber[100]!, outlineColor, headSize, true),
                             ),
                             Positioned(
                               top: -headSize * 0.22, 
                               right: headSize * 0.12, // Um pouco mais para dentro
                               child: _buildPointyHorn(Colors.amber[100]!, outlineColor, headSize, false),
                             ),

                             // 1 Espinho centralizado na cabeça
                             Positioned(
                               top: -headSize *  0.05,
                               child: _buildHeadSpikes(mainColor, outlineColor, headSize),
                             ),
                             
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

                             // Focinho + Fumaça
                             Positioned(
                               bottom: headSize * 0.18, // Ajustado para dar profundidade
                               child: Stack(
                                 alignment: Alignment.center,
                                 clipBehavior: Clip.none,
                                 children: [
                                   // Muzzle (Focinho) - Reduzido em 30% (de 0.6x0.35 para 0.42x0.24)
                                   Container(
                                     width: headSize * 0.42,
                                     height: headSize * 0.24,
                                     decoration: BoxDecoration(
                                       color: mainColor.withOpacity(0.9),
                                       borderRadius: BorderRadius.circular(20),
                                       border: Border.all(color: outlineColor.withOpacity(0.3), width: 1),
                                     ),
                                   ),
                                   // Narinas Realistas
                                   Row(
                                     children: [
                                       _nostril(outlineColor),
                                       const SizedBox(width: 15), // Reduzido espaçamento
                                       _nostril(outlineColor),
                                     ],
                                   ),
                                   // Fumaça animada nas narinas
                                   if (widget.mood != PetMood.sad)
                                     Positioned(
                                       top: -8,
                                       child: CustomPaint(
                                         size: const Size(35, 35),
                                         painter: SmokePainter(_smokeController.value),
                                       ),
                                     ),
                                 ],
                               ),
                             ),

                             // Boca + Sopro de Fogo
                             Positioned(
                               bottom: headSize * 0.08,
                               child: Stack(
                                 alignment: Alignment.topCenter,
                                 clipBehavior: Clip.none,
                                 children: [
                                   // Sopro de Fogo
                                   if (_fireController.isAnimating)
                                     Positioned(
                                       top: 10,
                                       child: CustomPaint(
                                         size: const Size(120, 180),
                                         painter: FireBreathPainter(_fireController.value),
                                       ),
                                     ),
                                   
                                   // Boca Aberta com Presas
                                   CustomPaint(
                                     size: Size(headSize * 0.45, 25),
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

  Widget _buildPointyHorn(Color color, Color outline, double headSize, bool left) {
    return Transform.rotate(
      angle: left ? 0.18 : -0.18, // Menos inclinado para dentro
      child: CustomPaint(
        size: Size(headSize * 0.25, headSize * 0.45),
        painter: DragonHornPainter(color, outline, _strokeW, left),
      ),
    );
  }

  Widget _buildHeadSpikes(Color color, Color outline, double headSize) {
    return CustomPaint(
      size: Size(headSize * 0.15, headSize * 0.15), // Menor e único
      painter: DragonHeadSpikesPainter(color, outline, _strokeW),
    );
  }

  Widget _nostril(Color color) => Container(
    width: 6, height: 10, // Formato mais alongado e "realista"
    decoration: BoxDecoration(
      color: color.withOpacity(0.7), 
      borderRadius: BorderRadius.circular(4),
    ),
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
                  child: CustomPaint(
                    painter: BellyLinesPainter(outline, _strokeW),
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
      ..color = color.withOpacity(0.8)
      ..strokeWidth = strokeW * 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final fangPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    // Boca Aberta (Formato de semicírculo/U)
    path.moveTo(0, 0);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.5,
      size.width,
      0,
    );
    
    // Preenche o interior da boca
    canvas.drawPath(path, fillPaint);
    // Desenha o contorno da boca
    canvas.drawPath(path, paint);

    // 🦷 Presas (Duas pequenas presas brancas saindo do topo da boca)
    final fangW = size.width * 0.15;
    final fangH = size.height * 0.4;

    // Presa Esquerda
    final leftFang = Path();
    leftFang.moveTo(size.width * 0.2, 0);
    leftFang.lineTo(size.width * 0.2 + fangW / 2, fangH);
    leftFang.lineTo(size.width * 0.2 + fangW, 0);
    leftFang.close();
    canvas.drawPath(leftFang, fangPaint);

    // Presa Direita
    final rightFang = Path();
    rightFang.moveTo(size.width * 0.8 - fangW, 0);
    rightFang.lineTo(size.width * 0.8 - fangW / 2, fangH);
    rightFang.lineTo(size.width * 0.8, 0);
    rightFang.close();
    canvas.drawPath(rightFang, fangPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DragonHornPainter extends CustomPainter {
  final Color color;
  final Color outline;
  final double strokeW;
  final bool isLeft;
  DragonHornPainter(this.color, this.outline, this.strokeW, this.isLeft);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final paintOutline = Paint()
      ..color = outline
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Chifre Pontudo e curvado para dentro (curvatura reduzida)
    if (isLeft) {
      // Chifre esquerdo apontando para a direita (dentro)
      path.moveTo(size.width * 0.1, size.height);
      path.quadraticBezierTo(
        size.width * 0.2, // Ponto de controle mais próximo da reta para reduzir a curva
        size.height * 0.4, 
        size.width, 
        0,
      );
      path.quadraticBezierTo(
        size.width * 0.7, 
        size.height * 0.5, 
        size.width * 0.8, 
        size.height,
      );
    } else {
      // Chifre direito apontando para a esquerda (dentro)
      path.moveTo(size.width * 0.9, size.height);
      path.quadraticBezierTo(
        size.width * 0.8, // Ponto de controle mais próximo da reta
        size.height * 0.4, 
        0, 
        0,
      );
      path.quadraticBezierTo(
        size.width * 0.3, 
        size.height * 0.5, 
        size.width * 0.2, 
        size.height,
      );
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, paintOutline);
    
    // Detalhes de ranhuras no chifre
    final linePaint = Paint()
      ..color = outline.withOpacity(0.2)
      ..strokeWidth = 1.0;
    
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.7), Offset(size.width * 0.7, size.height * 0.7), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DragonHeadSpikesPainter extends CustomPainter {
  final Color color;
  final Color outline;
  final double strokeW;
  DragonHeadSpikesPainter(this.color, this.outline, this.strokeW);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final paintOutline = Paint()
      ..color = outline
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Apenas 1 espinho centralizado
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
    canvas.drawPath(path, paintOutline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BellyLinesPainter extends CustomPainter {
  final Color outline;
  final double strokeW;
  BellyLinesPainter(this.outline, this.strokeW);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = outline.withOpacity(0.3)
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 1; i < 5; i++) {
      double y = size.height * (i / 5);
      final path = Path();
      path.moveTo(size.width * 0.2, y);
      path.quadraticBezierTo(
        size.width * 0.5,
        y + 10,
        size.width * 0.8,
        y,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DragonTailPainter extends CustomPainter {
  final Color color;
  final Color bellyColor;
  final Color outline;
  final double strokeW;
  final bool isLeft;
  DragonTailPainter(this.color, this.bellyColor, this.outline, this.strokeW, this.isLeft);

  @override
  void paint(Canvas canvas, Size size) {
    final double xF = size.width / 200;
    final double yF = size.height / 200;
    
    double x(double val) => isLeft ? (200 - val) * xF : val * xF;
    double y(double val) => val * yF;

    final paintMain = Paint()..color = color..style = PaintingStyle.fill;
    final paintBelly = Paint()..color = bellyColor..style = PaintingStyle.fill;
    final paintOutline = Paint()
      ..color = outline
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 1️⃣ Corpo Principal do Rabo (Camada de Baixo)
    // path d="M 150 140 Q 40 140, 30 80 Q 60 210, 170 190 Z"
    final tailBase = Path();
    tailBase.moveTo(x(150), y(140));
    tailBase.quadraticBezierTo(x(40), y(140), x(30), y(80));
    tailBase.quadraticBezierTo(x(60), y(210), x(170), y(190));
    tailBase.close();
    canvas.drawPath(tailBase, paintMain);
    canvas.drawPath(tailBase, paintOutline);

    // 2️⃣ Parte de cima (Belly) do Rabo
    // path d="M 150 140 Q 40 140, 30 80 Q 55 160, 155 165 Z"
    final tailHighlight = Path();
    tailHighlight.moveTo(x(150), y(140));
    tailHighlight.quadraticBezierTo(x(40), y(140), x(30), y(80));
    tailHighlight.quadraticBezierTo(x(55), y(160), x(155), y(165));
    tailHighlight.close();
    canvas.drawPath(tailHighlight, paintBelly);
    canvas.drawPath(tailHighlight, paintOutline);

    // 3️⃣ Linhas de Detalhe na barriga
    final linePaint = Paint()..color = outline..strokeWidth = 1.5..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x(40), y(101)), Offset(x(45), y(112)), linePaint);
    canvas.drawLine(Offset(x(55), y(125)), Offset(x(62), y(140)), linePaint);
    canvas.drawLine(Offset(x(80), y(137)), Offset(x(85), y(156)), linePaint);
    canvas.drawLine(Offset(x(115), y(140)), Offset(x(118), y(162)), linePaint);

    // 4️⃣ Ponta do Rabo (Triângulo/Seta)
    // path d="M 15 90 L 5 40 L 55 60 Z"
    final tailTip = Path();
    tailTip.moveTo(x(15), y(90));
    tailTip.lineTo(x(5), y(40));
    tailTip.lineTo(x(55), y(60));
    tailTip.close();
    canvas.drawPath(tailTip, paintMain);
    canvas.drawPath(tailTip, paintOutline);
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
    final paintOutline = Paint()
      ..color = outline
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final flapEffect = math.sin(flap * math.pi) * 15; // Aumentado para o novo design
    
    // Normalização baseada no viewBox 200x200 do SVG original
    final double xF = size.width / 200;
    final double yF = size.height / 200;

    double x(double val) => isLeft ? val * xF : (200 - val) * xF;
    double y(double val) => (val * yF) + (isLeft ? flapEffect : flapEffect); // O flap afeta o Y

    // 1️⃣ Caminho Principal da Asa (Membrana)
    final path = Path();
    // M 160 40
    path.moveTo(x(160), y(40));
    // Q 90 30, 20 110 (Ponta superior e ponta da asa)
    path.quadraticBezierTo(x(90), y(30) + flapEffect, x(20), y(110) + flapEffect);
    // Q 55 95, 80 140 (Arco 1)
    path.quadraticBezierTo(x(55), y(95) + flapEffect, x(80), y(140) + flapEffect);
    // Q 105 110, 130 145 (Arco 2)
    path.quadraticBezierTo(x(105), y(110) + flapEffect, x(130), y(145) + flapEffect);
    // Q 145 115, 160 90 (Arco 3 de volta ao corpo)
    path.quadraticBezierTo(x(145), y(115) + flapEffect, x(160), y(90));
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, paintOutline);

    // 2️⃣ Detalhes Internos (Ossos/Cartilagem do SVG)
    final detailPaint = Paint()
      ..color = outline.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Detalhe 1: M 85 53 Q 75 90, 80 140
    final detailPath1 = Path();
    detailPath1.moveTo(x(85), y(53) + flapEffect);
    detailPath1.quadraticBezierTo(x(75), y(90) + flapEffect, x(80), y(140) + flapEffect);
    canvas.drawPath(detailPath1, detailPaint);

    // Detalhe 2: M 125 40 Q 120 90, 130 145
    final detailPath2 = Path();
    detailPath2.moveTo(x(125), y(40) + flapEffect);
    detailPath2.quadraticBezierTo(x(120), y(90) + flapEffect, x(130), y(145) + flapEffect);
    canvas.drawPath(detailPath2, detailPaint);
    
    // Braço principal para conectar tudo
    final armPath = Path();
    armPath.moveTo(x(160), y(40));
    armPath.lineTo(x(160), y(90));
    canvas.drawPath(armPath, detailPaint);
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
