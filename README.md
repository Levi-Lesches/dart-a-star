# A* path finding with Dart

A simple A* algorithm implemented in [Dart](http://dartlang.org).
An example of path finding.

Last updated 2021-03.

The original 2D algorithm was ported from
[this JavaScript example](http://46dogs.blogspot.com/2009/10/star-pathroute-finding-javascript-code.html). 
No effort has been made to optimize it. A more generic A* algorithm was added
in November 2013. That one is fairly optimized.

See LICENSE file for license details.

See running example at http://sethladd.github.io/dart-a-star/deploy/

# Example

There are two separate A* algorithms in this package. One of them, `aStar2D`, is
specific to **2D grid maps.** The usage can be as simple as:

    import 'package:a_star/a_star_2d.dart';
    main() {
      String textMap = """
            sooooooo
            oxxxxxoo
            oxxoxooo
            oxoogxxx      
            """;
      Maze maze = new Maze.parse(textMap);
      Queue<Tile> solution = aStar2D(maze);
    }

The second algorithm is **generic** and works on any graph (e.g. 3D grids, mesh
networks). The usage is best explained with an example (details below):

    import 'package:a_star/a_star.dart';
    
    class TerrainTile extends Object with Node {
      // ...
    }
    class TerrainMap implements Graph<TerrainTile> {
      // Must implement 4 methods.
      Iterable<T> get allNodes => /* ... */
      num getDistance(T a, T b) => /* ... */
      num getHeuristicDistance(T a, T b) => /* ... */
      Iterable<T> getNeighboursOf(T node) => /* ... */
    }
    
    main() {
      var map = new TerrainMap();
      var pathFinder = new AStar(map);
      var start = /* ... */
      var goal = /* ... */
      pathFinder.findPath(start, goal)
      .then((path) => print("The best path from $start to $goal is: $path"));
    }

**Explanation:** Here, we have a `TerrainMap` of `TerrainTile` nodes. The only
requirements are that `TerrainMap` implements `Graph` (4 methods) and
`TerrainTile` is extended with the `Node` mixin (no additional work). Then, we
can simply instantiate the A* algorithm by `new AStar(map)` and find paths 
between two nodes by calling the `findPath(start, goal)` method. Normally,
we would only create the `AStar` instance once and then reuse it throughout our
program. This saves performance.

You can also use `findPathSync(start, goal)` if you don't need to worry about
blocking.

All the three classes (`AStar`, `Graph` and `Node`) are well documented in
`lib/a_star.dart`. For a complete example, see the minimal unit tests or one of
the two generalized benchmarks (`benchmark.dart` or `benchmark_generalized_2d`).

# Reporting bugs

Please file bugs at https://github.com/sethladd/dart-a-star/issues

# Contributors

* https://github.com/PedersenThomas
* https://github.com/filiph
