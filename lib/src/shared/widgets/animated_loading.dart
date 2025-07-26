import 'package:flutter/material.dart';
import 'package:demo/src/theme/app_colors.dart';

class AnimatedLoading extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration? duration;
  final Widget? child;
  final String? imagePath;
  
  const AnimatedLoading({
    super.key,
    this.size = 48.0,
    this.color,
    this.duration,
    this.child,
    this.imagePath,
  });

  @override
  AnimatedLoadingState createState() => AnimatedLoadingState();
}

class AnimatedLoadingState extends State<AnimatedLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(seconds: 3),
      vsync: this,
    );

    // Animación de rotación (0 a 360 grados)
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0, // 2 * pi = 360 grados
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Animación de escala (1.0 a 1.1 y vuelta a 1.0)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Repetir la animación infinitamente
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 3.14159, // Convertir a radianes
            child: widget.imagePath != null
                ? SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: Image.asset(
                      widget.imagePath!,
                      fit: BoxFit.contain,
                    ),
                  )
                : Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: widget.color ?? AppColors.primaryDarkTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.child ?? const Icon(
                      Icons.engineering,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

// Widget específico para loading con el logo de la empresa
class CompanyAnimatedLoading extends StatelessWidget {
  final double size;
  final String? text;
  
  const CompanyAnimatedLoading({
    super.key,
    this.size = 64.0,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedLoading(
          size: size,
          imagePath: 'assets/images/loading.png',
          duration: const Duration(seconds: 3),
        ),
        if (text != null) ...[
          const SizedBox(height: 16),
          Text(
            text!,
            style: TextStyle(
              color: AppColors.neutralTextGray,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}