import 'package:graphviz/src/language/a_list.dart';
import 'package:graphviz/src/language/attr_list.dart';
import 'package:graphviz/src/language/compass_pt.dart';
import 'package:graphviz/src/language/edge_op.dart';
import 'package:graphviz/src/language/edge_rhs.dart';
import 'package:graphviz/src/language/graph.dart';
import 'package:graphviz/src/language/node_id.dart';
import 'package:graphviz/src/language/port.dart';
import 'package:graphviz/src/language/statement.dart';
import 'package:graphviz/src/language/stmt_list.dart';
import 'package:graphviz/src/language/subgraph.dart';
import 'package:petitparser/petitparser.dart';

/// The grammar definition of the Graphviz Dot Language.
///
/// You probably don't want to use this yourself, see [DotParser.parseGraph] instead.
///
/// You can find the spec here: https://graphviz.org/doc/info/lang.html.
/// Notable deviations from the spec in this library include:
/// - Inability to read files with HTML strings.
/// - No restrictions on edge_ops (`--` or `->`) depending on the type of the current graph.
///
/// To learn how to use this grammar definition, check out the documentation for [GrammarDefinition]
/// and the [petitparser package](https://pub.dev/packages/petitparser).
class DotGrammar extends GrammarDefinition<Graph> {
  @override
  Parser<Graph> start() => graph().end();

  // Tokens

  /// The `node` keyword.
  Parser<Token<String>> nodeToken() => token('node');

  /// The `edge` keyword.
  Parser<Token<String>> edgeToken() => token('edge');

  /// The `graph` keyword.
  Parser<Token<String>> graphToken() => token('graph');

  /// The `digraph` keyword.
  Parser<Token<String>> digraphToken() => token('digraph');

  /// The `subgraph` keyword.
  Parser<Token<String>> subgraphToken() => token('subgraph');

  /// The `strict` keyword.
  Parser<Token<String>> strictToken() => token('strict');

  // Grammar

  /// A complete `graph`.
  Parser<Graph> graph() => (ref0(strictToken).optional() &
          (ref0(graphToken) | ref0(digraphToken)) &
          ref0(id).optional() &
          ref1(token, '{') &
          ref0(stmtList) &
          ref1(token, '}'))
      .map((result) => Graph(
            strict: result[0] != null,
            type: GraphType.fromValue((result[1] as Token<String>).value),
            id: result[2],
            stmtList: result[4],
          ));

  /// A complete `stmt_list`.
  Parser<StmtList> stmtList() => (ref0(stmt) &
              (ref1(token, ';') | ref0(whitespaceOrComments)).optional() &
              ref0(stmtList).optional())
          .optional()
          .map((result) {
        if (result == null) {
          return const StmtList([]);
        }

        final stmtList = <Statement>[result[0]];

        // Will just be empty if nothing was parsed - see the if-null block above.
        StmtList? more = result[2];
        if (more != null) {
          stmtList.addAll(more.statements);
        }

        return StmtList(stmtList);
      });

  /// A complete `stmt`.
  Parser<Statement> stmt() => [
        // First try to match edge/attr/subgraph statements which might otherwise be caught as node
        // statements
        ref0(edgeStmt),
        ref0(attrStmt),
        ref0(subgraph),
        (ref0(id) & ref1(token, '=') & ref0(id))
            .map((result) => AssignStatement(result[0], result[2])),
        ref0(nodeStmt),
      ].toChoiceParser();

  /// A complete `attr_stmt`.
  Parser<AttrStatement> attrStmt() =>
      ([ref0(graphToken) | ref0(nodeToken) | ref0(edgeToken)].toChoiceParser() & ref0(attrList))
          .map((result) =>
              AttrStatement(AttrTarget.fromValue((result[0] as Token<String>).value), result[1]));

  /// A complete `attr_list`.
  Parser<AttrList> attrList() =>
      (ref1(token, '[') & ref0(aList).optional() & ref1(token, ']') & ref0(attrList).optional())
          .map((result) {
        final aLists = <AList>[result[1]];

        AttrList? more = result.last;
        if (more != null) {
          aLists.addAll(more.aLists);
        }

        return AttrList(aLists);
      });

