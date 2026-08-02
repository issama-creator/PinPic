class FuzzyMatcher {
  bool isMatch(String source, String target) {
    final a = source.toLowerCase();
    final b = target.toLowerCase();
    if (a == b) return true;
    if (a.length < 4 || b.length < 4) return false;
    final maxDistance = a.length >= 8 || b.length >= 8 ? 2 : 1;
    return distance(a, b, maxDistance: maxDistance) <= maxDistance;
  }

  double similarity(String source, String target) {
    if (source.isEmpty && target.isEmpty) return 1;
    final maxLength = source.length > target.length
        ? source.length
        : target.length;
    if (maxLength == 0) return 1;
    return 1 - (distance(source, target) / maxLength);
  }

  int distance(String source, String target, {int? maxDistance}) {
    if (source == target) return 0;
    if (source.isEmpty) return target.length;
    if (target.isEmpty) return source.length;
    if (maxDistance != null &&
        (source.length - target.length).abs() > maxDistance) {
      return maxDistance + 1;
    }

    var previousPrevious = List<int>.filled(target.length + 1, 0);
    var previous = List<int>.generate(target.length + 1, (index) => index);

    for (var i = 1; i <= source.length; i++) {
      final current = List<int>.filled(target.length + 1, 0);
      current[0] = i;
      var rowMinimum = current[0];

      for (var j = 1; j <= target.length; j++) {
        final substitutionCost =
            source.codeUnitAt(i - 1) == target.codeUnitAt(j - 1) ? 0 : 1;
        var value = _min3(
          previous[j] + 1,
          current[j - 1] + 1,
          previous[j - 1] + substitutionCost,
        );

        if (i > 1 &&
            j > 1 &&
            source.codeUnitAt(i - 1) == target.codeUnitAt(j - 2) &&
            source.codeUnitAt(i - 2) == target.codeUnitAt(j - 1)) {
          final transposition = previousPrevious[j - 2] + 1;
          if (transposition < value) value = transposition;
        }

        current[j] = value;
        if (value < rowMinimum) rowMinimum = value;
      }

      if (maxDistance != null && rowMinimum > maxDistance) {
        return maxDistance + 1;
      }
      previousPrevious = previous;
      previous = current;
    }

    return previous[target.length];
  }

  int _min3(int a, int b, int c) {
    var result = a < b ? a : b;
    if (c < result) result = c;
    return result;
  }
}
