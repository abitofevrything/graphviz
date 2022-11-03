import 'package:graphviz/src/dot_grammar.dart';
import 'package:graphviz/src/language/a_list.dart';
import 'package:graphviz/src/language/attr_list.dart';
import 'package:graphviz/src/language/compass_pt.dart';
import 'package:graphviz/src/language/edge_rhs.dart';
import 'package:graphviz/src/language/graph.dart';
import 'package:graphviz/src/language/node_id.dart';
import 'package:graphviz/src/language/port.dart';
import 'package:graphviz/src/language/statement.dart';
import 'package:graphviz/src/language/stmt_list.dart';
import 'package:graphviz/src/language/subgraph.dart';
import 'package:petitparser/petitparser.dart';

/// A helper class to make working with parsing easier.
///
/// Most users will want to use [parseGraph] to parse an entire graph, but methods for each
/// individual element of the Dot Language are available.
class DotParser {
  /// The instance of [DotGrammar] backing this parser.
  final DotGrammar grammar = DotGrammar();

  Graph parseGraph(String input) => grammar.build(start: grammar.graph).end().parse(input).value;
  StmtList parseStmtList(String input) =>
      grammar.build(start: grammar.stmtList).end().parse(input).value;
  Statement parseStatement(String input) =>
      grammar.build(start: grammar.stmt).end().parse(input).value;
  AttrStatement parseAttrStatement(String input) =>
      grammar.build(start: grammar.attrStmt).end().parse(input).value;
  AttrList parseAttrList(String input) =>
      grammar.build(start: grammar.attrList).end().parse(input).value;
  AList parseAList(String input) => grammar.build(start: grammar.aList).end().parse(input).value;
  EdgeStatement parseEdgeStatement(String input) =>
      grammar.build(start: grammar.edgeStmt).end().parse(input).value;
  EdgeRhs parseEdgeRhs(String input) =>
      grammar.build(start: grammar.edgeRhs).end().parse(input).value;
  NodeStatement parseNodeStatement(String input) =>
      grammar.build(start: grammar.nodeStmt).end().parse(input).value;
  NodeId parseNodeId(String input) => grammar.build(start: grammar.nodeId).end().parse(input).value;
  Port parsePort(String input) => grammar.build(start: grammar.port).end().parse(input).value;
  Subgraph parseSubgraph(String input) =>
      grammar.build(start: grammar.subgraph).end().parse(input).value;
  CompassPt parseCompassPt(String input) =>
      grammar.build(start: grammar.compassPt).end().parse(input).value;
}
