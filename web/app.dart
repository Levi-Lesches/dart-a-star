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

import 'dart:html';
import 'dart:math' as Math;
import 'dart:collection' show Queue;
import 'package:a_star/a_star_2d.dart';

class CanvasMap {
  final CanvasElement canvas;
  final CanvasRenderingContext2D ctx;
  final Maze maze;
  final Tile startTile;
  final Tile goalTile;

  final int width;
  final int height;
  final int numRows;
  final int numCols;
  final num tileWidth;
  final num tileHeight;

  CanvasMap(canvas, maze)
      : canvas = canvas,
        maze = maze,
        startTile = maze.start,
        goalTile = maze.goal,
        ctx = canvas.getContext("2d"),
        width = canvas.width,
        height = canvas.height,
        numRows = maze.tiles.length,
        numCols = maze.tiles[0].length,
        tileWidth = canvas.width / maze.tiles[0].length,
        tileHeight = canvas.height / maze.tiles[0].length;

  drawTile(Tile tile) {
    var loc = coords(tile);
    ctx.beginPath();
    if (tile.obstacle) {
      ctx.fillStyle = 'red';
    } else {
      ctx.fillStyle = 'black';
    }
    ctx.arc(loc[0], loc[1], 5, 0, Math.pi * 2, true);
    ctx.fill();
  }

  drawStart(Tile start) {
    var loc = coords(start);
    ctx.beginPath();
    ctx.strokeStyle = 'blue';
    ctx.arc(loc[0], loc[1], 15, 0, Math.pi * 2, true);
    ctx.stroke();
  }

  drawGoal(Tile start) {
    var loc = coords(start);
    ctx.beginPath();
    ctx.strokeStyle = 'green';
    ctx.arc(loc[0], loc[1], 15, 0, Math.pi * 2, true);
    ctx.stroke();
  }

  drawLine(Tile start, Tile end) {
    var moveTo = coords(start);
    var lineTo = coords(end);
    ctx.beginPath();
    ctx.strokeStyle = 'black';
    ctx.moveTo(moveTo[0], moveTo[1]);
    ctx.lineTo(lineTo[0], lineTo[1]);
    ctx.stroke();
  }

  coords(Tile tile) {
    num x = (tile.x + 1) * tileWidth - (tileWidth / 2);
    num y = (tile.y + 1) * tileHeight - (tileHeight / 2);
    return [x, y];
  }

  drawMap() {
    for (var y = 0; y < maze.tiles.length; y++) {
      List<Tile> row = maze.tiles[y];
      for (var x = 0; x < row.length; x++) {
        Tile tile = row[x];
        drawTile(tile);
      }
    }

    drawStart(startTile);
    drawGoal(goalTile);
  }

  drawSolution(Queue<Tile> solution) {
    var start;
    solution.forEach((Tile tile) {
      if (start == null) {
        start = tile;
      } else {
        drawLine(start, tile);
        start = tile;
      }
    });
  }
}

void generateMapAndSolve(CanvasElement canvas) {
  canvas.context2D.clearRect(0, 0, canvas.width, canvas.height);

  Maze maze = new Maze.random(width: 10, height: 10);
  CanvasMap canvasMap = new CanvasMap(canvas, maze);
  canvasMap.drawMap();

  Queue<Tile> solution = aStar2D(maze);

  canvasMap.drawSolution(solution);
}

main() {
  CanvasElement canvas = querySelector('#surface');
  querySelector('#b').onClick.listen((e) => generateMapAndSolve(canvas));

//  var textMap = """
//            sooooooo
//            oxxxxxoo
//            oxxoxooo
//            oxoogxxx
//            """;
//
//  Maze maze = parseTiles(textMap);
}
