import 'package:graphviz/src/language/edge_op.dart';
import 'package:graphviz/src/language/statement.dart';
import 'package:graphviz/src/language/stmt_list.dart';
import 'package:graphviz/src/util.dart';

/// The type of a graph.
enum GraphType {
  /// A normal, undirected graph.
  graph('graph'),

  /// A directed graph.
  digraph('digraph');

  /// The encoded value of this graph type.
  final String value;

  const GraphType(this.value);

  /// Create a [GraphType] from its encoded value.
  factory GraphType.fromValue(String value) =>
      values.singleWhere((type) => type.value == value.toLowerCase());

  @override
  String toString() => value;
}

/// A graph.
///
/// Graphs can be parsed using [DotParser.parseGraph] and can be converted back to Dot Language by
/// calling [toString]. See [Graph.create] and [Graph.fromStatements] for creating a graph
/// programmatically.
class Graph {
  /// Whether this graph is in strict mode.
  ///
  /// https://graphviz.org/doc/info/lang.html#lexical-and-semantic-notes:
  /// > A graph may also be described as strict. This forbids the creation of multi-edges, i.e.,
  ///   there can be at most one edge with a given tail node and head node in the directed case. For
  ///   undirected graphs, there can be at most one edge connected to the same two nodes. Subsequent
  ///   edge statements using the same two nodes will identify the edge with the previously defined
  ///   one and apply any attributes given in the edge statement.
  final bool strict;

  /// The type of this graph.
  final GraphType type;

  /// The ID of this graph.
  final String? id;

  /// The statement list that composes this graph.
  final StmtList stmtList;

  const Graph({required this.id, required this.stmtList, required this.strict, required this.type});

  /// Create a graph from a list of statements.
  factory Graph.fromStatements({
    String? id,
    GraphType type = GraphType.graph,
    bool strict = false,
    required List<Statement> statements,
  }) =>
      Graph(
        id: id,
        stmtList: StmtList(statements),
        strict: strict,
        type: type,
      );

  /// Create a graph from a mapping of node to connected nodes.
  factory Graph.create({
    String? id,
    GraphType type = GraphType.graph,
    bool strict = false,
    required Map<String, List<String>> data,
  }) =>
      Graph(
        id: id,
        stmtList: StmtList(dataToStatements(
          data,
          type == GraphType.graph ? EdgeOp.directed : EdgeOp.undirected,
        )),
        strict: strict,
        type: type,
      );

  /// Convert a graph into a mapping of node to connected nodes.
  Map<String, List<String>> toData({bool inlineSubgraphs = true}) => statementsToData(
        stmtList.statements,
        inlineSubgraphs,
      );

  @override
  int get hashCode => Object.hash(strict, type, id, stmtList);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          (other as Graph).strict == strict &&
          other.type == type &&
          other.id == id &&
          other.stmtList == stmtList);

  @override
  String toString() => '${strict ? 'strict ' : ''}$type${id != null ? ' $id' : ''} {\n'
      '  ${stmtList.toString().replaceAll('\n', '\n  ')}\n}';
}
