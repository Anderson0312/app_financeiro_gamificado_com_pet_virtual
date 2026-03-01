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

// --- A LÓGICA DE ANIMAÇÃO É IDÊNTICA À DO GATO (REUTILIZÁVEL) ---
class _FullBodyDogWidgetState extends State<FullBodyDogWidget> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _tailController;
  late AnimationController _jumpController;
  late AnimationController _blinkController;
  late Animation<double> _tailAnimation;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _tailController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
    // Rabo do cachorro balança mais rápido e em ângulo menor
    _tailAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(CurvedAnimation(parent: _tailController, curve: Curves.easeInOutSine));
    _jumpController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _blinkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _startBlinking();
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 4000), (timer) {
      if (math.Random().nextBool() && widget.mood != PetMood.sad && mounted) {
        _blinkController.forward().then((_) => _blinkController.reverse());
      }
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _breathingController.dispose();
    _tailController.dispose();
    _jumpController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FullBodyDogWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mood == PetMood.happy && oldWidget.mood != PetMood.happy) {
      _jumpController.forward(from: 0.0).then((_) => _jumpController.reverse());
      _tailController.duration = const Duration(milliseconds: 200); // Rabo muito rápido
    } else if (widget.mood == PetMood.sad) {
      _tailController.duration = const Duration(milliseconds: 1500); // Rabo lento
    } else {
      _tailController.duration = const Duration(milliseconds: 500);
    }
    if(_tailController.isAnimating) _tailController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    // --- PALETA DE CORES DO CACHORRO ---
    final colors = widget.customColors ?? PetColors.defaultDog;
    final mainColor = colors.primaryColor;
    final secondaryColor = colors.secondaryColor;
    final outlineColor = colors.outlineColor;
    
    double eyeHeight = widget.mood == PetMood.happy ? 12.0 : (widget.mood == PetMood.sad ? 32.0 : 24.0);
    bool showTongue = widget.mood == PetMood.happy;

    final headSize = widget.size * 0.6;
    final bodyWidth = widget.size * 0.5;
    final bodyHeight = widget.size * 0.55;

    return AnimatedBuilder(
      animation: Listenable.merge([_breathingController, _tailController, _jumpController, _blinkController]),
      builder: (context, child) {
        final jumpValue = Curves.elasticOut.transform(_jumpController.value);
        final jumpY = -45.0 * math.sin(jumpValue * math.pi);
        final breathScaleY = 1.0 + (_breathingController.value * 0.03);
        final breathScaleX = 1.0 + (_breathingController.value * 0.01);
        final jumpScaleY = 1.0 + (math.sin(jumpValue * math.pi) * 0.15); // Mais stretch no pulo
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
                  // RABO (Mais curto e grosso)
                  Positioned(
                    bottom: bodyHeight * 0.4,
                    left: (widget.size / 2),
                    child: Transform.rotate(
                      angle: _tailAnimation.value * (widget.mood == PetMood.happy ? 2.5 : 1.0),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 20, height: 50,
                        decoration: BoxDecoration(color: mainColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: outlineColor, width: 3.5)),
                      ),
                    ),
                  ),
                  // CORPO E PATAS
                  _buildBodyAndLegs(bodyWidth, bodyHeight, mainColor, secondaryColor, outlineColor),
                  
                  // CABEÇA DO CACHORRO
                  Positioned(
                    top: widget.size * 0.1,
                    child: Transform.translate(
                      offset: Offset(0, _breathingController.value * 4),
                      child: SizedBox(
                        width: headSize, height: headSize,
                        child: Stack(
                           alignment: Alignment.center,
                           clipBehavior: Clip.none,
                           children: [
                             // Orelhas Caídas (Ao lado da cabeça)
                             Positioned(top: headSize*0.1, left: -10, child: Transform.rotate(angle: 0.2 + (showTongue ? _tailAnimation.value : 0), child: _buildFloppyEar(mainColor, outlineColor, headSize))),
                             Positioned(top: headSize*0.1, right: -10, child: Transform.rotate(angle: -0.2 - (showTongue ? _tailAnimation.value : 0), child: _buildFloppyEar(mainColor, outlineColor, headSize))),
                             
                             // Formato da Cabeça
                             Container(
                                width: headSize, height: headSize * 0.85,
                                decoration: BoxDecoration(
                                  color: mainColor,
                                  borderRadius: BorderRadius.circular(headSize * 0.4),
                                  border: Border.all(color: outlineColor, width: 3.5),
                                ),
                             ),
                             // Focinho mais claro
                             Positioned(
                               bottom: headSize * 0.1,
                               child: Container(width: headSize * 0.5, height: headSize * 0.35, decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(30))),
                             ),

                             // Olhos
                              Positioned(top: headSize * 0.3, child: _buildEyes(headSize, eyeHeight)),
                             // Nariz e Boca
                              Positioned(
                                top: headSize * 0.58,
                                 child: Column(
                                   children: [
                                     Container(width: 18, height: 12, decoration: BoxDecoration(color: const Color(0xFF4A342E), borderRadius: BorderRadius.circular(8))), // Nariz Grande
                                     const SizedBox(height: 5),
                                     // Língua (se feliz) ou Boca
                                     if (showTongue)
                                       Container(width: 20, height: 24, decoration: BoxDecoration(color: Colors.pinkAccent, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)), border: Border.all(color: outlineColor, width: 2)))
                                     else
                                       Container(width: 20, height: 5, decoration: BoxDecoration(color: const Color(0xFF4A342E), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)))),
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

  // --- WIDGETS AUXILIARES ESPECÍFICOS DO CACHORRO ---
  Widget _buildFloppyEar(Color color, Color outline, double headSize) {
    return Container(
      width: headSize * 0.25, height: headSize * 0.45,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20), border: Border.all(color: outline, width: 3.5)),
    );
  }

  // Reutilizando estruturas básicas
  Widget _buildBodyAndLegs(double width, double height, Color main, Color belly, Color outline) {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
           Positioned(bottom: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildPaw(main, outline), SizedBox(width: width * 0.4), _buildPaw(main, outline)])),
           Positioned(bottom: 10, child: Container(width: width, height: height, decoration: BoxDecoration(color: main, borderRadius: const BorderRadius.vertical(top: Radius.circular(70), bottom: Radius.circular(30)), border: Border.all(color: outline, width: 3.5)), child: Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.only(bottom: 5), child: Container(width: width * 0.7, height: height * 0.6, decoration: BoxDecoration(color: belly, borderRadius: BorderRadius.circular(40))))))),
        ],
      );
  }

  Widget _buildPaw(Color color, Color outline) => Container(width: 40, height: 20, decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(5)), border: Border.all(color: outline, width: 3.5)));
  
  Widget _buildEyes(double headSize, double eyeHeight) {
      final currentEyeHeight = eyeHeight * (1.0 - _blinkController.value);
      return SizedBox(width: headSize * 0.5, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildSingleEye(currentEyeHeight), _buildSingleEye(currentEyeHeight)]));
  }
  Widget _buildSingleEye(double height) => Container(width: 20, height: height < 0 ? 0 : height, decoration: BoxDecoration(color: const Color(0xFF332211), borderRadius: BorderRadius.circular(20)));
}