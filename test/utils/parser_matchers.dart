import 'package:test/test.dart';
import 'package:petitparser/petitparser.dart';

TypeMatcher<Success<T>> isSuccessContext<T>({
  dynamic position = anything,
  dynamic value = anything,
}) =>
    isA<Success<T>>()
        .having((context) => context.value, 'value', value)
        .having((context) => context.position, 'position', position);

Matcher isParseSuccess<T>(
  String input,
  dynamic result, {
  dynamic position,
}) =>
    isA<Parser<T>>()
        .having((parser) => parser.parse(input), 'parse',
            isSuccessContext<T>(value: result, position: position ?? input.length))
        .having((parser) => parser.fastParseOn(input, 0), 'fastParseOn', position ?? input.length)
        .having((parser) => parser.accept(input), 'accept', isTrue)
        .having((parser) => parser.allMatches(input).first, 'allMatches', result);
