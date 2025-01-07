String replaceMiddleWithDots(String input) {
  if (input.length <= 30) {
    return input;
  }

  final int middleIndex = input.length ~/ 2;
  final int startIndex = middleIndex - 15;
  final int endIndex = middleIndex + 15;
  return input.substring(0, startIndex) + '...' + input.substring(endIndex);
}

String replaceMiddleWithDots2(String input) {
  if (input.length <= 32) {
    return input;
  }
  final int numCharsToShow = 7;
  final String start = input.substring(0, numCharsToShow);
  final String end = input.substring(input.length - numCharsToShow);
  return "$start...$end";
}