import 'dart:async';

import './time_text_formatter.dart';
import './utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

class TimeFieldEvent {
  final String newValue;
  final bool filled;
  final bool empty;

  const TimeFieldEvent({required this.newValue, required this.filled, required this.empty});
}

class TimeFieldController {
  late final TextEditingController controller;
  final focusNode = FocusNode();
  late List<TextInputFormatter> inputFormatters;
  final int? maxValue;
  final bool zeroPrefix;
  bool nextEventProgrammatic = false;
  late String prevText;
  final _event$ = StreamController<TimeFieldEvent>.broadcast();
  final int? initialValue;

  TimeFieldController({this.maxValue, required this.zeroPrefix, this.initialValue}) {
    final defaultText = initialValue != null ? formatValue(initialValue!) : defaultValue;

    controller = TextEditingController(text: defaultText);
    prevText = defaultText;

    inputFormatters = [
      LengthLimitingTextInputFormatter(inputLength),
      TimeTextFormatter.zeroSpaceAndDigits,
    ];

    if (maxValue != null) {
      inputFormatters.add(TimeTextFormatter.maxValue(maxValue!));
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
    print(focusNode.hasFocus);
    if (focusNode.hasFocus) {
      text = emptyValue;
      setCursorPosition();
    } else {
      final int? value = parsePrefixedOrNull(text);

      if (value == null || value == 0) {
        text = defaultValue;
      } else {
        text = formatValue(value);
      }
    }
  }

  void handleValueChange() {
    if (!nextEventProgrammatic) {
      _event$.add(TimeFieldEvent(
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

  Stream<TimeFieldEvent> get event$ => _event$.stream;
}

typedef TimeFieldValue = List<int?>;

class TimeFormController {
  final List<TimeFieldController> fields = [];
  final _expanded$ = BehaviorSubject<bool>.seeded(false);
  final  _value$ = BehaviorSubject<TimeFieldValue?>.seeded(null);
  TimeFieldValue? currentValue;
  final focusNode = FocusNode();
  bool hasValue = false;
  final List<int>? initialValue;

  TimeFormController([this.initialValue]) {
    if (initialValue != null) {
      hasValue = true;
      emitExpanded();
    }


    focusNode.addListener(() {
      emitExpanded();
    });
  }

  TimeFieldController registerField(int? maxValue) {
    final int index = fields.length;
    final newField = TimeFieldController(maxValue: maxValue, zeroPrefix: index != 0, initialValue: initialValue?[index]);
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
      final fieldValue = parsePrefixedOrNull(field.text);
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
