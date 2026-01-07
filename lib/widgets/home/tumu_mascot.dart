import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../../models/mascot_state.dart';

/// Widget untuk Tumu Mascot dengan Rive Animation + Touch Interaction
class TumuMascot extends StatefulWidget {
  final MascotState state;
  final double size;
  final VoidCallback? onTap; // 🆕 Callback saat di-tap

  const TumuMascot({
    super.key,
    required this.state,
    this.size = 300,
    this.onTap,
  });

  @override
  State<TumuMascot> createState() => _TumuMascotState();
}

class _TumuMascotState extends State<TumuMascot> {
  StateMachineController? _controller;

  // State inputs
  SMIInput<bool>? _normalInput;
  SMIInput<bool>? _highTempInput;
  SMIInput<bool>? _lowTempInput;
  SMIInput<bool>? _unstablePhInput;
  SMIInput<bool>? _lowNutrientInput;
  SMIInput<bool>? _lowLevelWaterInput; // 🆕
  SMIInput<bool>? _highLevelWaterInput; // 🆕
  SMIInput<bool>? _noSignalInput; // 🆕

  // Touch trigger (🆕 untuk animasi saat di-tap)
  SMITrigger? _touchTrigger;

  @override
  void initState() {
    super.initState();
    debugPrint('🎭 [TUMU] Init with state: ${widget.state.emoji}');
  }

  void _onRiveInit(Artboard artboard) {
    debugPrint('🎨 [TUMU] Rive initialized');

    final controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
    );

    if (controller == null) {
      debugPrint('❌ [TUMU] State Machine not found!');
      return;
    }

    artboard.addController(controller);
    _controller = controller;

    // Find state inputs
    _normalInput = controller.findInput<bool>('Normal');
    _highTempInput = controller.findInput<bool>('High Temperature');
    _lowTempInput = controller.findInput<bool>('Low Temperature');
    _unstablePhInput = controller.findInput<bool>('Unstable Ph');
    _lowNutrientInput = controller.findInput<bool>('Low Nutrient');
    _lowLevelWaterInput = controller.findInput<bool>('Low Level Water'); // 🆕
    _highLevelWaterInput = controller.findInput<bool>('High Level Water'); // 🆕
    _noSignalInput = controller.findInput<bool>('No Signal'); // 🆕

    // 🆕 Find touch trigger
    _touchTrigger = controller.findInput<bool>('Touch') as SMITrigger?;

    // Debug log
    debugPrint('🔍 [TUMU] Inputs found:');
    debugPrint('   Normal: ${_normalInput != null}');
    debugPrint('   High Temp: ${_highTempInput != null}');
    debugPrint('   Low Temp: ${_lowTempInput != null}');
    debugPrint('   Unstable pH: ${_unstablePhInput != null}');
    debugPrint('   Low Nutrient: ${_lowNutrientInput != null}');
    debugPrint('   Low Water: ${_lowLevelWaterInput != null}');
    debugPrint('   High Water: ${_highLevelWaterInput != null}');
    debugPrint('   No Signal: ${_noSignalInput != null}');
    debugPrint('   Touch: ${_touchTrigger != null}');

    _updateRiveState();
  }

  void _updateRiveState() {
    if (_controller == null) return;

    debugPrint('🔄 [TUMU] Switching to: ${widget.state.riveInputName}');

    // Reset all states
    _setInputValue(_normalInput, false);
    _setInputValue(_highTempInput, false);
    _setInputValue(_lowTempInput, false);
    _setInputValue(_unstablePhInput, false);
    _setInputValue(_lowNutrientInput, false);
    _setInputValue(_lowLevelWaterInput, false); // 🆕
    _setInputValue(_highLevelWaterInput, false); // 🆕
    _setInputValue(_noSignalInput, false); // 🆕

    // Set active state
    switch (widget.state) {
      case MascotState.normal:
        _setInputValue(_normalInput, true);
        break;
      case MascotState.highTemperature:
        _setInputValue(_highTempInput, true);
        break;
      case MascotState.lowTemperature:
        _setInputValue(_lowTempInput, true);
        break;
      case MascotState.unstablePh:
        _setInputValue(_unstablePhInput, true);
        break;
      case MascotState.lowNutrient:
        _setInputValue(_lowNutrientInput, true);
        break;
      case MascotState.lowLevelWater: // 🆕
        _setInputValue(_lowLevelWaterInput, true);
        break;
      case MascotState.highLevelWater: // 🆕
        _setInputValue(_highLevelWaterInput, true);
        break;
      case MascotState.noSignal: // 🆕
        _setInputValue(_noSignalInput, true);
        break;
    }
  }

  void _setInputValue(SMIInput<bool>? input, bool value) {
    if (input == null) return;

    if (input is SMIBool) {
      input.value = value;
    } else if (input is SMITrigger) {
      if (value) {
        input.fire();
      }
    }
  }

  // 🆕 Handle tap
  void _handleTap() {
    debugPrint('👆 [TUMU] Tapped!');

    // Fire touch animation
    _touchTrigger?.fire();

    // Call parent callback
    widget.onTap?.call();
  }

  @override
  void didUpdateWidget(TumuMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      debugPrint(
          '🔁 [TUMU] State changed: ${oldWidget.state.emoji} → ${widget.state.emoji}');
      _updateRiveState();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    debugPrint('🗑️ [TUMU] Disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap, // 🆕 Enable tap
      child: Container(
        width: widget.size,
        height: widget.size,
        color: Colors.transparent,
        child: RiveAnimation.asset(
          'assets/rive/tumu.riv',
          fit: BoxFit.contain,
          alignment: Alignment.center,
          onInit: _onRiveInit,
        ),
      ),
    );
  }
}
