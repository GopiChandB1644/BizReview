import 'dart:math' as math;
import 'package:bizreview/core/constants/app_colors.dart';
import 'package:bizreview/features/auth/cubit/auth_cubit.dart';
import 'package:bizreview/features/auth/cubit/auth_state.dart';
import 'package:bizreview/features/auth/models/user_role.dart';
import 'package:bizreview/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _dotsController;

  // Phase Animations
  late final Animation<double> _assemblyProgress;
  late final Animation<double> _pulseProgress;
  late final Animation<double> _shockwaveProgress;
  late final Animation<double> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _footerFade;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    // 1. Assembly Phase (0.0 - 0.55): 4 pieces fly in & snap with elastic overshoot
    _assemblyProgress = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
    );

    // 2. Pulse & Impact Phase (0.55 - 0.72): United logo bounces with energy
    _pulseProgress = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.55, 0.72, curve: Curves.easeInOut),
    );

    // 3. Shockwave Radiation (0.55 - 0.80): Glow ring expands and dissipates
    _shockwaveProgress = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.55, 0.80, curve: Curves.easeOutQuad),
    );

    // 4. Title entrance (0.62 - 0.85): Slides up with smooth fade
    _titleSlide = Tween<double>(begin: 25.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.62, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _titleFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.62, 0.82, curve: Curves.easeIn),
    );

    // 5. Tagline & Badges (0.72 - 0.92)
    _taglineFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.72, 0.92, curve: Curves.easeIn),
    );

    // 6. Loading dots footer (0.82 - 1.0)
    _footerFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.82, 1.0, curve: Curves.easeIn),
    );

    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    // 1. Play the logo animation
    await _mainController.forward();

    if (!mounted) return;

    // 2. Await auth resolution if still initializing
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state is AuthLoading || authCubit.state is AuthInitial) {
      await for (final state in authCubit.stream) {
        if (state is! AuthLoading && state is! AuthInitial) {
          break;
        }
      }
    }

    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    final authState = authCubit.state;
    if (authState is Authenticated) {
      if (authState.user.role == UserRole.owner) {
        Navigator.pushReplacementNamed(context, AppRoutes.ownerDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.customerHome);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double logoSize = 136.0;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Rich Brand Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF071A2C), // Deep midnight navy
                  Color(0xFF0A2540), // Slate blue
                  Color(0xFF0F766E), // Signature Teal 700
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // 2. Ambient Decorative Glow Blobs
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withValues(alpha: 0.15),
              ),
            ),
          ),

          // 3. Central Animated Branding Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Assembling Logo
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, _) {
                    return _buildLogoAssembly(logoSize);
                  },
                ),

                const SizedBox(height: 32),

                // App Title with Slide & Fade Animation
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, _) {
                    return Transform.translate(
                      offset: Offset(0, _titleSlide.value),
                      child: Opacity(
                        opacity: _titleFade.value,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color(0xFFE2F1F2),
                                  Color(0xFF5EEAD4),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Text(
                                'BizReview',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing:
                                      1.0 + (1.5 * _titleFade.value),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Opacity(
                              opacity: _taglineFade.value,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: const Text(
                                  'SMART REVIEWS • VERIFIED BUSINESSES',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFCCFBF1),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 4. Subtle Animated Footer Indicator
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, _) {
                return Opacity(
                  opacity: _footerFade.value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _dotsController,
                        builder: (context, _) {
                          final phase =
                              (_dotsController.value + (index * 0.25)) % 1.0;
                          final dotScale = 0.6 + (0.5 * math.sin(phase * math.pi));
                          final dotOpacity =
                              0.3 + (0.7 * math.sin(phase * math.pi));

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF5EEAD4)
                                  .withValues(alpha: dotOpacity.clamp(0.0, 1.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(
                                    alpha: (dotOpacity * 0.5).clamp(0.0, 1.0),
                                  ),
                                  blurRadius: 6,
                                  spreadRadius: dotScale * 1.5,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the 4-quadrant assembly animation converging into the unified logo.
  Widget _buildLogoAssembly(double size) {
    final t = _assemblyProgress.value; // 0.0 to 1.0

    // Pulse bounce scale after assembly (0.55 -> 0.72): 1.0 -> 1.15 -> 1.0
    double pulseScale = 1.0;
    if (_pulseProgress.value > 0.0) {
      final pulseSine = math.sin(_pulseProgress.value * math.pi);
      pulseScale = 1.0 + (0.14 * pulseSine);
    }

    // Shockwave expansion behind assembled logo
    final shockwaveT = _shockwaveProgress.value;
    final shockwaveScale = 0.8 + (0.8 * shockwaveT);
    final shockwaveOpacity = (1.0 - shockwaveT).clamp(0.0, 1.0) * 0.6;

    final isFused = t >= 1.0;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Shockwave Ring
        if (shockwaveT > 0.0 && shockwaveOpacity > 0.0)
          Transform.scale(
            scale: shockwaveScale,
            child: Container(
              width: size + 30,
              height: size + 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF5EEAD4)
                      .withValues(alpha: shockwaveOpacity),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF14B8A6)
                        .withValues(alpha: shockwaveOpacity * 0.5),
                    blurRadius: 20,
                    spreadRadius: 6,
                  ),
                ],
              ),
            ),
          ),

        // Glowing Ambient Backing Halo
        Container(
          width: size + 16,
          height: size + 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F766E).withValues(alpha: 0.6),
                blurRadius: 30,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: const Color(0xFF2DD4BF)
                    .withValues(alpha: (0.2 + (0.3 * t)).clamp(0.0, 1.0)),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
        ),

        // Main Animated Logo Container with Pulse Scale
        Transform.scale(
          scale: pulseScale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  // Phase 1: 4 Quadrants flying inward with distinct angles & offsets
                  if (!isFused) ...[
                    // Piece 0: Top-Left (flies from top-left, rotated -24 deg)
                    _buildQuadrantPiece(
                      quadrant: 0,
                      size: size,
                      currentOffset:
                          Offset(-80 * (1.0 - t), -80 * (1.0 - t)),
                      rotation: -0.42 * (1.0 - t),
                      scale: 0.4 + (0.6 * t),
                      opacity: (t * 2.0).clamp(0.0, 1.0),
                    ),

                    // Piece 1: Top-Right (flies from top-right, rotated +24 deg)
                    _buildQuadrantPiece(
                      quadrant: 1,
                      size: size,
                      currentOffset:
                          Offset(80 * (1.0 - t), -80 * (1.0 - t)),
                      rotation: 0.42 * (1.0 - t),
                      scale: 0.4 + (0.6 * t),
                      opacity: (t * 2.0).clamp(0.0, 1.0),
                    ),

                    // Piece 2: Bottom-Left (flies from bottom-left, rotated +20 deg)
                    _buildQuadrantPiece(
                      quadrant: 2,
                      size: size,
                      currentOffset:
                          Offset(-80 * (1.0 - t), 80 * (1.0 - t)),
                      rotation: 0.35 * (1.0 - t),
                      scale: 0.4 + (0.6 * t),
                      opacity: (t * 2.0).clamp(0.0, 1.0),
                    ),

                    // Piece 3: Bottom-Right (flies from bottom-right, rotated -20 deg)
                    _buildQuadrantPiece(
                      quadrant: 3,
                      size: size,
                      currentOffset:
                          Offset(80 * (1.0 - t), 80 * (1.0 - t)),
                      rotation: -0.35 * (1.0 - t),
                      scale: 0.4 + (0.6 * t),
                      opacity: (t * 2.0).clamp(0.0, 1.0),
                    ),
                  ],

                  // Phase 2: Perfectly fused unified image
                  if (isFused)
                    Image.asset(
                      'assets/images/app_logo.png',
                      width: size,
                      height: size,
                      fit: BoxFit.contain,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a single clipped quadrant of the app logo that transforms individually.
  Widget _buildQuadrantPiece({
    required int quadrant,
    required double size,
    required Offset currentOffset,
    required double rotation,
    required double scale,
    required double opacity,
  }) {
    final half = size / 2;

    // Viewport coordinates inside the parent container
    final double left = (quadrant == 1 || quadrant == 3) ? half : 0;
    final double top = (quadrant == 2 || quadrant == 3) ? half : 0;

    // Internal image offset to expose only the designated quadrant
    final double imgLeft = (quadrant == 1 || quadrant == 3) ? -half : 0;
    final double imgTop = (quadrant == 2 || quadrant == 3) ? -half : 0;

    return Positioned(
      left: left,
      top: top,
      width: half,
      height: half,
      child: Transform.translate(
        offset: currentOffset,
        child: Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: ClipRect(
                child: Stack(
                  children: [
                    Positioned(
                      left: imgLeft,
                      top: imgTop,
                      width: size,
                      height: size,
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: size,
                        height: size,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
