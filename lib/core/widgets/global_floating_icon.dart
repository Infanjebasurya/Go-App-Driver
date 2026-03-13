import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/sos/presentation/cubit/sos_cubit.dart';
import 'package:goapp/features/sos/presentation/pages/sos_page.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/core/theme/app_colors.dart';

/// A lightweight in-app floating icon that stays above all pages.
class GlobalFloatingIcon extends StatefulWidget {
  const GlobalFloatingIcon({super.key, required this.child, this.navigatorKey});

  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<GlobalFloatingIcon> createState() => _GlobalFloatingIconState();
}

class _GlobalFloatingIconState extends State<GlobalFloatingIcon> {
  Offset _offset = const Offset(20, 120);
  bool _isExpanded = false;
  bool _isDragging = false;
  bool _isHidden = false;

  void _snapToNearestEdge(double maxX, double maxY) {
    final double snapX = _offset.dx > (maxX / 2) ? maxX : 0;
    setState(() {
      _offset = Offset(snapX, _offset.dy.clamp(0, maxY));
    });
  }

  Future<void> _openSos(BuildContext context) async {
    setState(() {
      _isExpanded = false;
    });
    final navigator =
        widget.navigatorKey?.currentState ??
        Navigator.maybeOf(context, rootNavigator: true) ??
        Navigator.maybeOf(context);
    if (navigator == null || !mounted) return;
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<SosCubit>(
          create: (_) => sl<SosCubit>(),
          child: const SOSPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double iconSize = 56;
        const double panelWidth = 220;
        const double panelMaxHeight = 260;
        final double maxX = (constraints.maxWidth - iconSize).clamp(
          0,
          double.infinity,
        );
        final double maxY = (constraints.maxHeight - iconSize).clamp(
          0,
          double.infinity,
        );
        final double effectivePanelMaxHeight = (constraints.maxHeight - 16)
            .clamp(120, panelMaxHeight)
            .toDouble();
        final Offset bubbleOffset = Offset(
          _offset.dx.clamp(0, maxX),
          _offset.dy.clamp(0, maxY),
        );
        final bool placePanelLeft =
            bubbleOffset.dx > (constraints.maxWidth / 2);

        final double panelLeft = placePanelLeft
            ? (bubbleOffset.dx - panelWidth - 12).clamp(
                8,
                constraints.maxWidth - panelWidth - 8,
              )
            : (bubbleOffset.dx + iconSize + 12).clamp(
                8,
                constraints.maxWidth - panelWidth - 8,
              );
        final double panelTop = bubbleOffset.dy
            .clamp(8, constraints.maxHeight - effectivePanelMaxHeight - 8)
            .toDouble();
        final bool hiddenOnRight = bubbleOffset.dx > (maxX / 2);
        final double hiddenTabTop = bubbleOffset.dy.clamp(
          8,
          constraints.maxHeight - 72,
        );

        return Stack(
          children: <Widget>[
            widget.child,
            if (_isExpanded)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      _isExpanded = false;
                    });
                  },
                ),
              ),
            if (_isExpanded)
              Positioned(
                left: panelLeft,
                top: panelTop,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.white,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: panelWidth,
                      maxWidth: panelWidth,
                      maxHeight: effectivePanelMaxHeight,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => _openSos(context),
                              icon: const Icon(Icons.shield_outlined),
                              label: const Text('Open SOS'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isExpanded = false;
                                  _isHidden = true;
                                });
                              },
                              icon: const Icon(Icons.visibility_off_outlined),
                              label: const Text('Skip for now'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isExpanded = false;
                                  _isHidden = true;
                                });
                              },
                              icon: const Icon(Icons.close_rounded),
                              label: const Text('Close'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_isHidden)
              Positioned(
                top: hiddenTabTop,
                left: hiddenOnRight ? null : 0,
                right: hiddenOnRight ? 0 : null,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isHidden = false;
                      _isExpanded = false;
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.black87,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(hiddenOnRight ? 16 : 0),
                        bottomLeft: Radius.circular(hiddenOnRight ? 16 : 0),
                        topRight: Radius.circular(hiddenOnRight ? 0 : 16),
                        bottomRight: Radius.circular(hiddenOnRight ? 0 : 16),
                      ),
                    ),
                    child: Icon(
                      hiddenOnRight
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            if (!_isHidden)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                left: bubbleOffset.dx,
                top: bubbleOffset.dy,
                child: GestureDetector(
                  onPanStart: (_) {
                    _isDragging = true;
                    if (_isExpanded) {
                      setState(() {
                        _isExpanded = false;
                      });
                    }
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _offset = Offset(
                        (_offset.dx + details.delta.dx).clamp(0, maxX),
                        (_offset.dy + details.delta.dy).clamp(0, maxY),
                      );
                    });
                  },
                  onPanEnd: (_) {
                    _snapToNearestEdge(maxX, maxY);
                    Future<void>.delayed(const Duration(milliseconds: 120), () {
                      _isDragging = false;
                    });
                  },
                  onTap: () {
                    if (_isDragging) return;
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: _isExpanded ? AppColors.blue : AppColors.black87,
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isExpanded
                          ? Icons.close_rounded
                          : Icons.open_in_new_rounded,
                      color: AppColors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
