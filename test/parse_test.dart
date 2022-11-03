import 'dart:io';

import 'package:graphviz/src/dot_grammar.dart';
import 'package:test/test.dart';

import 'utils/parser_matchers.dart';

void main() async {
  final files = await Directory('test/test_graphs')
      .list()
      .where((file) => file.path.endsWith('.gv'))
      .cast<File>()
      .toList();

  group('parsing test', () {
    final parser = DotGrammar().build();

    for (final file in files) {
      test(file.path, () async {
        expect(parser.parse(await file.readAsString()), isSuccessContext());

        print('\n\n\n\n\n ${parser.parse(await file.readAsString()).value}');
      });
    }
  });
}
