import 'package:facetest/controller/face_capture_cubit.dart';
import 'package:facetest/controller/face_capture_state.dart';
import 'package:flutter/material.dart';



class ControllerSelect<T> extends StatefulWidget {
  final FaceCaptureController controller;
  final T Function(FaceCaptureState state) selector;
  final Widget Function(BuildContext context, T value) builder;

  const ControllerSelect({super.key, 
    required this.controller,
    required this.selector,
    required this.builder,
  });

  @override
  State<ControllerSelect<T>> createState() => _ControllerSelectState<T>();
}

class _ControllerSelectState<T> extends State<ControllerSelect<T>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.selector(widget.controller.state);
    widget.controller.addListener(_handleChange);
  }

  @override
  void didUpdateWidget(ControllerSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleChange);
      widget.controller.addListener(_handleChange);
    }
    final next = widget.selector(widget.controller.state);
    if (next != _value) {
      _value = next;
    }
  }

  void _handleChange() {
    final next = widget.selector(widget.controller.state);
    if (next == _value) return;
    setState(() => _value = next);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _value);
}
