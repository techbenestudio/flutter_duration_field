import './time_form_controller.dart';
import './model/time_field_mode.dart';
import './model/value_labels.dart';
import 'package:flutter/material.dart';

class TimeField extends StatefulWidget {
  final Function(List<int?>) onChanged;
  final TimeFieldMode mode;
  final bool mandatory;
  final String? label;
  final List<int>? initialValue;
  final ValueLabels valueLabels;

  const TimeField(
      {Key? key,
      required this.onChanged,
      required this.mode,
      this.mandatory = false,
      this.label,
      this.initialValue,
      this.valueLabels = const ValueLabels.eng()})
      : super(key: key);

  @override
  _TimeFieldState createState() => _TimeFieldState();
}

class _TimeFieldState extends State<TimeField> {
  late TimeFormController formController;
  bool elevated = false;

  @override
  void initState() {
    super.initState();

    formController = TimeFormController(widget.initialValue);

    formController.value$.listen((value) {
      if (value != null) {
        widget.onChanged(value);
      }
    });

    formController.expanded$.listen((event) {
      setState(() {
        elevated = event;
      });
    });
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

      if (widget.mode == TimeFieldMode.ms) {
        fields.addAll([
          _TimeFieldItem(formController: formController, abbreviation: min),
          _TimeFieldDivider(visible: elevated),
          _TimeFieldItem(
            formController: formController,
            abbreviation: sec,
            max: 59,
          )
        ]);
      }

      if (widget.mode == TimeFieldMode.hms) {
        fields.addAll([
          _TimeFieldItem(formController: formController, abbreviation: hrs),
          _TimeFieldDivider(visible: elevated),
          _TimeFieldItem(
            formController: formController,
            abbreviation: min,
            max: 59,
          ),
          _TimeFieldDivider(visible: elevated),
          _TimeFieldItem(
            formController: formController,
            abbreviation: sec,
            max: 59,
          ),
        ]);
      }

      return fields;
    }

    return IntrinsicWidth(
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
    );
  }

  @override
  void dispose() {
    formController.dispose();
    super.dispose();
  }
}

class _TimeFieldDivider extends StatelessWidget {
  final bool visible;

  const _TimeFieldDivider({Key? key, required this.visible}) : super(key: key);

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

class _TimeFieldItem extends StatelessWidget {
  final TimeFormController formController;
  final int? max;
  final String abbreviation;

  const _TimeFieldItem({
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
        _TimeNumberField(
          formController: formController,
          max: max,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3),
          // child: TypeScale.subCaption(Text(abbreviation, style: const TextStyle(color: AppTheme.gray2))),
          child: Text(abbreviation),
        ),
      ],
    );
  }
}

class _TimeNumberField extends StatefulWidget {
  final int? max;
  final TimeFormController formController;

  const _TimeNumberField({Key? key, this.max, required this.formController}) : super(key: key);

  @override
  State<_TimeNumberField> createState() => _TimeNumberFieldState();
}

class _TimeNumberFieldState extends State<_TimeNumberField> {
  late TimeFieldController _fieldController;
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