  /// A complete `a_list`.
  Parser<AList> aList() => (ref0(id) &
              ref1(token, '=') &
              ref0(id) &
              (ref1(token, ';') | ref1(token, ',') | ref0(whitespaceOrComments)).optional() &
              ref0(aList).optional())
          .map((List result) {
        final properties = <String, String>{result[0]: result[2]};

        AList? more = result.last;
        if (more != null) {
          properties.addAll(more.properties);
        }

        return AList(properties);
      });

  /// A complete `edge_stmt`.
  Parser<EdgeStatement> edgeStmt() => ([
            ref0(nodeId),
            ref0(subgraph),
          ].toChoiceParser() &
          ref0(edgeRhs) &
          ref0(attrList).optional())
      .map((result) => EdgeStatement(result[0], result[1], result[2]));

  /// A complete `edgeRHS`.
  Parser<EdgeRhs> edgeRhs() => (ref0(edgeOp) &
          [
            ref0(nodeId),
            ref0(subgraph),
          ].toChoiceParser() &
          ref0(edgeRhs).optional())
      .map((results) => EdgeRhs(results[0], results[1], results[2]));

  /// A complete `node_stmt`.
  Parser<NodeStatement> nodeStmt() => (ref0(nodeId) & ref0(attrList).optional())
      .map((results) => NodeStatement(results[0], results[1]));

  /// A complete `node_id`.
  Parser<NodeId> nodeId() =>
      (ref0(id) & ref0(port).optional()).map((result) => NodeId(result[0], result[1]));

  /// A complete `port`.
  Parser<Port> port() => [
        // First try to match a compass port to avoid parsing a compass point as an id
        (ref1(token, ':') & ref0(compassPt)).map((result) => CompassPort(result[1])),
        (ref1(token, ':') & ref0(id) & (ref1(token, ':') & ref0(compassPt)).optional())
            .map((result) => IdPort(result[1], result[2]?[1])),
      ].toChoiceParser();

  /// A complete `subgraph`.
  Parser<Subgraph> subgraph() => ((ref0(subgraphToken) & ref0(id).optional()).optional() &
          ref1(token, '{') &
          ref0(stmtList) &
          ref1(token, '}'))
      .map((result) => Subgraph(result[0]?[1], result[2]));

  /// A complete `compass_pt`.
  Parser<CompassPt> compassPt() => [
        // First try to match longer points, to avoid matching just the `n` in `ne` for example.
        ref1(token, 'ne'),
        ref1(token, 'se'),
        ref1(token, 'sw'),
        ref1(token, 'nw'),
        ref1(token, 'n'),
        ref1(token, 'e'),
        ref1(token, 's'),
        ref1(token, 'w'),
        ref1(token, 'c'),
        ref1(token, '_'),
      ].toChoiceParser().map((token) => CompassPt.fromValue(token.value));

  /// A complete `edgeop`.
  // TODO: Do we care about the type of graph?
  Parser<EdgeOp> edgeOp() => [
        ref1(token, '->'),
        ref1(token, '--'),
      ].toChoiceParser().map((token) => EdgeOp.fromValue(token.value));

  /// A valid `ID`.
  // TODO: HTML Strings
  Parser<String> id() => [ref0(alphanumericId), ref0(numeral), ref0(quotedString)].toChoiceParser();

  // Utilities

  Parser<String> alphanumericId() => (digit().not() & pattern('a-zA-Z0-9_').plus()).flatten();

  Parser<String> numeral() => (char('-').optional() &
          ((char('.') & digit().plus()) |
              (digit().plus() & (char('.') & digit().star()).optional())))
      .flatten();

  Parser<String> quotedString() =>
      (char('"') & (pattern('^\\"\n\r') | (char('\\') & any())).star() & char('"')).flatten();

  Parser<void> whitespaceOrComments() => whitespaceOrComment().plus();
  Parser<void> whitespaceOrComment() => whitespace() | singleLineComment() | multiLineComment();

  Parser<void> newline() => pattern('\n\r');

  Parser<void> singleLineComment() =>
      string('//') & ref0(newline).neg().star() & ref0(newline).optional();
  Parser<void> multiLineComment() =>
      string('/*') & (ref0(multiLineComment) | string('*/').neg()).star() & string('*/');

  Parser<Token<String>> token(Object input) {
    if (input is Parser) {
      return input.cast<String>().token().trim(ref0(whitespaceOrComments));
    } else if (input is String) {
      return token(stringIgnoreCase(input));
    }
    throw ArgumentError.value(input, 'Invalid token parser');
  }
}
