import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

enum PetMood { idle, happy, sad }

class FullBodyCatWidget extends StatefulWidget {
  final PetMood mood;
  final double size;

  const FullBodyCatWidget({
    Key? key,
    this.mood = PetMood.idle,
    this.size = 300.0,
  }) : super(key: key);

  @override
  State<FullBodyCatWidget> createState() => _FullBodyCatWidgetState();
}

class _FullBodyCatWidgetState extends State<FullBodyCatWidget> with TickerProviderStateMixin {
  // Controladores de Movimento Contínuo
  late AnimationController _breathingController;
  late AnimationController _tailController;
  
  // Controladores de Ação Específica
  late AnimationController _jumpController;
  late AnimationController _blinkController;
  
  late Animation<double> _tailAnimation;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    
    // 1. Respiração (Timing suave e orgânico)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // 2. Rabo (Ação Secundária)
    _tailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _tailAnimation = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(parent: _tailController, curve: Curves.easeInOutSine),
    );

    // 3. Sistema de Pulo (Squash & Stretch)
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 4. Sistema de Piscar (Life-like)
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _startBlinking();
  }

  // Lógica de piscar orgânico (intervalos aleatórios)
  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (math.Random().nextBool() && widget.mood != PetMood.sad) {
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
  void didUpdateWidget(covariant FullBodyCatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Dispara a animação de pulo elástico se ficou feliz
    if (widget.mood == PetMood.happy && oldWidget.mood != PetMood.happy) {
      _jumpController.forward(from: 0.0).then((_) {
         // Opcional: fazer ele pular algumas vezes
         _jumpController.reverse();
      });
      _tailController.duration = const Duration(milliseconds: 400); // Rabo elétrico
    } 
    // Ajustes para estado Triste
    else if (widget.mood == PetMood.sad) {
      _tailController.duration = const Duration(milliseconds: 2500); // Rabo desanimado
    } 
    // Volta ao Normal
    else {
      _tailController.duration = const Duration(milliseconds: 1200);
    }
    
    if(_tailController.isAnimating) {
        _tailController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- LINGUAGEM VISUAL "DUOLINGO" (Saturado, Flat, Contornos Fortes) ---
    Color mainColor;
    Color bellyColor;
    Color outlineColor;
    
    double eyeHeight, eyeWidth;
    double earAngleDrop = 0.0;
    bool showTear = widget.mood == PetMood.sad;
    bool showStar = widget.mood == PetMood.happy;

    switch (widget.mood) {
      case PetMood.happy:
        mainColor = const Color(0xFFFF9600); // Laranja Super Vibrante
        bellyColor = const Color(0xFFFFD579);
        outlineColor = const Color(0xFFC77100); // Contorno escuro para dar volume flat
        eyeHeight = 12.0; eyeWidth = 28.0; 
        break;
      case PetMood.sad:
        mainColor = const Color(0xFF5CC6D0); // Azul ciano triste, mas amigável
        bellyColor = const Color(0xFFA6E3E9);
        outlineColor = const Color(0xFF3BA1AB);
        eyeHeight = 35.0; eyeWidth = 24.0;
        earAngleDrop = 0.4; // Orelhas caem dramaticamente
        break;
      case PetMood.idle:
      default:
        mainColor = const Color(0xFFFFAB00); 
        bellyColor = const Color(0xFFFFE599);
        outlineColor = const Color(0xFFD68F00);
        eyeHeight = 26.0; eyeWidth = 22.0; 
        break;
    }

    // Proporções: Cabeça gigante, corpo pequeno (Mascote Premium)
    final headSize = widget.size * 0.65;
    final bodyWidth = widget.size * 0.45;
    final bodyHeight = widget.size * 0.50;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _breathingController, 
        _tailController, 
        _jumpController,
        _blinkController
      ]),
      builder: (context, child) {
        // --- CÁLCULOS DE MOTION DESIGN ---
        
        // 1. Respiração (Mais profunda se triste, mais elétrica se feliz)
        double breathIntensity = widget.mood == PetMood.sad ? 0.05 : 0.02;
        final breathScaleY = 1.0 + (_breathingController.value * breathIntensity);
        final breathScaleX = 1.0 + (_breathingController.value * (breathIntensity / 2));

        // 2. Animação de Pulo (Squash & Stretch via Curvas)
        // Usa elasticOut para dar aquele "bounce" estilo gelatina quando aterrissa
        final jumpValue = Curves.elasticOut.transform(_jumpController.value);
        final jumpY = -40.0 * math.sin(jumpValue * math.pi); // Sobe e desce
        
        // Achatamento durante o pulo
        double jumpScaleY = 1.0;
        double jumpScaleX = 1.0;
        if (_jumpController.isAnimating) {
           jumpScaleY = 1.0 + (math.sin(jumpValue * math.pi) * 0.1); // Estica ao subir
           jumpScaleX = 1.0 - (math.sin(jumpValue * math.pi) * 0.05); // Afina ao subir
        }

        // 3. Olhos Piscando
        final currentEyeHeight = eyeHeight * (1.0 - _blinkController.value);

        return Transform.translate(
          offset: Offset(0, jumpY),
          child: Transform.scale(
            scaleY: breathScaleY * jumpScaleY,
            scaleX: breathScaleX * jumpScaleX,
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  // --- CAMADA 1: O RABO ---
                  Positioned(
                    bottom: bodyHeight * 0.25,
                    left: (widget.size / 2) + (bodyWidth / 3.5), 
                    child: Transform.rotate(
                      angle: _tailAnimation.value * (widget.mood == PetMood.sad ? 0.3 : 1.5),
                      alignment: Alignment.bottomLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 28,
                        height: 90,
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: outlineColor, width: 3.5)
                        ),
                      ),
                    ),
                  ),

                  // --- CAMADA 2: CORPO ---
                  Positioned(
                    bottom: 10, 
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: bodyWidth,
                      height: bodyHeight,
                      decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(80), 
                          bottom: Radius.circular(40)
                        ),
                        border: Border.all(color: outlineColor, width: 3.5),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AnimatedContainer(
                             duration: const Duration(milliseconds: 400),
                             width: bodyWidth * 0.65,
                             height: bodyHeight * 0.55,
                             decoration: BoxDecoration(
                               color: bellyColor,
                               borderRadius: BorderRadius.circular(40)
                             ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Patas (Traseiras e Dianteiras unificadas visualmente para manter flat)
                  Positioned(
                      bottom: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           _buildPaw(mainColor, outlineColor),
                           SizedBox(width: bodyWidth * 0.25),
                           _buildPaw(mainColor, outlineColor),
                        ],
                      ),
                  ),

                  // --- CAMADA 3: CABEÇA ---
                  Positioned(
                    top: widget.size * 0.1, // Cabeça sobrepõe o corpo
                    child: Transform.translate(
                      // Cabeça mexe sutilmente com a respiração
                      offset: Offset(0, _breathingController.value * 5),
                      child: SizedBox(
                        width: headSize,
                        height: headSize * 0.9,
                        child: Stack(
                           alignment: Alignment.center,
                           clipBehavior: Clip.none,
                           children: [
                             // Orelhas Animadas
                             Positioned(
                               top: -15, left: 15, 
                               child: Transform.rotate(
                                 angle: (-math.pi/5) - earAngleDrop, 
                                 alignment: Alignment.bottomRight,
                                 child: _buildEar(mainColor, outlineColor, headSize))),
                             Positioned(
                               top: -15, right: 15, 
                               child: Transform.rotate(
                                 angle: (math.pi/5) + earAngleDrop, 
                                 alignment: Alignment.bottomLeft,
                                 child: _buildEar(mainColor, outlineColor, headSize))),
                             
                             // Rosto Principal
                             AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                width: headSize,
                                height: headSize * 0.8,
                                decoration: BoxDecoration(
                                  color: mainColor,
                                  borderRadius: BorderRadius.circular(headSize * 0.45),
                                  border: Border.all(color: outlineColor, width: 3.5),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))
                                  ]
                                ),
                             ),

                             // Olhos
                              Positioned(
                                top: headSize * 0.35,
                                child: SizedBox(
                                  width: headSize * 0.55,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildEye(eyeWidth, currentEyeHeight, showStar),
                                      _buildEye(eyeWidth, currentEyeHeight, showStar),
                                    ],
                                  ),
                                ),
                              ),

                              // Nariz e Boca
                               Positioned(
                                top: headSize * 0.52,
                                 child: Column(
                                   children: [
                                     // Nariz Fofinho
                                     Container(
                                       width: 14, height: 8, 
                                       decoration: BoxDecoration(color: const Color(0xFFFF7B93), borderRadius: BorderRadius.circular(10))
                                     ),
                                     const SizedBox(height: 6),
                                     // Boca expressiva
                                     AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: widget.mood == PetMood.happy ? 28 : 20,
                                      height: widget.mood == PetMood.happy ? 16 : (widget.mood == PetMood.sad ? 12 : 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4A342E), // Marrom escuro quase preto
                                        borderRadius: widget.mood == PetMood.sad
                                            ? const BorderRadius.vertical(top: Radius.circular(20)) 
                                            : const BorderRadius.vertical(bottom: Radius.circular(20)), 
                                      ),
                                 ),
                                   ],
                                 ),
                               ),

                             // Lágrima de Carete (Triste)
                             if (showTear)
                              Positioned(
                                top: headSize * 0.5,
                                left: headSize * 0.2,
                                child: Container(
                                  width: 12, height: 18, 
                                  decoration: const BoxDecoration(color: Color(0xFF4AC6FF), borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)))
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

  // --- Widgets Auxiliares ---
  Widget _buildEar(Color color, Color outlineColor, double headSize) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: headSize * 0.35,
      height: headSize * 0.45,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25), bottom: Radius.circular(10)),
        border: Border.all(color: outlineColor, width: 3.5)
      ),
    );
  }

  Widget _buildEye(double width, double height, bool showStar) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: width,
      // Garante que a altura nunca seja negativa
      height: height < 0 ? 0 : height,
      decoration: BoxDecoration(
        color: const Color(0xFF332211), // Quase preto, bem marcado
        borderRadius: BorderRadius.circular(20),
      ),
      // Adiciona o brilho nos olhos se estiver feliz e de olhos abertos
      child: (showStar && height > 5) 
          ? Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 2, right: 3),
                child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              ),
            ) 
          : null,
    );
  }

  Widget _buildPaw(Color color, Color outlineColor) {
     return AnimatedContainer(
       duration: const Duration(milliseconds: 400),
       width: 45,
       height: 25,
       decoration: BoxDecoration(
         color: color,
         borderRadius: const BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(10)),
         border: Border.all(color: outlineColor, width: 3.5),
       ),
     );
  }
}