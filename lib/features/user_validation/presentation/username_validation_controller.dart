/// Debounced username-existence controller.
///
/// Each search field (Import + Profile Scanner) owns one instance in
/// its widget state. `updateInput` is called on every text change +
/// source toggle; the controller debounces [_debounce] before firing a
/// network check against `UsernameValidator`. A generation counter
/// guards against stale in-flight futures: if the user types more
/// characters before the previous request resolves, the older result
/// is discarded so the pill always reflects the latest input.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/username_validator.dart';

enum ValidationPhase { idle, debouncing, loading, result }

class UsernameValidationState {
  const UsernameValidationState({
    required this.phase,
    required this.existence,
    required this.query,
  });

  const UsernameValidationState.idle()
      : phase = ValidationPhase.idle,
        existence = UsernameExistence.unknown,
        query = '';

  final ValidationPhase phase;
  final UsernameExistence existence;
  final String query;

  bool get isResolved =>
      phase == ValidationPhase.result &&
      existence != UsernameExistence.unknown;
  bool get isGreen =>
      isResolved && existence == UsernameExistence.exists;
  bool get isRed =>
      isResolved && existence == UsernameExistence.missing;
  bool get isSpinning =>
      phase == ValidationPhase.debouncing ||
      phase == ValidationPhase.loading;
}

class UsernameValidationController extends ValueNotifier<UsernameValidationState> {
  UsernameValidationController(this._validator)
      : super(const UsernameValidationState.idle());

  final UsernameValidator _validator;
  Timer? _debounce;
  int _generation = 0;

  static const _debounceWindow = Duration(milliseconds: 400);
  static const _minLength = 2;

  /// Called on every keystroke + source toggle. Resets the pill to idle
  /// when the field is cleared; otherwise schedules a check.
  void updateInput({required String source, required String username}) {
    final trimmed = username.trim();
    _debounce?.cancel();
    _generation++;
    final gen = _generation;

    if (trimmed.length < _minLength) {
      value = const UsernameValidationState.idle();
      return;
    }

    value = UsernameValidationState(
      phase: ValidationPhase.debouncing,
      existence: UsernameExistence.unknown,
      query: trimmed,
    );
    _debounce = Timer(_debounceWindow, () => _fire(gen, source, trimmed));
  }

  Future<void> _fire(int gen, String source, String username) async {
    if (gen != _generation) return;
    value = UsernameValidationState(
      phase: ValidationPhase.loading,
      existence: UsernameExistence.unknown,
      query: username,
    );
    final result = await _validator.check(
      source: source,
      username: username,
    );
    if (gen != _generation) return;
    value = UsernameValidationState(
      phase: ValidationPhase.result,
      existence: result,
      query: username,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
