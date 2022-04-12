import './utils.dart';
import 'package:flutter/services.dart';


class NumberTextFormatter {
  static TextInputFormatter maxValue(int max) => _MaxValueTextFormatter(max);
  static final zeroSpaceAndDigits = FilteringTextInputFormatter.allow(RegExp(r'[\u200b 0-9]'));
}

class _MaxValueTextFormatter extends TextInputFormatter {
  final int max;

  _MaxValueTextFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String newText = newValue.text;
    final int? newNumber = newText.parsePrefixedOrNull();

    if (newNumber != null && newText.compareTo(oldValue.text) != 0) {
      return newNumber > max ? oldValue : newValue;
    } else {
      return newValue;
    }
  }
}
