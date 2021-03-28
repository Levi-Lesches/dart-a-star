import 'package:test/test.dart';
import 'package:a_star/a_star.dart';

class SimpleNode extends Object with Node<SimpleNode> {
  num nodeInherentCost;

  SimpleNode(this.nodeInherentCost);

  Iterable<SimpleNode> connectedNodes = [];

  num getCostFrom(SimpleNode other) =>
      nodeInherentCost; // This is how it works in many games - the node itself
// has a cost. For example, a forrest has 2x the cost
// of a plain.
}

class SimpleNodeNetwork extends Graph<SimpleNode> {
  @override
  late Iterable<SimpleNode> allNodes;

  late SimpleNode start, a, b, c, d, goal;

  SimpleNodeNetwork() {
    // The testing network is set up as follows:
    //      start
    //       / \
    //      a - b
    //      | X |
    //      c - d
    //       \ /
    //       goal
    // Nodes [a] and [d] are twice as costly to go through than nodes [b]
    // and [c].
    start = SimpleNode(1);
    a = SimpleNode(2);
    b = SimpleNode(1);
    c = SimpleNode(1);
    d = SimpleNode(2);
    goal = SimpleNode(3);

    start.connectedNodes = [a, b];
    a.connectedNodes = [start, b, c, d];
    b.connectedNodes = [start, a, c, d];
    c.connectedNodes = [a, b, d, goal];
    d.connectedNodes = [a, b, c, goal];
    goal.connectedNodes = [c, d];

    allNodes = [start, a, b, c, d, goal];
  }

  @override
  num getDistance(SimpleNode a, SimpleNode b) => b.nodeInherentCost;

  @override
  num getHeuristicDistance(SimpleNode node, SimpleNode goalNode) {
    assert(goalNode == goal);
    if (node == start) {
      return 3;
    }
    if (node == a || node == b) {
      return 2;
    }
    if (node == c || node == d) {
      return 1;
    }
    return 0;
  }

  @override
  Iterable<SimpleNode> getNeighboursOf(SimpleNode node) => node.connectedNodes;
}

void main() {
  group('A* star generic', () {
    late SimpleNodeNetwork network;
    late AStar<SimpleNode> aStar;

    setUp(() {
      network = SimpleNodeNetwork();
      aStar = AStar<SimpleNode>(network);
    });

    test('finds fastest way', () {
      final path = aStar.findPathSync(network.start, network.goal);
      expect(path,
          orderedEquals([network.start, network.b, network.c, network.goal]));
    });

    test("doesn't find if blocked by impassable", () {
      network.c.nodeInherentCost = double.infinity;
      network.d.nodeInherentCost = double.infinity;
      final path = aStar.findPathSync(network.start, network.goal);
      expect(path, isEmpty);
    });

    test('works for successive path finding on the same AStar instance', () {
      final path = aStar.findPathSync(network.start, network.goal);
      expect(path,
          orderedEquals([network.start, network.b, network.c, network.goal]));
      final path2 = aStar.findPathSync(network.a, network.goal);
      expect(path2, orderedEquals([network.a, network.c, network.goal]));
    });

    test('works asynchronously', () {
      aStar.findPath(network.start, network.goal).then(expectAsync1((path) {
        expect(path,
            orderedEquals([network.start, network.b, network.c, network.goal]));
      }));
    });
  });
}
