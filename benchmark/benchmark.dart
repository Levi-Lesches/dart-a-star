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

import 'dart:collection';
import 'dart:math' as math;
import 'package:a_star/a_star.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

class Simple2DNode extends Object with Node<Simple2DNode> {
  int x;
  int y;
  num nodeInherentCost;
  Set<Simple2DNode> connectedNodes = <Simple2DNode>{};

  Simple2DNode(this.x, this.y, this.nodeInherentCost);

  @override
  String toString() => '[$x,$y]';
}

class Simple2DMaze implements Graph<Simple2DNode> {
  late List<List<Simple2DNode>> tiles;

  Simple2DMaze(List<List<num>> costMap) {
    tiles = [];
    for (var i = 0; i < costMap.length; i++) {
      final rawRow = costMap[i];
      tiles[i] = [];
      for (var j = 0; j < rawRow.length; j++) {
        final rawTile = rawRow[j];
        tiles[i][j] = Simple2DNode(j, i, rawTile);
        allNodes.add(tiles[i][j]);
      }
    }
    _generateConnectedNodes();
  }

  void _generateConnectedNodes() {
    for (var rowNum = 0; rowNum < tiles.length; rowNum++) {
      final row = tiles[rowNum];
      for (var colNum = 0; colNum < row.length; colNum++) {
        final tile = row[colNum];
        for (var i = rowNum - 1; i <= rowNum + 1; i++) {
          if (i < 0 || i >= tiles.length) {
            continue; // Outside Maze bounds.
          }
          for (var j = colNum - 1; j <= colNum + 1; j++) {
            if (j < 0 || j >= row.length) {
              continue; // Outside Maze bounds.
            }
            if (i == rowNum && j == colNum) {
              continue; // Same tile.
            }
            tile.connectedNodes.add(tiles[i][j]);
          }
        }
      }
    }
  }

  Simple2DNode getNode(int x, int y) => tiles[x][y];

  @override
  List<Simple2DNode> allNodes = [];

  @override
  num getDistance(Simple2DNode a, Simple2DNode b) => b.nodeInherentCost;

  @override
  num getHeuristicDistance(Simple2DNode a, Simple2DNode b) =>
      math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2));

  @override
  Iterable<Simple2DNode> getNeighboursOf(Simple2DNode node) =>
      node.connectedNodes;
}

class AStarBenchmark extends BenchmarkBase {
  static const List<List<num>> costMap = [
    [1, 10, 1, 1, 1, 1, 1, 1],
    [1, 10, 1, 1, 1, 1, 1, 1],
    [1, 10, 1, 1, 1, 1, 1, 1],
    [1, 10, 1, 1, 1, 1, 1, 1],
    [1, 10, 1, 2, 1, 1, 1, 1],
    [1, 10, 1, 2, 1, 1, 1, 1],
    [1, 10, 1, 2, 1, 1, 20, 2],
    [1, 1, 1, 2, 1, 1, 10, 1],
  ];

  AStarBenchmark() : super('AStar');

  // The benchmark code.
  @override
  void run() {
    resultQueue = aStar.findPathSync(maze.getNode(0, 0), maze.getNode(7, 7));
  }

  late Simple2DMaze maze;
  late Queue<Simple2DNode> resultQueue;
  late AStar<Simple2DNode> aStar;

  // Not measured setup code executed prior to the benchmark runs.
  @override
  void setup() {
    maze = Simple2DMaze(costMap);
    aStar = AStar(maze);
  }

  // Not measures teardown code executed after the benchmark runs.
  @override
  void teardown() {
    // ignore: avoid_print
    print(resultQueue);
  }
}

void main() {
  AStarBenchmark().report();
}
