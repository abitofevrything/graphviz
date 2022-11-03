import 'package:graphviz2/src/language/edge_op.dart';
import 'package:graphviz2/src/language/edge_rhs.dart';
import 'package:graphviz2/src/language/node_id.dart';
import 'package:graphviz2/src/language/statement.dart';
import 'package:graphviz2/src/language/subgraph.dart';

List<Statement> dataToStatements(Map<String, List<String>> data, EdgeOp opType) {
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
          EdgeRhs(
            opType,
            NodeId(end),
          ),
        ),
      );
    }
  }

  return statements;
}

Map<String, List<String>> statementsToData(List<Statement> statements, bool inlineSubgraphs) {
  final result = <String, List<String>>{};

  for (final statement in statements) {
    if (statement is NodeStatement) {
      result[statement.id.toString()] ??= [];
    } else if (statement is EdgeStatement) {
      final starts = getAllNodes(statement.origin);
      final ends = getAllNodes(statement).skip(starts.length);

      for (final start in starts) {
        result[start.toString()] ??= [];
        result[start.toString()]!.addAll(ends.map((id) => id.toString()));
      }
    } else if (statement is Subgraph && inlineSubgraphs) {
      result.addAll(statementsToData(statement.stmtList.statements, inlineSubgraphs));
    }
  }

  return result;
}

List<NodeId> getAllNodes(Statement statement) {
  if (statement is NodeStatement) {
    return [statement.id];
  } else if (statement is EdgeStatement) {
    final result = getAllNodes(statement.origin);
    EdgeRhs? rhs = statement.rhs;
    while (rhs != null) {
      result.addAll(getAllNodes(rhs.target));

      rhs = rhs.next;
    }
  } else if (statement is Subgraph) {
    return [
      for (final st in statement.stmtList.statements) ...getAllNodes(st),
    ];
  }

  return [];
}
