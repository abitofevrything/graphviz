/// A compass point, used to indicate where to aim on a node.
///
/// See https://graphviz.org/docs/attr-types/portPos/.
enum CompassPt {
  north('n'),
  northEast('ne'),
  east('e'),
  southEast('se'),
  south('s'),
  southWest('sw'),
  west('w'),
  northWest('nw'),
  center('c'),
  appropriate('_');

  /// The encoded representation of this compass point.
  final String value;

  const CompassPt(this.value);

  /// Create a [CompassPt] from its encoded representation.
  factory CompassPt.fromValue(String value) => values.singleWhere((pt) => pt.value == value);

  @override
  String toString() => value;
}
