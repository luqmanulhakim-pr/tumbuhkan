import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../../models/mascot_state.dart';

class TumuMascot extends StatefulWidget {
  final MascotState state;
  final double size;

  const TumuMascot({
    super.key,
    required this.state,
    this.size = 800,
  });

  @override
  State<TumuMascot> createState() => _TumuMascotState();
}

class _TumuMascotState extends State<TumuMascot> {
  StateMachineController? _controller;

  SMIInput<bool>? _normalInput;
  SMIInput<bool>? _highTempInput;
  SMIInput<bool>? _lowTempInput;
  SMIInput<bool>? _unstablePhInput;
  SMIInput<bool>? _lowNutrientInput;
  SMIInput<bool>? _lowLevelWaterInput;
  SMIInput<bool>? _highLevelWaterInput;
  SMIInput<bool>? _noSignalInput;

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
    );

    if (controller == null) return;

    artboard.addController(controller);
    _controller = controller;

    _normalInput = controller.findInput<bool>('Normal');
    _highTempInput = controller.findInput<bool>('High Temperature');
    _lowTempInput = controller.findInput<bool>('Low Temperature');
    _unstablePhInput = controller.findInput<bool>('Unstable Ph');
    _lowNutrientInput = controller.findInput<bool>('Low Nutrient');
    _lowLevelWaterInput = controller.findInput<bool>('Low Level Water');
    _highLevelWaterInput = controller.findInput<bool>('High Level Water');
    _noSignalInput = controller.findInput<bool>('No Signal');

    debugPrint('🌱 [TumuMascot] Rive inputs found:');
    debugPrint('   Normal: ${_normalInput != null}');
    debugPrint('   Unstable Ph: ${_unstablePhInput != null}');
    debugPrint('   Low Nutrient: ${_lowNutrientInput != null}');

    _updateRiveState();
  }

  void _updateRiveState() {
    debugPrint('🌱 [TumuMascot] Updating Rive state to: ${widget.state}');
    if (_controller == null) {
      debugPrint('🌱 [TumuMascot] Controller is null!');
      return;
    }

    _normalInput?.value = false;
    _highTempInput?.value = false;
    _lowTempInput?.value = false;
    _unstablePhInput?.value = false;
    _lowNutrientInput?.value = false;
    _lowLevelWaterInput?.value = false;
    _highLevelWaterInput?.value = false;
    _noSignalInput?.value = false;

    switch (widget.state) {
      case MascotState.normal:
        _normalInput?.value = true;
        break;
      case MascotState.highTemperature:
        _highTempInput?.value = true;
        break;
      case MascotState.lowTemperature:
        _lowTempInput?.value = true;
        break;
      case MascotState.unstablePh:
        _unstablePhInput?.value = true;
        break;
      case MascotState.lowNutrient:
        _lowNutrientInput?.value = true;
        break;
      case MascotState.lowLevelWater:
        _lowLevelWaterInput?.value = true;
        break;
      case MascotState.highLevelWater:
        _highLevelWaterInput?.value = true;
        break;
      case MascotState.noSignal:
        _noSignalInput?.value = true;
        break;
    }
  }

  @override
  void didUpdateWidget(TumuMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _updateRiveState();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RiveAnimation.asset(
        'assets/rive/tumu.riv',
        fit: BoxFit.cover,
        alignment: Alignment.center,
        onInit: _onRiveInit,
      ),
    );
  }
}
