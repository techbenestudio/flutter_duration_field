import './duration_form_controller.dart';
import './model/duration_field_mode.dart';
import './model/value_labels.dart';
import 'package:flutter/material.dart';
import './utils.dart';

/// A widget with separate inputs for duration input
class DurationField extends StatefulWidget {
  /// This callback is called with the raw int values and converted [Duration]
  final Function(List<int?>, Duration)? onChanged;

  /// Supports Hours Minutes Seconds or Minutes Seconds mode, defaults [DurationFieldMode.hms]
  final DurationFieldMode mode;

  /// Adds * to the field label if field is required
  final bool mandatory;

  /// Label displayed above the field
  final String? label;

  /// Initial [Duration] value
  final Duration? initialDuration;

  /// Unit abbreviation displayed under each field, defaults to hrs., min, sec
  final ValueLabels valueLabels;

  const DurationField(
      {Key? key,
      this.onChanged,
      this.mode = DurationFieldMode.hms,
      this.mandatory = false,
      this.label,
      this.initialDuration,
      this.valueLabels = const ValueLabels.eng()})
      : super(key: key);

  @override
  _DurationFieldState createState() => _DurationFieldState();
}

class _DurationFieldState extends State<DurationField> {
  late DurationFormController formController;
  bool elevated = false;

  @override
  void initState() {
    super.initState();

    final initialValues = widget.initialDuration != null ? getInitialValue(widget.initialDuration!) : null;

    formController = DurationFormController(initialValues);

    formController.value$.listen((value) {
      if (value != null) {
        handleChange(value);
      }
    });

    formController.expanded$.listen((event) {
      setState(() {
        elevated = event;
      });
    });
  }

  List<int>? getInitialValue(Duration duration) {
    if (isHms) {
      return duration.inHms;
    }

    if (isMs) {
      return duration.inMs;
    }
  }


  void handleChange(List<int?> newValues) {
    Duration? newDuration;

    if (!newValues.contains(null)) {
      if (isHms) {
        newDuration = Duration(hours: newValues[0]!, minutes: newValues[1]!, seconds: newValues[2]!);
      }

      if (isMs) {
        newDuration = Duration(minutes: newValues[0]!, seconds: newValues[1]!);
      }
    }

    if (newDuration != null) {
      widget.onChanged?.call(newValues, newDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle? _getLabelStyle() {
      final theme = Theme.of(context);


      if (elevated) {
        final primary = theme.colorScheme.primaryVariant;

        return theme.textTheme.bodyText2?.copyWith(color: primary);
      } else {
        return theme.textTheme.subtitle1;
      }
    }

    List<Widget> _getFields() {
      final List<Widget> fields = [];

      final hrs = widget.valueLabels.hrs;
      final min = widget.valueLabels.min;
      final sec = widget.valueLabels.sec;

      if (isMs) {
        fields.addAll([
          _DurationFieldItem(formController: formController, abbreviation: min),
          _DurationFieldDivider(visible: elevated),
          _DurationFieldItem(
            formController: formController,
            abbreviation: sec,
            max: 59,
          )
        ]);
      }

      if (isHms) {
        fields.addAll([
          _DurationFieldItem(formController: formController, abbreviation: hrs),
          _DurationFieldDivider(visible: elevated),
          _DurationFieldItem(
            formController: formController,
            abbreviation: min,
            max: 59,
          ),
          _DurationFieldDivider(visible: elevated),
          _DurationFieldItem(
            formController: formController,
            abbreviation: sec,
            max: 59,
          ),
        ]);
      }

      return fields;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: IntrinsicWidth(
        child: Stack(children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            left: 0,
            top: elevated ? 0 : 15,
            child: Text(
              widget.label == null ? '' : "${widget.label}${widget.mandatory ? '*' : ''}",
              style: _getLabelStyle(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Focus(
              focusNode: formController.focusNode,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _getFields(),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    formController.dispose();
    super.dispose();
  }

  bool get isHms => widget.mode == DurationFieldMode.hms;
  bool get isMs => widget.mode == DurationFieldMode.ms;
}

class _DurationFieldDivider extends StatelessWidget {
  final bool visible;

  const _DurationFieldDivider({Key? key, required this.visible}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.bodyText2;

    if (!visible) {
      textStyle = textStyle?.copyWith(color: Colors.transparent);
    }

    return Padding(
      padding: const EdgeInsets.only(right: 1, top: 8),
      child: Text(
        ":",
        style: textStyle,
      ),
    );
  }
}

class _DurationFieldItem extends StatelessWidget {
  final DurationFormController formController;
  final int? max;
  final String abbreviation;

  const _DurationFieldItem({
    Key? key,
    required this.formController,
    this.max,
    required this.abbreviation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DurationNumberField(
          formController: formController,
          max: max,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(abbreviation, style: Theme.of(context).textTheme.overline,),
        ),
      ],
    );
  }
}
/// A single time input field
class _DurationNumberField extends StatefulWidget {
  final int? max;
  final DurationFormController formController;

  const _DurationNumberField({Key? key, this.max, required this.formController}) : super(key: key);

  @override
  State<_DurationNumberField> createState() => _DurationNumberFieldState();
}

class _DurationNumberFieldState extends State<_DurationNumberField> {
  late DurationFieldController _fieldController;
  bool textVisible = false;

  @override
  void initState() {
    super.initState();
    _fieldController = widget.formController.registerField(widget.max);

    widget.formController.expanded$.listen((event) {
      setState(() {
        textVisible = event;
      });
    });
  }

  TextEditingController get _controller => _fieldController.controller;

  @override
  Widget build(BuildContext context) {
    TextStyle? _getTextStyle() {
      final textStyle = Theme.of(context).textTheme.subtitle1;

      if (textVisible) {
        return textStyle;
      } else {
        return textStyle?.copyWith(color: Colors.transparent);
      }
    }

    return SizedBox(
      width: 20,
      child: TextField(
        controller: _controller,
        focusNode: _fieldController.focusNode,
        keyboardType: TextInputType.number,
        inputFormatters: _fieldController.inputFormatters,
        style: _getTextStyle(),
        decoration: const InputDecoration(
          isDense: true,
        ),
      ),
    );
  }
}
