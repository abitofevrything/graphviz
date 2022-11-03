import 'package:collection/collection.dart';
import 'package:graphviz2/src/language/statement.dart';

/// A list of statements.
///
/// Serves only as a wrapper for parsing.
class StmtList {
  /// The statements contained in this list.
  final List<Statement> statements;

  const StmtList(this.statements);

  @override
  int get hashCode => const UnorderedIterableEquality().hash(statements);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          const UnorderedIterableEquality().equals((other as StmtList).statements, statements));

  @override
  String toString() => statements.join(';\n');
}
