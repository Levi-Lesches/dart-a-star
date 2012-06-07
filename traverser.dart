class Point implements Hashable {
  final int x, y, _hashCode;
  final String _str;
  const Point(x, y)
      : x = x,
        y = y,
        _hashCode = "$x,$y".hashCode(),
        _str = '[X:$x, Y:$y]';
  int hashCode() => _hashCode;
  
  bool equals(Point other) {
    return x == other.x && y == other.y;
  }
  
  // this will go away soon when dart2js and vm implement this for us
  bool operator ==(other) {
    if (this === other) return true;
    if (other == null) return false;
    return equals(other);
  }
  
  String toString() => _str;
}

class Tile {
  final Point point;
  final bool obstacle;
  final String _str;
  
  // for A*
  int f = -1;  // heuristic + cost
  int g = -1;  // cost
  int h = -1;  // heuristic estimate
  int parentIndex = -1;
  
  Tile(Point point, bool obstacle)
      : point = point,
        obstacle=obstacle,
        _str = '[P:$point, X:$obstacle]';
  
  String toString() => _str;
  
  bool equals(other) {
    return point == other.point;
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
    
    var lineTiles = rows[rowNum].split("");
    for (var colNum = 0; colNum < lineTiles.length; colNum++) {
      var t = lineTiles[colNum];
      bool obstacle = t == 'x';
      row.add(new Tile(new Point(colNum, rowNum), obstacle));
    }
    tiles.add(row);
  }
  return tiles;
}

int hueristic(Tile tile, Tile goal) {
  var x = tile.point.x-goal.point.x;
  var y = tile.point.y-goal.point.y;
  return x*x+y*y;
}

Queue<Tile> a_star(Tile start, Tile goal, List<List<Tile>> map, int numRows, int numColumns) {
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
    
    for (var new_node_x = Math.max(0, currentTile.point.x-1); new_node_x <= Math.min(numColumns-1, currentTile.point.x+1); new_node_x++) {
      for (var new_node_y = Math.max(0, currentTile.point.y-1); new_node_y <= Math.min(numRows-1, currentTile.point.y+1); new_node_y++) {
        if (!map[new_node_y][new_node_x].obstacle //If the new node is not blocked
          || (goal.point == new Point(new_node_x, new_node_y))) { //or the new node is our destination
          //See if the node is already in our closed list. If so, skip it.
          var found_in_closed = false;
          for (var i = 0; i < closed.length; i++) {
            if (closed[i].point == new Point(new_node_x, new_node_y)) {
              found_in_closed = true;
              break;
            }
          }

          if (found_in_closed) {
            continue;
          }

          //See if the node is in our open list. If not, use it.
          var found_in_open = false;
          for (var i = 0; i < open.length; i++) {
            if (open[i].point.x == new_node_x && open[i].point.y == new_node_y) {
              found_in_open = true;
              break;
            }
          }

          if (!found_in_open) {
            var new_node = map[new_node_y][new_node_x];
            new_node.parentIndex = closed.length-1;

            new_node.g = currentTile.g + Math.sqrt(Math.pow(new_node.point.x-currentTile.point.x, 2)+Math.pow(new_node.point.y-currentTile.point.y, 2)).floor().toInt();
            new_node.h = hueristic(new_node, goal);
            new_node.f = new_node.g+new_node.h;

            open.add(new_node);
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
    Queue<Tile> path = a_star(start, goal, tiles, 4, 8);
  }
}