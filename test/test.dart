import 'package:test/test.dart';
import 'package:a_star/a_star.dart';


class SimpleNode extends Object with Node {
  num nodeInherentCost;

  SimpleNode(this.nodeInherentCost);
  
  Iterable<SimpleNode> connectedNodes;
  
  num getCostFrom(SimpleNode other) =>
      nodeInherentCost;  // This is how it works in many games - the node itself
                         // has a cost. For example, a forrest has 2x the cost
                         // of a plain.
}

class SimpleNodeNetwork extends Graph<SimpleNode> {
  
  Iterable<SimpleNode> allNodes; // TODO implement this getter
  
  SimpleNode start, a, b, c, d, goal;
  
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
    start = new SimpleNode(1);
    a = new SimpleNode(2);
    b = new SimpleNode(1);
    c = new SimpleNode(1);
    d = new SimpleNode(2);
    goal = new SimpleNode(3);

    
    start.connectedNodes = [a,b];
    a.connectedNodes = [start, b, c, d];
    b.connectedNodes = [start, a, c, d];
    c.connectedNodes = [a, b, d, goal];
    d.connectedNodes = [a, b, c, goal];
    goal.connectedNodes = [c, d];
    
    allNodes = [start, a, b, c, d, goal];
  }

  num getDistance(SimpleNode a, SimpleNode b) {
    return b.nodeInherentCost;
  }

  num getHeuristicDistance(SimpleNode node, SimpleNode goalNode) {
    assert(goalNode == goal);
    if (node == start) return 3;
    if (node == a || node == b) return 2;
    if (node == c || node == d) return 1;
    return 0;
  }

  Iterable<SimpleNode> getNeighboursOf(SimpleNode node) {
    return node.connectedNodes;
  }
}


main() {
  group("A* star generic", () {
    SimpleNodeNetwork network;
    AStar<SimpleNode> aStar;
    
    setUp(() {
      network = new SimpleNodeNetwork();
      aStar = new AStar<SimpleNode>(network);
    });
    
    test("finds fastest way", () {
      var path = aStar.findPathSync(network.start, network.goal);
      expect(path, orderedEquals(
          [network.start, network.b, network.c, network.goal]));
    });
    
    test("doesn't find if blocked by impassable", () {
      network.c.nodeInherentCost = null;
      network.d.nodeInherentCost = null;
      var path = aStar.findPathSync(network.start, network.goal);
      expect(path, isEmpty);
    });
    
    test("works for successive path finding on the same AStar instance", () {
      var path = aStar.findPathSync(network.start, network.goal);
      expect(path, orderedEquals(
          [network.start, network.b, network.c, network.goal]));
      var path2 = aStar.findPathSync(network.a, network.goal);
      expect(path2, orderedEquals(
          [network.a, network.c, network.goal]));
    });
    
    test("works asynchronously", () {
      var pathFuture = aStar.findPath(network.start, network.goal);
      pathFuture.then(expectAsync1((path) {
        expect(path, orderedEquals(
            [network.start, network.b, network.c, network.goal]));
      }));
    });
  });
}