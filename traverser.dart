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

#library('aStar');

class Tile implements Hashable {
  final int x, y;
  final bool obstacle;
  final int hashcode;
  final String str;
  
  // for A*
  int _f = -1;  // heuristic + cost
  int _g = -1;  // cost
  int _h = -1;  // heuristic estimate
  int _parentIndex = -1;
  
  Tile(int x, int y, bool obstacle)
      : x=x,
        y=y,
        obstacle=obstacle,
        hashcode = "$x,$y".hashCode(),
        str = '[X:$x, Y:$y, X:$obstacle]';
  
  String toString() => str;
  int hashCode() => hashcode;
  
  bool equals(Tile tile) {
    return x == tile.x && y == tile.y;
  }
  
  // this will go away soon when dart2js and vm implement this for us
  bool operator ==(other) {
    if (this === other) return true;
    if (other == null) return false;
    return equals(other);
  }
}

List<List<Tile>> parseTiles(String map) {
  var tiles = <List<Tile>>[];
  
  var rows = map.trim().split('\n');
  for (var rowNum = 0; rowNum < rows.length; rowNum++) {
    var row = new List<Tile>();
    
    var lineTiles = rows[rowNum].trim().split("");
    for (var colNum = 0; colNum < lineTiles.length; colNum++) {
      var t = lineTiles[colNum];
      bool obstacle = t == 'x';
      row.add(new Tile(colNum, rowNum, obstacle));
    }
    tiles.add(row);
  }
  return tiles;
}

int hueristic(Tile tile, Tile goal) {
  var x = tile.x-goal.x;
  var y = tile.y-goal.y;
  return x*x+y*y;
}

Queue<Tile> aStar(Tile start, Tile goal, List<List<Tile>> map) {
  var numRows = map.length;
  var numColumns = map[0].length;
  
  var open = <Tile>[];
  var closed = <Tile>[];
  
  var g = 0;
  var h = hueristic(start, goal);
  var f = g + h;
  
  open.add(start);
  
  while (open.length > 0) {
    int bestCost = open[0].f;
    int bestTileIndex = 0;

    for (var i = 1; i < open.length; i++) {
      if (open[i].f < bestCost) {
        bestCost = open[i].f;
        bestTileIndex = i;
      }
    }
    
    var currentTile = open[bestTileIndex];
    
    if (currentTile == goal) {
      // queues are more performant when adding to the front
      var path = new Queue<Tile>.from([goal]);

      //Go up the chain to recreate the path 
      while (currentTile.parentIndex != -1) {
        currentTile = closed[currentTile.parentIndex];
        path.addFirst(currentTile);
      }

      return path;
    }
    
    open.removeRange(bestTileIndex, 1);

    //Push it onto the closed list
    closed.add(currentTile);
    
    //print("Closed is now $closed");
    
    for (var newX = Math.max(0, currentTile.x-1); newX <= Math.min(numColumns-1, currentTile.x+1); newX++) {
      for (var newY = Math.max(0, currentTile.y-1); newY <= Math.min(numRows-1, currentTile.y+1); newY++) {
        if (!map[newY][newX].obstacle //If the new node is open
          || (goal.x == newX && goal.y == newY)) { //or the new node is our destination
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
            var tile = map[newY][newX];
            tile._parentIndex = closed.length-1;

            tile._g = currentTile.g + Math.sqrt(Math.pow(tile.x-currentTile.x, 2)+Math.pow(tile.y-currentTile.y, 2)).floor().toInt();
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

main() {
  var map = """
oooooooo
oxxxxxoo
oxxoxooo
oxoooxxx      
""";
  
  List<List<Tile>> tiles = parseTiles(map);
  //print(tiles[2][1]);
  Tile start = tiles[0][0];
  Tile goal = tiles[3][3];
  
  for (var i = 0; i < 1000; i++) {
    Queue<Tile> path = aStar(start, goal, tiles);
  }
}