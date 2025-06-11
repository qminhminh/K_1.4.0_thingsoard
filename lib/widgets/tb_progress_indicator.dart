import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thingsboard_app/constants/assets_path.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';

class TbProgressIndicator extends ProgressIndicator {
  final double size;
  final TbContext tbContext;

  const TbProgressIndicator(
    this.tbContext, {
    Key? key,
    this.size = 36.0,
    Animation<Color?>? valueColor,
    String? semanticsLabel,
    String? semanticsValue,
  }) : super(
          key: key,
          value: null,
          valueColor: valueColor,
          semanticsLabel: semanticsLabel,
          semanticsValue: semanticsValue,
        );

  @override
  State<StatefulWidget> createState() => _TbProgressIndicatorState();

  Color _getValueColor(BuildContext context) =>
      valueColor?.value ?? Theme.of(context).primaryColor;
}

class _TbProgressIndicatorState extends State<TbProgressIndicator>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  CurvedAnimation? _rotation;

  @override
  void initState() {
    super.initState();
    if (!widget.tbContext.wlService.isCustomLogo) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
        upperBound: 1,
        animationBehavior: AnimationBehavior.preserve,
      );
      _rotation =
          CurvedAnimation(parent: _controller!, curve: Curves.easeInOut);
      _controller!.repeat();
    }
  }

  @override
  void didUpdateWidget(TbProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tbContext.wlService.isCustomLogo) {
      if (_controller != null) {
        _controller!.dispose();
        _controller = null;
      }
    } else {
      if (_controller == null) {
        _controller = AnimationController(
          duration: const Duration(milliseconds: 1500),
          vsync: this,
          upperBound: 1,
          animationBehavior: AnimationBehavior.preserve,
        );
        _rotation =
            CurvedAnimation(parent: _controller!, curve: Curves.easeInOut);
        _controller!.repeat();
      } else if (!_controller!.isAnimating) {
        _controller!.repeat();
      }
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tbContext.wlService.isCustomLogo) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          color: widget._getValueColor(context),
        ),
      );
    } else {
      return Stack(
        children: [
          Image.asset(
            'assets/images/logoapp.png',
            height: widget.size,
            width: 48,
            fit: BoxFit.contain,
          ),
          AnimatedBuilder(
            animation: _rotation!,
            child: SvgPicture.asset(
              ThingsboardImage.thingsboardOuter,
              height: widget.size,
              width: 100,
              colorFilter: const ColorFilter.mode(
                // Thay đổi màu thành xanh lá cây sáng (gần với ảnh)
                Color(0xFFF15A24), // Màu xanh lá cây (#00FF00)
                BlendMode.srcIn,
              ),
            ),
            builder: (BuildContext context, Widget? child) {
              return Transform.rotate(
                angle: _rotation!.value * pi * 2,
                child: child,
              );
            },
          ),
        ],
      );
    }
  }
}
