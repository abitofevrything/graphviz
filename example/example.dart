import 'package:graphviz/graphviz.dart';

void main() {
  final parser = DotParser();

  print(parser.parseGraph('''
strict graph { 
  a -- b
  a -- b
  b -- a [color=blue]
} 
'''));
}
