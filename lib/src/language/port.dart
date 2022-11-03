import 'package:graphviz/src/language/compass_pt.dart';

/// A port on a node.
///
/// Possible values are [IdPort] for ports with IDs and [CompassPort] for ports with only a compass
/// point.
abstract class Port {
  /// The target compass point, if any was specified.
  CompassPt? get compassPt;
}

/// A port with an ID and an optional compass point.
class IdPort implements Port {
  /// The id of this port.
  final String id;

  @override
  final CompassPt? compassPt;

  const IdPort(this.id, [this.compassPt]);

  @override
  int get hashCode => Object.hash(id, compassPt);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          (other as IdPort).id == id &&
          other.compassPt == compassPt);

  @override
  String toString() => ':$id${compassPt != null ? ':$compassPt' : ''}';
}

/// A port with no ID and only a compass point.
class CompassPort implements Port {
  @override
  final CompassPt compassPt;

  const CompassPort(this.compassPt);

  @override
  int get hashCode => compassPt.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && (other as CompassPort).compassPt == compassPt);

  @override
  String toString() => ':$compassPt';
}
