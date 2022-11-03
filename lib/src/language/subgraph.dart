import 'package:graphviz2/graphviz.dart';

/// A subgraph within a larger graph.
class Subgraph implements EdgeTarget, Statement {
  /// The id of this subgraph.
  final String? id;

  /// The list of statements that make up this subgraph.
  final StmtList stmtList;

  const Subgraph(this.id, this.stmtList);

  /// Create a subgraph from a list of statements.
  factory Subgraph.fromStatements({
    String? id,
    required List<Statement> statements,
  }) =>
      Subgraph(
        id,
        StmtList(statements),
      );

  /// Create a graph from a mapping of node to connected nodes.
  factory Subgraph.create({
    String? id,
    EdgeOp opType = EdgeOp.directed,
    required Map<String, List<String>> data,
  }) {
    final statements = <Statement>[];

    for (final node in data.keys) {
      statements.add(NodeStatement(NodeId(node)));
    }

    for (final mapping in data.entries) {
      final start = NodeId(mapping.key);
      for (final end in mapping.value) {
        statements.add(
          EdgeStatement(
            start,
            EdgeRhs(opType, NodeId(end)),
          ),
        );
      }
    }

    return Subgraph(id, StmtList(statements));
  }

  /// Convert a subgraph into a mapping of node to connected nodes.
  Map<String, List<String>> toData({bool inlineSubgraphs = true}) => statementsToData(
        stmtList.statements,
        inlineSubgraphs,
      );

  @override
  int get hashCode => Object.hash(id, stmtList);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          (other as Subgraph).id == id &&
          other.stmtList == stmtList);

  @override
  String toString() => '''subgraph${id != null ? ' $id' : ''} {
  ${stmtList.toString().replaceAll('\n', '\n  ')}
}''';
}
