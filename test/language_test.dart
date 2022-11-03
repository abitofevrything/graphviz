import 'package:graphviz/src/dot_grammar.dart';
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
import 'package:test/test.dart';

import 'utils/parser_matchers.dart';

void main() {
  group('language', () {
    final grammar = DotGrammar();

    group('id', () {
      test('alphanumeric', () {
        final parser = grammar.build(start: grammar.alphanumericId);

        expect(parser, isParseSuccess('abc', 'abc'));
        expect(parser, isParseSuccess('abc_def', 'abc_def'));
        expect(parser, isParseSuccess('_def', '_def'));
        expect(parser, isParseSuccess('a01234', 'a01234'));
      });

      test('numeral', () {
        final parser = grammar.build(start: grammar.numeral);

        expect(parser, isParseSuccess('1234', '1234'));
        expect(parser, isParseSuccess('-1234', '-1234'));
        expect(parser, isParseSuccess('.876', '.876'));
        expect(parser, isParseSuccess('-.876', '-.876'));
      });

      test('quoted string', () {
        final parser = grammar.build(start: grammar.quotedString);

        expect(parser, isParseSuccess('"foo"', '"foo"'));
        expect(parser, isParseSuccess('"foo & bar"', '"foo & bar"'));
        expect(parser, isParseSuccess('"foo \\" bar"', '"foo \\" bar"'));

        expect(parser, isParseSuccess('"foo \\  bar"', '"foo \\  bar"'));

        expect(
          parser,
          isParseSuccess(
            '"File: []\\l\\l total\\lDropped 2)\\l 110\\l\\l graph\\l"',
            '"File: []\\l\\l total\\lDropped 2)\\l 110\\l\\l graph\\l"',
          ),
        );
      });

      test('generic', () {
        final parser = grammar.build(start: grammar.id);

        expect(parser, isParseSuccess('abc', 'abc'));
        expect(parser, isParseSuccess('abc_def', 'abc_def'));
        expect(parser, isParseSuccess('_def', '_def'));
        expect(parser, isParseSuccess('a01234', 'a01234'));

        expect(parser, isParseSuccess('1234', '1234'));
        expect(parser, isParseSuccess('-1234', '-1234'));
        expect(parser, isParseSuccess('.876', '.876'));
        expect(parser, isParseSuccess('-.876', '-.876'));

        expect(parser, isParseSuccess('"foo"', '"foo"'));
        expect(parser, isParseSuccess('"foo & bar"', '"foo & bar"'));
        expect(parser, isParseSuccess('"foo \\" bar"', '"foo \\" bar"'));
      });
    });

    test('edge_op', () {
      final parser = grammar.build(start: grammar.edgeOp);

      expect(parser, isParseSuccess('->', EdgeOp.directed));
      expect(parser, isParseSuccess('--', EdgeOp.undirected));
    });

    test('compass_pt', () {
      final parser = grammar.build(start: grammar.compassPt);

      expect(parser, isParseSuccess('n', CompassPt.north));
      expect(parser, isParseSuccess('ne', CompassPt.northEast));
      expect(parser, isParseSuccess('e', CompassPt.east));
      expect(parser, isParseSuccess('se', CompassPt.southEast));
      expect(parser, isParseSuccess('s', CompassPt.south));
      expect(parser, isParseSuccess('sw', CompassPt.southWest));
      expect(parser, isParseSuccess('w', CompassPt.west));
      expect(parser, isParseSuccess('nw', CompassPt.northWest));
      expect(parser, isParseSuccess('c', CompassPt.center));
      expect(parser, isParseSuccess('_', CompassPt.appropriate));
    });

    test('port', () {
      final parser = grammar.build(start: grammar.port);

      expect(parser, isParseSuccess(':abc', IdPort('abc')));
      expect(parser, isParseSuccess(':abc:ne', IdPort('abc', CompassPt.northEast)));
      expect(parser, isParseSuccess(':ne', CompassPort(CompassPt.northEast)));
    });

    test('node_id', () {
      final parser = grammar.build(start: grammar.nodeId);

      expect(parser, isParseSuccess('abc', NodeId('abc')));
      expect(parser, isParseSuccess('abc:ne', NodeId('abc', CompassPort(CompassPt.northEast))));
      expect(parser, isParseSuccess('123:abc:n', NodeId('123', IdPort('abc', CompassPt.north))));
    });

    test('a_list', () {
      final parser = grammar.build(start: grammar.aList);

      expect(parser, isParseSuccess('a=b', AList({'a': 'b'})));
      expect(parser, isParseSuccess('a = b', AList({'a': 'b'})));
      expect(parser, isParseSuccess('a=b; c=d', AList({'a': 'b', 'c': 'd'})));
      expect(parser, isParseSuccess('a=b, c=d', AList({'a': 'b', 'c': 'd'})));
      expect(parser, isParseSuccess('a=b  c=d', AList({'a': 'b', 'c': 'd'})));

      expect(
        parser,
        isParseSuccess(
          'a=b; c=d; 1=2; -3 = 4',
          AList({
            'a': 'b',
            'c': 'd',
            '1': '2',
            '-3': '4',
          }),
        ),
      );
    });

    test('attr_list', () {
      final parser = grammar.build(start: grammar.attrList);

      expect(
        parser,
        isParseSuccess(
          '[a=b]',
          AttrList([
            AList({'a': 'b'})
          ]),
        ),
      );

      expect(
        parser,
        isParseSuccess(
          '[ a = b ]',
          AttrList([
            AList({'a': 'b'})
          ]),
        ),
      );

      expect(
        parser,
        isParseSuccess(
          '[ a = b; c = d] [e=f]',
          AttrList([
            AList({'a': 'b', 'c': 'd'}),
            AList({'e': 'f'}),
          ]),
        ),
      );
    });

    group('statement', () {
      test('node_stmt', () {
        final parser = grammar.build(start: grammar.nodeStmt);

        expect(parser, isParseSuccess('abc', NodeStatement(NodeId('abc'))));

        expect(
          parser,
          isParseSuccess(
            'abc [foo=bar]',
            NodeStatement(
              NodeId('abc'),
              AttrList([
                AList({'foo': 'bar'}),
              ]),
            ),
          ),
        );

        expect(
          parser,
          isParseSuccess(
            'abc:ne [foo=bar]',
            NodeStatement(
              NodeId('abc', CompassPort(CompassPt.northEast)),
              AttrList([
                AList({'foo': 'bar'}),
              ]),
            ),
          ),
        );

        expect(
          parser,
          isParseSuccess(
            'abc:ne [foo=bar; bar=baz] [bar=foo]',
            NodeStatement(
              NodeId('abc', CompassPort(CompassPt.northEast)),
              AttrList([
                AList({'foo': 'bar', 'bar': 'baz'}),
                AList({'bar': 'foo'}),
              ]),
            ),
          ),
        );
      });

      test('edge_rhs', () {
        final parser = grammar.build(start: grammar.edgeRhs);

        expect(parser, isParseSuccess('-> foo', EdgeRhs(EdgeOp.directed, NodeId('foo'))));

        expect(
          parser,
          isParseSuccess(
            '-> foo -> bar',
            EdgeRhs(
              EdgeOp.directed,
              NodeId('foo'),
              EdgeRhs(
                EdgeOp.directed,
                NodeId('bar'),
              ),
            ),
          ),
        );

        expect(
          parser,
          isParseSuccess(
            '-- foo:abc:ne -> bar',
            EdgeRhs(
              EdgeOp.undirected,
              NodeId(
                'foo',
                IdPort(
                  'abc',
                  CompassPt.northEast,
                ),
              ),
              EdgeRhs(
                EdgeOp.directed,
                NodeId('bar'),
              ),
            ),
          ),
        );
      });

      test('edge_stmt', () {
        final parser = grammar.build(start: grammar.edgeStmt);

        expect(
          parser,
          isParseSuccess(
            'a -> b',
            EdgeStatement(NodeId('a'), EdgeRhs(EdgeOp.directed, NodeId('b'))),
          ),
        );

        expect(
          parser,
          isParseSuccess(
            'a:foo -> b',
            EdgeStatement(NodeId('a', IdPort('foo')), EdgeRhs(EdgeOp.directed, NodeId('b'))),
          ),
        );
      });

      test('attr_stmt', () {
        final parser = grammar.build(start: grammar.attrStmt);

        expect(
          parser,
          isParseSuccess(
            'graph [foo=bar]',
            AttrStatement(
              AttrTarget.graph,
              AttrList([
                AList({'foo': 'bar'}),
              ]),
            ),
          ),
        );

        expect(
          parser,
          isParseSuccess(
            'node [foo=bar]',
            AttrStatement(
              AttrTarget.node,
              AttrList([
                AList({'foo': 'bar'}),
              ]),
            ),
          ),
        );

        expect(
          parser,
          isParseSuccess(
            'edge [foo=bar]',
            AttrStatement(
              AttrTarget.edge,
              AttrList([
                AList({'foo': 'bar'}),
              ]),
            ),
          ),
        );
      });

      test('subgraph', () {
        final parser = grammar.build(start: grammar.subgraph);

        expect(parser, isParseSuccess('{}', Subgraph(null, StmtList([]))));

        expect(
          parser,
          isParseSuccess(
            '{a -- b}',
            Subgraph(
              null,
              StmtList([
                EdgeStatement(
                  NodeId('a'),
                  EdgeRhs(
                    EdgeOp.undirected,
                    NodeId(
                      'b',
                    ),
                  ),
                ),
              ]),
            ),
          ),
        );

        expect(
          parser,
          isParseSuccess(
            '{a -- b;\nsubgraph foo { c -- d}\n  }',
            Subgraph(
              null,
              StmtList([
                EdgeStatement(
                  NodeId('a'),
                  EdgeRhs(
                    EdgeOp.undirected,
                    NodeId(
                      'b',
                    ),
                  ),
                ),
                Subgraph(
                  'foo',
                  StmtList([
                    EdgeStatement(NodeId('c'), EdgeRhs(EdgeOp.undirected, NodeId('d'))),
                  ]),
                ),
              ]),
            ),
          ),
        );

        expect(
          parser,
          isParseSuccess(
            '''subgraph cluster_L { "File: [stackcollapse]" [shape=box fontsize=16 label="File: [stackcollapse]\\l\\lShowing nodes accounting for 380, 90.48% of 420 total\\lDropped 120 nodes (cum <= 2)\\lShowing top 20 nodes out of 110\\l\\lSee https://git.io/JfYMW for how to read the graph\\l" tooltip="[stackcollapse]"] }''',
            Subgraph(
              'cluster_L',
              StmtList([
                NodeStatement(
                  NodeId('"File: [stackcollapse]"'),
                  AttrList([
                    AList({
                      'shape': 'box',
                      'fontsize': '16',
                      'label':
                          '"File: [stackcollapse]\\l\\lShowing nodes accounting for 380, 90.48% of 420 total\\lDropped 120 nodes (cum <= 2)\\lShowing top 20 nodes out of 110\\l\\lSee https://git.io/JfYMW for how to read the graph\\l"',
                      'tooltip': '"[stackcollapse]"',
                    }),
                  ]),
                )
              ]),
            ),
          ),
        );
      });

      test('generic', () {
        final parser = grammar.build(start: grammar.stmt);

        expect(parser, isParseSuccess('abc', NodeStatement(NodeId('abc'))));

        expect(
          parser,
          isParseSuccess(
            'abc [foo=bar]',
            NodeStatement(
              NodeId('abc'),
              AttrList([
                AList({'foo': 'bar'}),
              ]),
            ),
          ),
        );

        expect(
          parser,
          isParseSuccess(
            'abc:ne [foo=bar]',
            NodeStatement(
              NodeId('abc', CompassPort(CompassPt.northEast)),
              AttrList([
                AList({'foo': 'bar'}),
              ]),
            ),
          ),
        );

        expect(
          parser,
          isParseSuccess(
            'abc:ne [foo=bar; bar=baz] [bar=foo]',
            NodeStatement(
              NodeId('abc', CompassPort(CompassPt.northEast)),
              AttrList([
                AList({'foo': 'bar', 'bar': 'baz'}),
                AList({'bar': 'foo'}),
              ]),
            ),
          ),
        );

        expect(
          parser,
          isParseSuccess(
            'a -> b',
            EdgeStatement(NodeId('a'), EdgeRhs(EdgeOp.directed, NodeId('b'))),
          ),
        );

        expect(
          parser,
          isParseSuccess(
            'a:foo -> b',
            EdgeStatement(NodeId('a', IdPort('foo')), EdgeRhs(EdgeOp.directed, NodeId('b'))),
          ),
        );

        expect(
          parser,
          isParseSuccess(
            'graph [foo=bar]',
            AttrStatement(
              AttrTarget.graph,
              AttrList([
                AList({'foo': 'bar'}),
              ]),
            ),
          ),
        );

        expect(
          parser,
          isParseSuccess(
            'node [foo=bar]',
            AttrStatement(
              AttrTarget.node,
              AttrList([
                AList({'foo': 'bar'}),
              ]),
            ),
          ),
        );

        expect(
          parser,
          isParseSuccess(
            'edge [foo=bar]',
            AttrStatement(
              AttrTarget.edge,
              AttrList([
                AList({'foo': 'bar'}),
              ]),
            ),
          ),
        );
      });
    });

    test('stmt-list', () {
      final parser = grammar.build(start: grammar.stmtList);

      expect(
        parser,
        isParseSuccess(
          '"//absl/random:random"\n  "//absl/random:random" -> "//absl/random:distributions"\n  "//absl/random:random" -> "//absl/random:seed_sequences"',
          StmtList([
            NodeStatement(NodeId('"//absl/random:random"')),
            EdgeStatement(
              NodeId('"//absl/random:random"'),
              EdgeRhs(
                EdgeOp.directed,
                NodeId('"//absl/random:distributions"'),
              ),
            ),
            EdgeStatement(
              NodeId('"//absl/random:random"'),
              EdgeRhs(
                EdgeOp.directed,
                NodeId('"//absl/random:seed_sequences"'),
              ),
            ),
          ]),
        ),
      );

      expect(
        parser,
        isParseSuccess(
          'fontname="Helvetica,Arial,sans-serif"\n  node [fontname="Helvetica,Arial,sans-serif"]\n  edge [fontname="Helvetica,Arial,sans-serif"]',
          StmtList([
            AssignStatement('fontname', '"Helvetica,Arial,sans-serif"'),
            AttrStatement(
              AttrTarget.node,
              AttrList([
                AList({'fontname': '"Helvetica,Arial,sans-serif"'})
              ]),
            ),
            AttrStatement(
              AttrTarget.edge,
              AttrList([
                AList({'fontname': '"Helvetica,Arial,sans-serif"'})
              ]),
            ),
          ]),
        ),
      );
    });

    test('group', () {
      final parser = grammar.build(start: grammar.graph);

      expect(
        parser,
        isParseSuccess(
          'graph foo {}',
          Graph(
            id: 'foo',
            stmtList: StmtList([]),
            strict: false,
            type: GraphType.graph,
          ),
        ),
      );

      expect(
        parser,
        isParseSuccess(
          'strict digraph { a -- b}',
          Graph(
            id: null,
            stmtList: StmtList([
              EdgeStatement(NodeId('a'), EdgeRhs(EdgeOp.undirected, NodeId('b'))),
            ]),
            strict: true,
            type: GraphType.digraph,
          ),
        ),
      );
    });
  });
}
