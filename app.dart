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

#import('dart:html');
#import('traverser.dart', prefix:'path');

class CanvasMap {
  final CanvasElement canvas;
  final CanvasRenderingContext2D ctx;
  final List<List<path.Tile>> map;
  final path.Tile startTile;
  final path.Tile goalTile;
  
  final int width;
  final int height;
  final int numRows;
  final int numCols;
  final num tileWidth;
  final num tileHeight;
  
  CanvasMap(canvas, map, startTile, goalTile)
      : canvas = canvas,
        map = map,
        startTile = startTile,
        goalTile = goalTile,
        ctx = canvas.getContext("2d"),
        width = canvas.width,
        height = canvas.height,
        numRows = map.length,
        numCols = map[0].length,
        tileWidth = canvas.width / map[0].length,
        tileHeight = canvas.height / map.length;
  
  drawTile(path.Tile tile) {
    var loc = coords(tile);
    ctx.beginPath();
    if (tile.obstacle) {
      ctx.fillStyle = 'red';
    } else {
      ctx.fillStyle = 'black';
    }
    ctx.arc(loc[0], loc[1], 5, 0, Math.PI*2, true);
    ctx.fill();
  }
  
  drawStart(path.Tile start) {
    var loc = coords(start);
    ctx.beginPath();
    ctx.strokeStyle = 'blue';
    ctx.arc(loc[0], loc[1], 15, 0, Math.PI*2, true); 
    ctx.stroke();
  }
  
  drawGoal(path.Tile start) {
    var loc = coords(start);
    ctx.beginPath();
    ctx.strokeStyle = 'green';
    ctx.arc(loc[0], loc[1], 15, 0, Math.PI*2, true); 
    ctx.stroke();
  }
  
  drawLine(path.Tile start, path.Tile end) {
    var moveTo = coords(start);
    var lineTo = coords(end);
    ctx.beginPath();
    ctx.strokeStyle = 'black';
    ctx.moveTo(moveTo[0], moveTo[1]);
    ctx.lineTo(lineTo[0], lineTo[1]);
    ctx.stroke();
  }
  
  coords(path.Tile tile) {
    num x = (tile.x+1)*tileWidth-(tileWidth/2);
    num y = (tile.y+1)*tileHeight-(tileHeight/2);
    return [x,y];
  }
  
  drawMap() {
    for (var y = 0; y < map.length; y++) {
      List<path.Tile> row = map[y];
      for (var x = 0; x < row.length; x++) {
        path.Tile tile = row[x];
        drawTile(tile);
      }
    }
    
    drawStart(startTile);
    drawGoal(goalTile);
  }
  
  drawSolution(Queue<path.Tile> solution) {
    var start;
    solution.forEach((path.Tile tile) {
      if (start == null) {
        start = tile;
      } else {
        drawLine(start, tile);
        start = tile;
      }
    });
  }
}


main() {
  var canvas = new CanvasElement(600, 800);
  canvas.style.cssText = 'border: 1px solid black';
  document.body.elements.add(canvas);
  
  var textMap = """
            oooooooo
            oxxxxxoo
            oxxoxooo
            oxoooxxx      
            """;
  
  List<List<path.Tile>> map = path.parseTiles(textMap);
  path.Tile start = map[0][0];
  path.Tile goal = map[3][3];
  
  CanvasMap canvasMap = new CanvasMap(canvas, map, start, goal);
  canvasMap.drawMap();
  
  Queue<path.Tile> solution = path.a_star(start, goal, map);
  
  canvasMap.drawSolution(solution);
}