const zeroPrefixChar = '\u200b';

extension ZeroWidthChar on String {
  String trimZeroSpace() {
    return replaceAll(RegExp(r'\u200b'),'');
  }

  int parsePrefixed() {
    return int.parse(trimZeroSpace());
  }

  int? parsePrefixedOrNull() {
    try {
      return parsePrefixed();
    } catch (_) {
      return null;
    }
  }
}

extension DurationConverter on Duration {
  List<int> get inHms {
    int remainder = inSeconds;

    final hours = remainder ~/ 3600;
    remainder = remainder - hours * 3600;
    final minutes = remainder ~/ 60;
    final seconds = remainder - minutes * 60;

    return [hours, minutes, seconds];
  }

  List<int> get inMs {
    int remainder = inSeconds;

    final minutes = remainder ~/ 60;
    final seconds = remainder - minutes * 60;

    return [minutes, seconds];
  }
}
