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

import 'dart:math' as Math;
import 'dart:collection';

class Maze {
  List<List<Tile>> tiles;
  Tile start;
  Tile goal;
  Maze(this.tiles, this.start, this.goal);
  
  factory Maze.random({int width, int height}) {
    if (width == null) throw new ArgumentError('width must not be null');
    if (height == null) throw new ArgumentError('height must not be null');
    
    Math.Random rand = new Math.Random();
    List<List<Tile>> tiles = new List<List<Tile>>();
    
    for (int y = 0; y < height; y++) {
      List<Tile> row = new List<Tile>();
      for (int x = 0; x < width; x++) {
        row.add(new Tile(x, y, rand.nextBool()));
      }
      tiles.add(row);
    }
    
    return new Maze(tiles, tiles[0][0], tiles[height-1][width-1]);
  }
  
  factory Maze.parse(String map) {
    List<List<Tile>> tiles = <List<Tile>>[];
    List rows = map.trim().split('\n');
    Tile start;
    Tile goal;
    
    for (var rowNum = 0; rowNum < rows.length; rowNum++) {
      var row = new List<Tile>();
      var lineTiles = rows[rowNum].trim().split("");
      
      for (var colNum = 0; colNum < lineTiles.length; colNum++) {
        var t = lineTiles[colNum];
        bool obstacle = (t == 'x');
        var tile = new Tile(colNum, rowNum, obstacle);
        if (t == 's') start = tile;
        if (t == 'g') goal = tile;
        row.add(tile);
      }
      
      tiles.add(row);
    }
    
    return new Maze(tiles, start, goal);
  }
}

class Tile {
  final int x, y;
  final bool obstacle;
  final int _hashcode;
  final String _str;
  
  // for A*
  double _f = -1.0;  // heuristic + cost
  double _g = -1.0;  // cost
  double _h = -1.0;  // heuristic estimate
  int _parentIndex = -1;
  
  Tile(int x, int y, bool obstacle)
      : x = x,
        y = y,
        obstacle = obstacle,
        _hashcode = "$x,$y".hashCode,
        _str = '[X:$x, Y:$y, Obs:$obstacle]';
  
  String toString() => _str;
  int get hashCode => _hashcode;
  
  bool operator ==(Tile tile) {
    return x == tile.x && y == tile.y;
  }

}

double hueristic(Tile tile, Tile goal) {
  int x = tile.x-goal.x;
  int y = tile.y-goal.y;
  return Math.sqrt(x*x+y*y);
}

// thanks to http://46dogs.blogspot.com/2009/10/star-pathroute-finding-javascript-code.html
// for the original algorithm

/**
 * This algorithm works only for 2D grids. There is a lot of room to optimize
 * this further.
 */
Queue<Tile> aStar2D(Maze maze) {
  List<List<Tile>> map = maze.tiles;
  Tile start = maze.start;
  Tile goal = maze.goal;
  int numRows = map.length;
  int numColumns = map[0].length;
  
  List<Tile> open = <Tile>[];
  List<Tile> closed = <Tile>[];
  
  double g = 0.0;
  double h = hueristic(start, goal);
  double f = g + h;
  
  open.add(start);
  
  while (open.length > 0) {
    double bestCost = open[0]._f;
    int bestTileIndex = 0;

    for (int i = 1; i < open.length; i++) {
      if (open[i]._f < bestCost) {
        bestCost = open[i]._f;
        bestTileIndex = i;
      }
    }
    
    Tile currentTile = open[bestTileIndex];
    
    if (currentTile == goal) {
      // queues are more performant when adding to the front
      Queue<Tile> path = new Queue<Tile>.from([goal]);

      // Go up the chain to recreate the path 
      while (currentTile._parentIndex != -1) {
        currentTile = closed[currentTile._parentIndex];
        path.addFirst(currentTile);
      }

      return path;
    }
    
    open.removeAt(bestTileIndex);

    closed.add(currentTile);    
    
    for (int newX = Math.max(0, currentTile.x-1); newX <= Math.min(numColumns-1, currentTile.x+1); newX++) {
      for (int newY = Math.max(0, currentTile.y-1); newY <= Math.min(numRows-1, currentTile.y+1); newY++) {
        if (!map[newY][newX].obstacle // If the new node is open
          || (goal.x == newX && goal.y == newY)) { // or the new node is our destination
          //See if the node is already in our closed list. If so, skip it.
          bool foundInClosed = false;
          for (int i = 0; i < closed.length; i++) {
            if (closed[i].x == newX && closed[i].y == newY) {
              foundInClosed = true;
              break;
            }
          }

          if (foundInClosed) {
            continue;
          }

          //See if the node is in our open list. If not, use it.
          bool foundInOpen = false;
          for (int i = 0; i < open.length; i++) {
            if (open[i].x == newX && open[i].y == newY) {
              foundInOpen = true;
              break;
            }
          }

          if (!foundInOpen) {
            Tile tile = map[newY][newX];
            tile._parentIndex = closed.length-1;

            tile._g = currentTile._g + Math.sqrt(Math.pow(tile.x-currentTile.x, 2) +
                      Math.pow(tile.y-currentTile.y, 2));
            tile._h = hueristic(tile, goal);
            tile._f = tile._g+tile._h;

            open.add(tile);
          }
        }
      }
    }
  }
  
  return new Queue<Tile>();
}