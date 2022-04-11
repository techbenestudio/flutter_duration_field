import 'dart:async';

import './number_text_formatter.dart';
import './utils.dart';
import './model/duration_field_event.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

/// This class manages a single input field in [DurationField]. Contains it's [TextEditingController] and [FocusNode] and deals with
/// every logic related to behaviour. Appearance is defined in [_DurationNumberField].
class DurationFieldController {
  /// [TextEditingController] used to control [TextField] in [_DurationNumberField]
  late final TextEditingController controller;

  /// [FocusNode] used to control [TextField] in [_DurationNumberField]
  final focusNode = FocusNode();

  /// This list defines which values allowed to input
  late List<TextInputFormatter> inputFormatters;

  /// Optional maximum value allowed for input
  final int? maxValue;

  /// If true the input field will be prefixed with a zero width unicode character
  final bool zeroPrefix;

  /// Used to differentiate changes triggered by the class and user events
  bool nextEventProgrammatic = false;

  /// Previous value of [TextEditingController.text], used to detect value change
  late String prevText;

  /// Broadcast stream, that can be used by multiple subscribers to listen to [DurationFieldEvent]s
  final _event$ = StreamController<DurationFieldEvent>.broadcast();

  /// Optional initial value of the input field
  final int? initialValue;

  DurationFieldController({this.maxValue, required this.zeroPrefix, this.initialValue}) {
    final defaultText = initialValue != null ? formatValue(initialValue!) : defaultValue;

    controller = TextEditingController(text: defaultText);
    prevText = defaultText;

    inputFormatters = [
      LengthLimitingTextInputFormatter(inputLength),
      NumberTextFormatter.zeroSpaceAndDigits,
    ];

    if (maxValue != null) {
      inputFormatters.add(NumberTextFormatter.maxValue(maxValue!));
    }

    focusNode.addListener(handleFocusChange);

    controller.addListener(() {
      if (controller.text != prevText) {
        handleValueChange();
      }
      prevText = controller.text;
    });
  }

  void handleFocusChange() {
    if (focusNode.hasFocus) {
      text = emptyValue;
      setCursorPosition();
    } else {
      final int? value = text.parsePrefixedOrNull();

      if (value == null || value == 0) {
        text = defaultValue;
      } else {
        text = formatValue(value);
      }
    }
  }

  void handleValueChange() {
    if (!nextEventProgrammatic) {
      _event$.add(DurationFieldEvent(
        newValue: controller.text,
        filled: filled,
        empty: isEmpty,
      ));
    }

    nextEventProgrammatic = false;
  }

  void focus() {
    focusNode.requestFocus();
    setCursorPosition();
  }

  void setCursorPosition() {
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
  }

  void dispose() {
    focusNode.dispose();
    controller.dispose();

    _event$.close();
  }

  String formatValue(int value) {
    return value < 10 ? '${emptyValue}0$value' : '$value';
  }

  String get defaultValue => zeroPrefix ? '${zeroPrefixChar}00' : '00';

  String get emptyValue => zeroPrefix ? zeroPrefixChar : '';

  int get inputLength => zeroPrefix ? 3 : 2;

  bool get isEmpty => controller.text.characters.isEmpty;

  bool get filled => controller.text.characters.length == inputLength;

  String get text => controller.text;

  set text(String newValue) {
    nextEventProgrammatic = true;
    controller.text = newValue;
  }

  Stream<DurationFieldEvent> get event$ => _event$.stream;
}

typedef TimeFieldValue = List<int?>;

/// This class manages a list of [DurationFieldController]s. Moves focus forward when the field filled and move it back when
/// backspace event is detected.
class DurationFormController {
  /// [DurationFieldController]s managed by this class
  final List<DurationFieldController> fields = [];

  /// [BehaviorSubject] broadcasting if the title should be in elevated position and dividers visible
  final _expanded$ = BehaviorSubject<bool>.seeded(false);

  /// [BehaviorSubject] broadcasting current field values
  final _value$ = BehaviorSubject<TimeFieldValue?>.seeded(null);

  /// [FocusNode] used to determine if the focus is inside [DurationField]
  final focusNode = FocusNode();

  /// This flag tracks if at least one field has value
  bool hasValue = false;

  /// Optional initial value
  final List<int>? initialValue;

  DurationFormController([this.initialValue]) {
    if (initialValue != null) {
      hasValue = true;
      emitExpanded();
    }

    focusNode.addListener(() {
      emitExpanded();
    });
  }

  DurationFieldController registerField(int? maxValue) {
    final int index = fields.length;
    final newField = DurationFieldController(maxValue: maxValue, zeroPrefix: index != 0, initialValue: initialValue?[index]);
    fields.add(newField);

    newField.event$.listen((event) {
      handleFieldEvent();

      if (event.empty) {
        focusField(index - 1);
      }
      if (event.filled) {
        focusField(index + 1);
      }
    });

    return newField;
  }

  bool hasField(int index) => index > -1 && index < fields.length;

  void focusField(int index) {
    if (hasField(index)) {
      fields[index].focus();
    }
  }

  void handleFieldEvent() {
    final TimeFieldValue values = [];
    hasValue = false;

    for (final field in fields) {
      final fieldValue = field.text.parsePrefixedOrNull();
      values.add(fieldValue);

      if (fieldValue != null && fieldValue != 0) {
        hasValue = true;
      }
    }

    emitExpanded();
    _value$.add(values);
  }

  void emitExpanded() {
    _expanded$.add(focusNode.hasFocus || hasValue);
  }

  void dispose() {
    for (final element in fields) {
      element.dispose();
    }

    _expanded$.close();
    _value$.close();
  }

  Stream<bool> get expanded$ => _expanded$.stream;

  Stream<TimeFieldValue?> get value$ => _value$.stream;
}
