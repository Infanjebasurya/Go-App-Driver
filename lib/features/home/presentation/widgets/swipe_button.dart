import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goapp/core/theme/app_colors.dart';

class SwipeToggleButton extends StatefulWidget {
  const SwipeToggleButton({
    super.key,
    required this.isOnline,
    required this.onGoOnline,
    required this.onGoOffline,
  });

  final bool isOnline;
  final VoidCallback onGoOnline;
  final VoidCallback onGoOffline;

  @override
  State<SwipeToggleButton> createState() => _SwipeToggleButtonState();
}

class _SwipeToggleButtonState extends State<SwipeToggleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _dragDx = 0;
  bool _isDragging = false;

  static const double _thumbSize = 56.0;
  static const double _trackHeight = 68.0;
  static const double _trackWidth = 280.0;
  static const double _padding = 6.0;
  static const double _maxSlide = _trackWidth - _thumbSize - _padding * 2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.isOnline ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant SwipeToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOnline != widget.isOnline && !_isDragging) {
      _controller.animateTo(
        widget.isOnline ? 1.0 : 0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 280),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _thumbLeft => (_controller.value * _maxSlide) + _padding;

  void _onDragStart(DragStartDetails _) {
    _isDragging = true;
    _dragDx = _controller.value * _maxSlide;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragDx = (_dragDx + details.delta.dx).clamp(0.0, _maxSlide);
      _controller.value = _dragDx / _maxSlide;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;
    final double vel = details.primaryVelocity ?? 0;
    final double pos = _dragDx / _maxSlide;
    final bool shouldBeOnline = vel > 200 || (vel >= -200 && pos > 0.5);

    if (shouldBeOnline != widget.isOnline) {
      HapticFeedback.mediumImpact();
      shouldBeOnline ? widget.onGoOnline() : widget.onGoOffline();
    }

    _controller.animateTo(
      shouldBeOnline ? 1.0 : 0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? _) {
          return Container(
            width: _trackWidth,
            height: _trackHeight,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(_trackHeight / 2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: widget.isOnline ? 0 : _thumbSize + _padding * 2 + 4,
                      right: widget.isOnline
                          ? _thumbSize + _padding * 2 + 4
                          : 0,
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Text(
                          widget.isOnline
                              ? 'Swipe to Go Offline'
                              : 'Swipe to Go Online',
                          key: ValueKey<bool>(widget.isOnline),
                          style: const TextStyle(
                            color: AppColors.neutral555,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: _thumbLeft,
                  top: _padding,
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        radius: 1.30,
                        colors: <Color>[
                          AppColors.greenDeep,
                          AppColors.greenStrong,
                          AppColors.greenDeep,
                        ],
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AppColors.greenStrong.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isOnline
                          ? Icons.chevron_left
                          : Icons.chevron_right,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
