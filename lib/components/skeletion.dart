import 'package:flutter/material.dart';
import '../theme/colors.dart';

class SkeletonLoader extends StatefulWidget {
  final double height;
  final double width;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool isCircle;

  const SkeletonLoader({
    super.key,
    this.height = 80,
    this.width = double.infinity,
    this.padding,
    this.borderRadius,
    this.isCircle = false,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
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
          padding: widget.padding,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.isCircle 
              ? BorderRadius.circular(widget.height / 2)
              : (widget.borderRadius ?? BorderRadius.circular(16)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                surfaceColor,
                surfaceColor.withOpacity(0.5),
                surfaceColor,
              ],
              stops: [
                0,
                0.5,
                1,
              ],
              transform: GradientRotation(_animation.value),
            ),
          ),
        );
      },
    );
  }
}

class UserTileSkeleton extends StatelessWidget {
  final EdgeInsetsGeometry? padding;

  const UserTileSkeleton({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding!,
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const SkeletonLoader(
                height: 50,
                width: 50,
                isCircle: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLoader(
                      height: 16,
                      width: 120,
                    ),
                    const SizedBox(height: 8),
                    SkeletonLoader(
                      height: 14,
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageBubbleSkeleton extends StatelessWidget {
  final bool isCurrentUser;
  final EdgeInsetsGeometry? padding;

  const MessageBubbleSkeleton({
    super.key,
    this.isCurrentUser = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: padding ?? EdgeInsets.only(
          left: isCurrentUser ? 64 : 16,
          right: isCurrentUser ? 16 : 64,
          bottom: 8,
        ),
        child: Column(
          crossAxisAlignment: isCurrentUser 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
          children: [
            SkeletonLoader(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.6,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
              ),
            ),
            const SizedBox(height: 4),
            SkeletonLoader(
              height: 12,
              width: 80,
            ),
          ],
        ),
      ),
    );
  }
}
