/// An edge operation, indicating the type of edge to use to join two nodes.
///
/// The type of [EdgeOp] you should use depends on the type of graph you are working in:
/// > An edgeop is `->` in directed graphs and `--` in undirected graphs.
enum EdgeOp {
  directed('->'),
  undirected('--');

  /// The encoded representation of this edge operation.
  final String value;

  const EdgeOp(this.value);

  /// Create an [EdgeOp] from its encoded value.
  factory EdgeOp.fromValue(String value) => values.singleWhere((op) => op.value == value);

  @override
  String toString() => value;
}
