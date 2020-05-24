/*
 Copyright 2012 Seth Ladd

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

library a_star_2d;

import 'dart:collection';
import 'dart:math' as math;

class Maze {
  List<List<Tile>> tiles;
  Tile start;
  Tile goal;

  Maze(this.tiles, this.start, this.goal);

  factory Maze.random({int width, int height}) {
    if (width == null) {
      throw ArgumentError('width must not be null');
    }
    if (height == null) {
      throw ArgumentError('height must not be null');
    }

    final rand = math.Random();
    final tiles = <List<Tile>>[];

    for (var y = 0; y < height; y++) {
      final row = <Tile>[];
      for (var x = 0; x < width; x++) {
        row.add(Tile(x, y, obstacle: rand.nextBool()));
      }
      tiles.add(row);
    }

    return Maze(tiles, tiles[0][0], tiles[height - 1][width - 1]);
  }

  factory Maze.parse(String map) {
    final tiles = <List<Tile>>[];
    final rows = map.trim().split('\n');
    Tile start;
    Tile goal;

    for (var rowNum = 0; rowNum < rows.length; rowNum++) {
      final row = <Tile>[];
      final lineTiles = rows[rowNum].trim().split('');

      for (var colNum = 0; colNum < lineTiles.length; colNum++) {
        final t = lineTiles[colNum];
        final obstacle = t == 'x';
        final tile = Tile(colNum, rowNum, obstacle: obstacle);
        if (t == 's') {
          start = tile;
        }
        if (t == 'g') {
          goal = tile;
        }
        row.add(tile);
      }

      tiles.add(row);
    }

    return Maze(tiles, start, goal);
  }
}

class Tile {
  final int x, y;
  final bool obstacle;
  final int _hashcode;
  final String _str;

  // for A*
  double _f = -1.0; // heuristic + cost
  double _g = -1.0; // cost
  double _h = -1.0; // heuristic estimate
  int _parentIndex = -1;

  Tile(this.x, this.y, {this.obstacle = false})
      : _hashcode = '$x,$y'.hashCode,
        _str = '[X:$x, Y:$y, Obs:$obstacle]';

  @override
  String toString() => _str;

  @override
  int get hashCode => _hashcode;

  @override
  bool operator ==(dynamic tile) => tile is Tile && x == tile.x && y == tile.y;
}

double hueristic(Tile tile, Tile goal) {
  final x = tile.x - goal.x;
  final y = tile.y - goal.y;
  return math.sqrt(x * x + y * y);
}

// thanks to http://46dogs.blogspot.com/2009/10/star-pathroute-finding-javascript-code.html
// for the original algorithm

/// This algorithm works only for 2D grids. There is a lot of room to optimize
/// this further.
Queue<Tile> aStar2D(Maze maze) {
  final map = maze.tiles;
  final start = maze.start;
  final goal = maze.goal;
  final numRows = map.length;
  final numColumns = map[0].length;

  final open = <Tile>[];
  final closed = <Tile>[];

  open.add(start);

  while (open.length > 0) {
    var bestCost = open[0]._f;
    var bestTileIndex = 0;

    for (var i = 1; i < open.length; i++) {
      if (open[i]._f < bestCost) {
        bestCost = open[i]._f;
        bestTileIndex = i;
      }
    }

    var currentTile = open[bestTileIndex];

    if (currentTile == goal) {
      // queues are more performant when adding to the front
      final path = Queue<Tile>.from([goal]);

      // Go up the chain to recreate the path
      while (currentTile._parentIndex != -1) {
        currentTile = closed[currentTile._parentIndex];
        path.addFirst(currentTile);
      }

      return path;
    }

    open.removeAt(bestTileIndex);

    closed.add(currentTile);

    for (var newX = math.max(0, currentTile.x - 1);
        newX <= math.min(numColumns - 1, currentTile.x + 1);
        newX++) {
      for (var newY = math.max(0, currentTile.y - 1);
          newY <= math.min(numRows - 1, currentTile.y + 1);
          newY++) {
        if (!map[newY][newX].obstacle // If the new node is open
            ||
            (goal.x == newX && goal.y == newY)) {
          // or the new node is our destination
          //See if the node is already in our closed list. If so, skip it.
          var foundInClosed = false;
          for (var i = 0; i < closed.length; i++) {
            if (closed[i].x == newX && closed[i].y == newY) {
              foundInClosed = true;
              break;
            }
          }

          if (foundInClosed) {
            continue;
          }

          //See if the node is in our open list. If not, use it.
          var foundInOpen = false;
          for (var i = 0; i < open.length; i++) {
            if (open[i].x == newX && open[i].y == newY) {
              foundInOpen = true;
              break;
            }
          }

          if (!foundInOpen) {
            final tile = map[newY][newX].._parentIndex = closed.length - 1;

            tile
              .._g = currentTile._g +
                  math.sqrt(math.pow(tile.x - currentTile.x, 2) +
                      math.pow(tile.y - currentTile.y, 2))
              .._h = hueristic(tile, goal)
              .._f = tile._g + tile._h;

            open.add(tile);
          }
        }
      }
    }
  }

  return Queue<Tile>();
}
