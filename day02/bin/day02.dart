import 'dart:io';

import 'package:args/args.dart';

/// Builds the argument parser.
ArgParser buildParser() {
  return ArgParser()..addFlag(
    'help',
    abbr: 'h',
    negatable: false,
    help: 'Print this help message',
  );
}

/// Prints information on how to use the tool.
void printUsage(ArgParser argParser) {
  print('Usage: dart day02.dart <flags> input-file');
  print(argParser.usage);
}

/// Returns the [rawContents] of the input file as a list of ranges.
List<(int, int)> getRanges(String rawContents) {
  return rawContents.split(',').map((String range) {
    final entries = range.split('-');
    return (int.parse(entries[0]), int.parse(entries[1]));
  }).toList();
}

/// Returns true if the [id] contains a digit sequence repeated exactly twice.
///
/// Examples for IDs that contain a twice-repeating sequence:
///  - 1010
///  - 222222
///  - 446446
bool hasTwoIdenticalHalves(String id) {
  if (id.length < 2 || id.length.isOdd) return false;
  final half = id.length ~/ 2;
  return id.substring(0, half) == id.substring(half, id.length);
}

/// Returns true if the [id] contains a repeated digit pattern.
///
/// The pattern can be repeated an arbitrary number of times. Examples for IDs
/// that contain a repeating pattern:
///  - 666
///  - 21212121
///  - 824824824
///
/// Explanation of the algorithm: If there is a repeating pattern, its length
/// must be one of the factors of the id length, e.g. ID of length 8 => length
/// of pattern must be 1, 2, or 4. For each of these factors we check if the id
/// rotated by this value is equal to the original id.
bool hasRepeatingPattern(String id) {
  int l = id.length;
  for (int i = 1; i <= (l ~/ 2); i++) {
    if (l % i != 0) continue;
    String rotated = id.substring(i) + id.substring(0, i);
    if (rotated == id) return true;
  }
  return false;
}

/// Returns all IDs in the given [ranges] which satisfy [isInvalid].
List<int> getInvalidIds(
  List<(int, int)> ranges,
  bool Function(String) isInvalid,
) {
  final invalidIds = <int>[];
  for (final (start, end) in ranges) {
    for (int id = start; id <= end; id++) {
      if (isInvalid(id.toString())) invalidIds.add(id);
    }
  }
  return invalidIds;
}

void main(List<String> arguments) {
  final ArgParser argParser = buildParser();
  final ArgResults results = argParser.parse(arguments);

  if (results.flag('help')) {
    printUsage(argParser);
    return;
  }

  if (results.rest.length != 1) {
    print('Program requires exactly one argument (input-file)');
    exitCode = 2;
    return;
  }

  final file = File(results.rest[0]);
  if (!file.existsSync()) {
    print('Given file "${file.path}" does not exist');
    exitCode = 2;
    return;
  }

  final ranges = getRanges(file.readAsStringSync());

  final invalidIds = getInvalidIds(ranges, hasTwoIdenticalHalves);
  print(invalidIds.reduce((a, b) => a + b));

  final invalidIds2 = getInvalidIds(ranges, hasRepeatingPattern);
  print(invalidIds2.reduce((a, b) => a + b));
}
