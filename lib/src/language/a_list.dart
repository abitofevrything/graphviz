import 'package:collection/collection.dart';

/// A list of attributes.
class AList {
  /// The attributes mapped by name to value.
  final Map<String, String> properties;

  const AList(this.properties);

  @override
  int get hashCode => const MapEquality().hash(properties);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          const MapEquality().equals((other as AList).properties, properties));

  @override
  String toString() => properties.entries.map((e) => '${e.key}=${e.value}').join('; ');
}
