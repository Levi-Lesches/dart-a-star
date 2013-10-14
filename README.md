# A* path finding with Dart

A simple A* algorithm implemented in [Dart](http://dartlang.org).
An example of path finding.

Last updated 2013-10.

No effort has been made to optimize this. Ported from
[http://46dogs.blogspot.com/2009/10/star-pathroute-finding-javascript-code.html].

See LICENSE file for license details.

See running example at http://sethladd.github.io/dart-a-star/deploy/

# Example

    import 'package:a_star/a_star.dart';
    main() {
      String textMap = """
            sooooooo
            oxxxxxoo
            oxxoxooo
            oxoogxxx      
            """;
      Maze maze = new Maze.parse(textMap);
      Queue<Tile> solution = aStar(maze);
    }

# Reporting bugs

Please file bugs at https://github.com/sethladd/dart-a-star/issues

# Contributors

* https://github.com/PedersenThomas