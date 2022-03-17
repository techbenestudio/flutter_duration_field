import 'package:duration_field/src/time_field.dart';
import 'package:duration_field/src/utils.dart';

import './model/time_field_mode.dart';
import 'package:flutter/material.dart';

/*
todo: support textedeting controller
todo: initial value: duration or text
 */
class DurationField extends StatefulWidget {
  final Function(Duration)? onChanged;

  // final Field field;
  final TimeFieldMode mode;

  const DurationField({
    Key? key,
    this.onChanged,
    // required this.field,
    this.mode = TimeFieldMode.hms,
  }) : super(key: key);

  @override
  _DurationFieldState createState() => _DurationFieldState();
}

class _DurationFieldState extends State<DurationField> {
  List<int>? initialValue;

  @override
  void initState() {
    super.initState();

    // todo: deal with initial Duration here
    /*
    final duration = widget.field.value as Duration?;

    if (duration != null) {
      initialValue = getInitialValue(duration);
    }
    */
  }

  List<int>? getInitialValue(Duration duration) {
    if (isHms) {
      return ConvertDuration.toHms(duration);
    }

    if (isMs) {
      return ConvertDuration.toMs(duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final formHandler = context.safeWatch<FormHandler>();

    void handleChange(List<int?> newValues) {
      if (!newValues.contains(null)) {
        Duration? newDuration;

        if (isHms) {
          newDuration = Duration(hours: newValues[0]!, minutes: newValues[1]!, seconds: newValues[2]!);
        }

        if (isMs) {
          newDuration = Duration(minutes: newValues[0]!, seconds: newValues[1]!);
        }

        if (newDuration != null) {
          // formHandler?.setFieldValue(widget.field.key, newDuration);
          widget.onChanged?.call(newDuration);
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TimeField(
        onChanged: handleChange,
        mode: widget.mode,
        // label: widget.field.label,
        label: 'lb',
        initialValue: initialValue,
      ),
    );
  }

  bool get isHms => widget.mode == TimeFieldMode.hms;

  bool get isMs => widget.mode == TimeFieldMode.ms;
}
