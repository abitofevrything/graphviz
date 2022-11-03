import 'package:graphviz2/src/language/edge_op.dart';
import 'package:graphviz2/src/language/statement.dart';

/// A target for an edge.
///
/// Possible values are [NodeId] for targeting a node and [Subgraph] for targeting a subgraph.
abstract class EdgeTarget implements Statement {}

/// The right hand side of an edge statement.
class EdgeRhs {
  /// The [EdgeOp] to use for this edge.
  final EdgeOp op;

  /// The target (endpoint) of this edge.
  final EdgeTarget target;

  /// If another edge is chained onto this one, the next edge in the chain, otherwise `null`.
  final EdgeRhs? next;

  const EdgeRhs(this.op, this.target, [this.next]);

  @override
  int get hashCode => Object.hash(op, target, next);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          (other as EdgeRhs).op == op &&
          other.target == target &&
          other.next == next);

  @override
  String toString() => '$op $target${next != null ? ' $next' : ''}';
}
