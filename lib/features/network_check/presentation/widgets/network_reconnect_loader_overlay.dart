import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';

import '../bloc/reconnect_overlay_cubit.dart';
import '../bloc/reconnect_overlay_state.dart';

class NetworkReconnectLoaderOverlay extends StatelessWidget {
  const NetworkReconnectLoaderOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReconnectOverlayCubit, ReconnectOverlayState>(
      builder: (context, state) {
        return IgnorePointer(
          ignoring: !state.visible,
          child: AnimatedOpacity(
            opacity: state.visible ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: const _ReconnectShimmerScreen(),
          ),
        );
      },
    );
  }
}

/*
  Pure UI below (no business logic)
*/
class _ReconnectShimmerScreen extends StatefulWidget {
  const _ReconnectShimmerScreen();

  @override
  State<_ReconnectShimmerScreen> createState() =>
      _ReconnectShimmerScreenState();
}

class _ReconnectShimmerScreenState extends State<_ReconnectShimmerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 4,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ShimmerBar(controller: _controller, height: 20, width: 100),
                  _ShimmerBar(controller: _controller, height: 12, width: 150),
                ],
              ),
              const Spacer(),
              _ShimmerBar(controller: _controller, height: 15, width: 28),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 4),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    top: 0,
                    bottom: 260,
                    child: Container(color: Colors.white),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceF8,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.borderSoft),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: AppColors.surfaceShadow,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.handleGray,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _ShimmerPill(controller: _controller, height: 36),
                          const SizedBox(height: 14),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _ShimmerBar(
                                  controller: _controller,
                                  height: 22,
                                  width: double.infinity,
                                  radius: 12,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ShimmerBar(
                                  controller: _controller,
                                  height: 22,
                                  width: double.infinity,
                                  radius: 12,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ShimmerBar(
                                  controller: _controller,
                                  height: 22,
                                  width: double.infinity,
                                  radius: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: <Widget>[
                              _ShimmerBar(
                                controller: _controller,
                                height: 10,
                                width: 70,
                                radius: 6,
                              ),
                              const Spacer(),
                              _ShimmerBar(
                                controller: _controller,
                                height: 10,
                                width: 40,
                                radius: 6,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _ShimmerCard(controller: _controller),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ShimmerCard(controller: _controller),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ShimmerCard(controller: _controller),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _ShimmerBar(
                            controller: _controller,
                            height: 26,
                            width: double.infinity,
                            radius: 14,
                          ),
                          const SizedBox(height: 12),
                          _ShimmerBar(
                            controller: _controller,
                            height: 40,
                            width: double.infinity,
                            radius: 14,
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.surfaceF8,
        borderRadius: BorderRadius.circular(16),
      ),
      child: _ShimmerBar(controller: controller, height: 12, width: 60),
    );
  }
}

class _ShimmerPill extends StatelessWidget {
  const _ShimmerPill({required this.controller, required this.height});

  final Animation<double> controller;
  final double height;

  @override
  Widget build(BuildContext context) {
    return _ShimmerBar(
      controller: controller,
      height: height,
      width: double.infinity,
      radius: height / 2,
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({
    required this.controller,
    required this.height,
    required this.width,
    this.radius = 8,
  });

  final Animation<double> controller;
  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + controller.value * 2, 0),
              end: Alignment(1 + controller.value * 2, 0),
              colors: const <Color>[
                AppColors.surfaceF5,
                AppColors.borderSoft,
                AppColors.surfaceF5,
              ],
            ),
          ),
        );
      },
    );
  }
}
