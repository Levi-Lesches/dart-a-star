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

import 'package:a_star/a_star.dart';
import 'package:a_star/a_star_2d.dart';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'dart:collection';
import 'dart:math' as Math;

class GeneralizedTile extends Tile with Node {
  GeneralizedTile(int x, int y, bool obstacle) : super(x, y, obstacle);
}

class GeneralizedMaze implements Graph<GeneralizedTile> {
  List<List<GeneralizedTile>> tiles = List();
  GeneralizedTile start;
  GeneralizedTile goal;

  int numColumns;
  int numRows;

  GeneralizedMaze(String map) {
    var maze = Maze.parse(map); // Lazy. Outsource parsing to the original.

    numRows = maze.tiles.length;
    numColumns = maze.tiles[0].length;

    for (int i = 0; i < numRows; i++) {
      var row = List<GeneralizedTile>();
      tiles.add(row);
      for (int j = 0; j < numColumns; j++) {
        var orig = maze.tiles[i][j];
        row.add(GeneralizedTile(orig.x, orig.y, orig.obstacle));
      }
    }

    start = tiles[maze.start.y][maze.start.x];
    goal = tiles[maze.goal.y][maze.goal.x];
  }

  @override
  Iterable<GeneralizedTile> get allNodes {
    return tiles.expand((row) => row);
  }

  @override
  num getDistance(GeneralizedTile a, GeneralizedTile b) {
    if (b.obstacle) return null;
    return Math.sqrt(Math.pow(b.x - a.x, 2) + Math.pow(b.y - a.y, 2));
  }

  @override
  num getHeuristicDistance(GeneralizedTile tile, GeneralizedTile goal) {
    int x = tile.x - goal.x;
    int y = tile.y - goal.y;
    return Math.sqrt(x * x + y * y);
  }

  @override
  Iterable<GeneralizedTile> getNeighboursOf(GeneralizedTile currentTile) {
    Queue<GeneralizedTile> result = Queue<GeneralizedTile>();
    for (int newX = Math.max(0, currentTile.x - 1);
        newX <= Math.min(numColumns - 1, currentTile.x + 1);
        newX++) {
      for (int newY = Math.max(0, currentTile.y - 1);
          newY <= Math.min(numRows - 1, currentTile.y + 1);
          newY++) {
        result.add(tiles[newY][newX]);
      }
    }
    return result;
  }
}

/// This is here to compare the new, generalized A* approach to the older,
/// 2D-only code. The goal is to attain similar performance even with the
/// more flexible design.
class AStar2DGeneralizedBenchmark extends BenchmarkBase {
  static const String textMap = """
      soooooooxoxo
      oxxxxxooxoxo
      oxxoxoooxoxx
      oxoooxxxooox
      oooxxoxoxxox
      xxoooxxxooox
      oxxoxxooxoxo
      oxxoxoooxoxx
      oxoooxxxooog
      """;

  AStar2DGeneralizedBenchmark() : super("AStar_Generalized_2D");

  // The benchmark code.
  @override
  void run() {
    resultQueue = aStar.findPathSync(maze.start, maze.goal);
  }

  GeneralizedMaze maze;
  Queue<GeneralizedTile> resultQueue;
  AStar<GeneralizedTile> aStar;

  // Not measured setup code executed prior to the benchmark runs.
  @override
  void setup() {
    maze = GeneralizedMaze(textMap);
    aStar = AStar(maze);
  }

  // Not measures teardown code executed after the benchark runs.
  @override
  void teardown() {
    print(resultQueue);
  }
}

main() {
  AStar2DGeneralizedBenchmark().report();
}
