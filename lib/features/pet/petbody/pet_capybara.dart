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
    this.size = 300.0,
    this.customColors,
  }) : super(key: key);

  @override
  State<FullBodyCapybaraWidget> createState() => _FullBodyCapybaraWidgetState();
}

class _FullBodyCapybaraWidgetState extends State<FullBodyCapybaraWidget> with TickerProviderStateMixin {
  // ... (COPIAR TODA A LÓGICA DE CONTROLADORES E INITSTATE DO CACHORRO/GATO AQUI) ...
  // A Capivara é mais "dura", então o pulo pode ter menos "squash & stretch" para ficar mais engraçado.
  late AnimationController _breathingController;
  late AnimationController _jumpController;
  late AnimationController _blinkController;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat(reverse: true); // Respiração lenta
    _jumpController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _blinkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _startBlinking();
  }
  // ... (copy paste dos métodos dispose, _startBlinking, didUpdateWidget) ...
   void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 5000), (timer) { // Pisca pouco
      if (math.Random().nextBool() && widget.mood != PetMood.sad && mounted) {
        _blinkController.forward().then((_) => _blinkController.reverse());
      }
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel(); _breathingController.dispose(); _jumpController.dispose(); _blinkController.dispose(); super.dispose();
  }

   @override
  void didUpdateWidget(covariant FullBodyCapybaraWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mood == PetMood.happy && oldWidget.mood != PetMood.happy) {
      _jumpController.forward(from: 0.0).then((_) => _jumpController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    // PALETA DA CAPIVARA
    final colors = widget.customColors ?? PetColors.defaultCapybara;
    final mainColor = colors.primaryColor;
    final outlineColor = colors.outlineColor;
    
    // Forma muito mais quadrada
    final headWidth = widget.size * 0.7;
    final headHeight = widget.size * 0.55;

    return AnimatedBuilder(
      animation: Listenable.merge([_breathingController, _jumpController, _blinkController]),
      builder: (context, child) {
        // Pulo mais "duro" (menos stretch X)
        final jumpValue = Curves.elasticOut.transform(_jumpController.value);
        final jumpY = -35.0 * math.sin(jumpValue * math.pi);
        final breathScaleY = 1.0 + (_breathingController.value * 0.02);
        final jumpScaleY = 1.0 + (math.sin(jumpValue * math.pi) * 0.08);

        return Transform.translate(
          offset: Offset(0, jumpY),
          child: Transform.scale(
            scaleY: breathScaleY * jumpScaleY,
            // scaleX: 1.0, // Capivara quase não estica pros lados
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: widget.size, height: widget.size,
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                   // CORPO (Retangular)
                   Positioned(bottom: 20, child: Container(width: widget.size*0.6, height: widget.size*0.5, decoration: BoxDecoration(color: mainColor, borderRadius: BorderRadius.circular(40), border: Border.all(color: outlineColor, width: 3.5)))),
                   // PATINHAS (Curtas)
                   Positioned(bottom: 0, child: Row(children: [Container(width: 30, height: 30, decoration: BoxDecoration(color: mainColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: outlineColor, width: 3.5))), SizedBox(width: 80), Container(width: 30, height: 30, decoration: BoxDecoration(color: mainColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: outlineColor, width: 3.5)))])),

                  // CABEÇA DA CAPIVARA (Formato de Pão)
                  Positioned(
                    top: widget.size * 0.2,
                    child: Transform.translate(
                      offset: Offset(0, _breathingController.value * 3),
                      child: SizedBox(
                        width: headWidth, height: headHeight,
                        child: Stack(
                           alignment: Alignment.center,
                           clipBehavior: Clip.none,
                           children: [
                             // Orelhinhas minúsculas no topo reto
                             Positioned(top: -5, left: headWidth*0.2, child: _buildTinyEar(mainColor, outlineColor)),
                             Positioned(top: -5, right: headWidth*0.2, child: _buildTinyEar(mainColor, outlineColor)),
                             
                             // Cabeça Retangular
                             Container(
                                width: headWidth, height: headHeight,
                                decoration: BoxDecoration(
                                  color: mainColor,
                                  // Bordas pouco arredondadas
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: outlineColor, width: 3.5),
                                ),
                             ),

                             // Olhos Afastados e Focinho Quadrado
                             Positioned(top: headHeight * 0.3, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [SizedBox(width: 40), _buildDeadEye(), SizedBox(width: 60), _buildDeadEye(), SizedBox(width: 40)])),
                             Positioned(
                               top: headHeight * 0.55,
                               child: Container(width: 50, height: 35, decoration: BoxDecoration(color: outlineColor.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: outlineColor, width: 2))),
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

  Widget _buildTinyEar(Color color, Color outline) => Container(width: 25, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10), border: Border.all(color: outline, width: 3.5)));
  // Olhos de capivara são meio "mortos" de tédio, então piscam menos
  Widget _buildDeadEye() {
       final currentHeight = 14.0 * (1.0 - _blinkController.value);
       return Container(width: 14, height: currentHeight, decoration: const BoxDecoration(color: Color(0xFF3E2723), shape: BoxShape.circle));
  }
}