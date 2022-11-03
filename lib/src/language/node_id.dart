import 'package:graphviz2/src/language/edge_rhs.dart';
import 'package:graphviz2/src/language/port.dart';

/// A node ID.
class NodeId implements EdgeTarget {
  /// The ID of the node.
  final String id;

  /// The port to attach to on th node.
  final Port? port;

  const NodeId(this.id, [this.port]);

  @override
  int get hashCode => Object.hash(id, port);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && (other as NodeId).id == id && other.port == port);

  @override
  String toString() => '$id${port ?? ''}';
}
