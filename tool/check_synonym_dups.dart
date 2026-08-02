import 'dart:io';

String normalize(String value) =>
    value.trim().toLowerCase().replaceAll('ё', 'е').replaceAll(RegExp(r'\s+'), ' ');

void main() {
  final src = File('lib/services/synonym_engine.dart').readAsStringSync();
  final start = src.indexOf('static const _groups');
  final end = src.indexOf('late final Map');
  final body = src.substring(start, end);

  final tokenToGroup = <String, int>{};
  final dups = <String>{};
  var groupIndex = 0;
  final current = <String>{};
  var depth = 0;

  void flush() {
    if (current.isEmpty) return;
    for (final t in current) {
      final prev = tokenToGroup[t];
      if (prev != null && prev != groupIndex) {
        dups.add(t);
      } else {
        tokenToGroup[t] = groupIndex;
      }
    }
    current.clear();
    groupIndex++;
  }

  for (var i = 0; i < body.length; i++) {
    final ch = body[i];
    if (ch == '{') {
      depth++;
      continue;
    }
    if (ch == '}') {
      depth--;
      if (depth == 0) flush();
      continue;
    }
    if (ch == "'" && depth >= 1) {
      final close = body.indexOf("'", i + 1);
      if (close == -1) break;
      final raw = body.substring(i + 1, close);
      if (RegExp(r'^[a-zA-Zа-яА-ЯёЁ0-9+-]+$').hasMatch(raw)) {
        current.add(normalize(raw));
      }
      i = close;
    }
  }

  stdout.writeln('groups: $groupIndex');
  stdout.writeln('unique tokens: ${tokenToGroup.length}');
  stdout.writeln('cross-group dups (${dups.length}):');
  for (final d in (dups.toList()..sort())) {
    stdout.writeln('  $d');
  }
}
