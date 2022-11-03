import 'package:graphviz/src/language/a_list.dart';
import 'package:graphviz/src/language/attr_list.dart';
import 'package:graphviz/src/language/edge_op.dart';
import 'package:graphviz/src/language/edge_rhs.dart';
import 'package:graphviz/src/language/node_id.dart';

/// A statement in a graph.
///
/// Possible values include [NodeStatement], [EdgeStatement], [AttrStatement], [AssignStatement] or
/// [Subgraph].
abstract class Statement {}

/// A node statement.
class NodeStatement implements Statement {
  /// The id of the node.
  final NodeId id;

  /// A list of attributes to apply to the node, if any.
  final AttrList? attrList;

  const NodeStatement(this.id, [this.attrList]);

  /// Create a node statement from an id and an optional mapping of attributes by name to value.
  factory NodeStatement.create(
    String id, {
    Map<String, String>? attributes,
  }) {
    AttrList? attrList;
    if (attributes != null) {
      attrList = AttrList([
        AList(attributes),
      ]);
    }

    return NodeStatement(NodeId(id), attrList);
  }

  @override
  int get hashCode => Object.hash(id, attrList);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          (other as NodeStatement).id == id &&
          other.attrList == attrList);

  @override
  String toString() => '$id${attrList != null ? ' $attrList' : ''}';
}

/// And edge statement, joining two nodes.
class EdgeStatement implements Statement {
  /// The start of the edge.
  final EdgeTarget origin;

  /// The right hand side of this statement.
  ///
  /// Contains data about the target node(s), edge type and possible edge chains.
  final EdgeRhs rhs;

  /// A list of attributes to apply to this edge.
  final AttrList? attrList;

  const EdgeStatement(this.origin, this.rhs, [this.attrList]);

  /// Create an edge statement joining [from] and [to], with an optional mapping of [attributes] by
  /// name to value.
  ///
  /// You may need to specify [opType] if you are in an undirected graph.
  factory EdgeStatement.create({
    required String from,
    required String to,
    EdgeOp opType = EdgeOp.directed,
    Map<String, String>? attributes,
  }) {
    AttrList? attrList;
    if (attributes != null) {
      attrList = AttrList([AList(attributes)]);
    }

    return EdgeStatement(
      NodeId(from),
      EdgeRhs(
        opType,
        NodeId(to),
      ),
      attrList,
    );
  }

  @override
  int get hashCode => Object.hash(origin, rhs, attrList);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          (other as EdgeStatement).origin == origin &&
          other.rhs == rhs &&
          other.attrList == attrList);

  @override
  String toString() => '$origin $rhs${attrList != null ? ' $attrList' : ''}';
}

/// A target for an attribute.
enum AttrTarget {
  graph('graph'),
  node('node'),
  edge('edge');

  /// The encoded value of this target.
  final String value;

  const AttrTarget(this.value);

  /// Create an [AttrTarget] from its value.
  factory AttrTarget.fromValue(String value) =>
      values.firstWhere((target) => target.value == value.toLowerCase());

  @override
  String toString() => value;
}

/// An attribute statement.
class AttrStatement implements Statement {
  /// The target of this statement.
  final AttrTarget target;

  /// The list of attributes to apply.
  final AttrList attrList;

  const AttrStatement(this.target, this.attrList);

  /// Create an attribute statement with a given [type] and a mapping of [attributes] by name to
  /// value.
  factory AttrStatement.withType(AttrTarget type, Map<String, String> attributes) => AttrStatement(
        type,
        AttrList([AList(attributes)]),
      );

  @override
  int get hashCode => Object.hash(target, attrList);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          (other as AttrStatement).target == target &&
          other.attrList == attrList);

  @override
  String toString() => '$target $attrList';
}

/// An assignment statement.
class AssignStatement implements Statement {
  /// The left hand side of the assignment.
  final String lhs;

  /// The right hand side of the assignment.
  final String rhs;

  const AssignStatement(this.lhs, this.rhs);

  @override
  int get hashCode => Object.hash(lhs, rhs);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          (other as AssignStatement).lhs == lhs &&
          other.rhs == rhs);

  @override
  String toString() => '$lhs = $rhs';
}
