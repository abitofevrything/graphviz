import 'package:collection/collection.dart';
import 'package:graphviz/src/language/a_list.dart';

/// A list of attributes.
///
/// The actual attributes are further split into more lists, represented by an [AList] instance. Use
/// [AttrList.fromAttributes] to skip creating an [AList].
class AttrList {
  /// The backing [AList]s that contain the attribute data.
  final List<AList> aLists;

  const AttrList(this.aLists);

  /// Create an attribute list from a mapping of attributes by name to value.
  factory AttrList.fromAttributes(Map<String, String> attributes) => AttrList([AList(attributes)]);

  @override
  int get hashCode => const UnorderedIterableEquality().hash(aLists);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          const UnorderedIterableEquality().equals((other as AttrList).aLists, aLists));

  @override
  String toString() => aLists.map((aList) => '[$aList]').join(' ');
}
