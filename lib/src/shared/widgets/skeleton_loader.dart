import 'package:flutter/material.dart';
import 'package:demo/src/theme/app_colors.dart';

class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  
  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  SkeletonLoaderState createState() => SkeletonLoaderState();
}

class SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            color: AppColors.neutralMediumBorder.withOpacity(_animation.value * 0.3),
          ),
        );
      },
    );
  }
}

// Skeleton para cards del dashboard
class CardSkeleton extends StatelessWidget {
  final bool isMobile;
  
  const CardSkeleton({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SkeletonLoader(
                  width: isMobile ? 40 : 48,
                  height: isMobile ? 40 : 48,
                  borderRadius: BorderRadius.circular(12),
                ),
                const Spacer(),
                SkeletonLoader(
                  width: 16,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            SkeletonLoader(
              width: double.infinity,
              height: 18,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 6),
            SkeletonLoader(
              width: 120,
              height: 12,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

// Skeleton para la card principal con gradiente
class HeaderCardSkeleton extends StatelessWidget {
  final bool isMobile;
  
  const HeaderCardSkeleton({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: AppColors.neutralLightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neutralMediumBorder.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      width: 200,
                      height: 28,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    SkeletonLoader(
                      width: double.infinity,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 16),
                    SkeletonLoader(
                      width: 250,
                      height: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 20),
                SkeletonLoader(
                  width: 64,
                  height: 64,
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// Skeleton para estadísticas
class StatsSkeleton extends StatelessWidget {
  final bool isMobile;
  
  const StatsSkeleton({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neutralMediumBorder.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            width: 80,
            height: 14,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            width: 60,
            height: 32,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          SkeletonLoader(
            width: 100,
            height: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}