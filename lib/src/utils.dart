const zeroPrefixChar = '\u200b';

String trimZeroSpace(String s) {
  return s.replaceAll(RegExp(r'\u200b'),'');
}

int parsePrefixed(String s) {
  return int.parse(trimZeroSpace(s));
}

int? parsePrefixedOrNull(String s) {
  try {
    return parsePrefixed(s);
  } catch (_) {
    return null;
  }
}

class ConvertDuration {
  static List<int> toHms(Duration duration) {
    int remainder = duration.inSeconds;

    final hours = remainder ~/ 3600;
    remainder = remainder - hours * 3600;
    final minutes = remainder ~/ 60;
    final seconds = remainder - minutes * 60;

    return [hours, minutes, seconds];
  }

  static List<int> toMs(Duration duration) {
    int remainder = duration.inSeconds;

    final minutes = remainder ~/ 60;
    final seconds = remainder - minutes * 60;

    return [minutes, seconds];
  }
}
