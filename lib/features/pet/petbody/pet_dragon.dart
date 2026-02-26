import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

import '../domain/models/pet.dart';

class FullBodyDragonWidget extends StatefulWidget {
  final PetMood mood;
  final double size;

  const FullBodyDragonWidget({Key? key, required this.mood, this.size = 300.0}) : super(key: key);

  @override
  State<FullBodyDragonWidget> createState() => _FullBodyDragonWidgetState();
}

class _FullBodyDragonWidgetState extends State<FullBodyDragonWidget> with TickerProviderStateMixin {
  // ... (Controladores de respiração, pulo, piscar IDÊNTICOS ao do cachorro/gato) ...
  late AnimationController _breathingController;
  late AnimationController _tailController;
  late AnimationController _jumpController;
  late AnimationController _blinkController;
  late Animation<double> _tailAnimation;
  Timer? _blinkTimer;
  
  // NOVO CONTROLADOR PARA AS ASAS
  late AnimationController _wingsController;

  @override
  void initState() {
    super.initState();
    // Inicialização padrão dos outros controladores...
    _breathingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _tailController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _tailAnimation = Tween<double>(begin: -0.15, end: 0.15).animate(CurvedAnimation(parent: _tailController, curve: Curves.easeInOutSine));
    _jumpController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _blinkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _startBlinking();

    // Inicialização das Asas
    _wingsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }

  // ... (Funções _startBlinking, dispose e didUpdateWidget IDÊNTICAS, mas adicione lógica para acelerar as asas se feliz) ...
  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 3000), (timer) {
      if (math.Random().nextBool() && widget.mood != PetMood.sad && mounted) {
        _blinkController.forward().then((_) => _blinkController.reverse());
      }
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel(); _breathingController.dispose(); _tailController.dispose(); _jumpController.dispose(); _blinkController.dispose();
    _wingsController.dispose(); // Não esqueça das asas
    super.dispose();
  }

   @override
  void didUpdateWidget(covariant FullBodyDragonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mood == PetMood.happy) {
      if (oldWidget.mood != PetMood.happy) _jumpController.forward(from: 0.0).then((_) => _jumpController.reverse());
      _wingsController.duration = const Duration(milliseconds: 300); // Asas rápidas
    } else if (widget.mood == PetMood.sad) {
       _wingsController.duration = const Duration(milliseconds: 1500); // Asas lentas
    } else {
       _wingsController.duration = const Duration(milliseconds: 800);
    }
    if(_wingsController.isAnimating) _wingsController.repeat(reverse: true);
  }


  @override
  Widget build(BuildContext context) {
    // PALETA DO DRAGÃO
    final mainColor = const Color(0xFF4CAF50); // Verde vibrante
    final bellyColor = const Color(0xFFC6FF00); // Verde limão
    final outlineColor = const Color(0xFF2E7D32); // Verde escuro
    
    final headSize = widget.size * 0.6;

    return AnimatedBuilder(
      // Adicione o _wingsController na lista
      animation: Listenable.merge([_breathingController, _tailController, _jumpController, _blinkController, _wingsController]),
      builder: (context, child) {
        // ... (Cálculos de pulo e respiração IDÊNTICOS) ...
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
                  // CAMADA 0: ASAS (Atrás de tudo)
                  Positioned(top: widget.size * 0.3, left: widget.size*0.1, child: Transform.rotate(angle: 0.2 + (_wingsController.value * 0.3), alignment: Alignment.bottomRight, child: _buildWing(mainColor, outlineColor))),
                  Positioned(top: widget.size * 0.3, right: widget.size*0.1, child: Transform.rotate(angle: -0.2 - (_wingsController.value * 0.3), alignment: Alignment.bottomLeft, child: _buildWing(mainColor, outlineColor))),

                  // CAMADA 1: RABO (Com ponta)
                  _buildDragonTail(mainColor, outlineColor),

                  // CAMADA 2: CORPO (Com escamas nas costas)
                  _buildBodyWithScales(mainColor, bellyColor, outlineColor),

                  // CAMADA 3: CABEÇA (Com chifres)
                  Positioned(
                    top: widget.size * 0.1,
                    child: Transform.translate(
                      offset: Offset(0, _breathingController.value * 4),
                      child: SizedBox(
                        width: headSize, height: headSize * 0.9,
                        child: Stack(
                           alignment: Alignment.center,
                           clipBehavior: Clip.none,
                           children: [
                             // Chifres
                             Positioned(top: -10, left: 20, child: _buildHorn(Colors.amber, outlineColor)),
                             Positioned(top: -10, right: 20, child: _buildHorn(Colors.amber, outlineColor)),
                             // Cabeça
                             Container(width: headSize, height: headSize * 0.8, decoration: BoxDecoration(color: mainColor, borderRadius: BorderRadius.circular(headSize * 0.35), border: Border.all(color: outlineColor, width: 3.5))),
                             // Olhos e Boca (Simplificados para o exemplo, use a lógica do gato para piscar/boca)
                             Positioned(top: headSize * 0.3, child: Row(children: [Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)), SizedBox(width: 40), Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle))])),
                             Positioned(bottom: 30, child: Container(width: 30, height: 10, decoration: BoxDecoration(color: outlineColor, borderRadius: BorderRadius.circular(10)))),
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

  // --- WIDGETS ESPECÍFICOS DO DRAGÃO ---
  Widget _buildWing(Color color, Color outline) => Container(width: 80, height: 60, decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), bottomLeft: Radius.circular(10)), border: Border.all(color: outline, width: 3.5)));
  Widget _buildHorn(Color color, Color outline) => Container(width: 15, height: 25, decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(5), bottom: Radius.circular(15)), border: Border.all(color: outline, width: 2.5)));
  Widget _buildDragonTail(Color main, Color outline) {
      // Simplificação do rabo para o exemplo. Use a estrutura do gato + um triângulo na ponta.
      return Positioned(bottom: 100, child: Transform.rotate(angle: _tailAnimation.value, child: Container(width: 30, height: 80, decoration: BoxDecoration(color: main, borderRadius: BorderRadius.circular(15), border: Border.all(color: outline, width: 3.5)))));
  }
  Widget _buildBodyWithScales(Color main, Color belly, Color outline) {
      // Corpo básico. Adicione pequenos triângulos nas laterais para as escamas.
      return Positioned(bottom: 20, child: Container(width: 140, height: 160, decoration: BoxDecoration(color: main, borderRadius: BorderRadius.circular(50), border: Border.all(color: outline, width: 3.5)), child: Center(child: Container(width: 100, height: 120, decoration: BoxDecoration(color: belly, borderRadius: BorderRadius.circular(40))))));
  }
}