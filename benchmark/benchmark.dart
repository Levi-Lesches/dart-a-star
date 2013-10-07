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
import 'package:benchmark_harness/benchmark_harness.dart';

class AStarBenchmark extends BenchmarkBase {
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
  
  Maze maze;
  
  AStarBenchmark() : super("AStar");

  // The benchmark code.
  void run() {
    aStar(maze);
  }

  // Not measured setup code executed prior to the benchmark runs.
  void setup() {
    maze = new Maze.parse(textMap);
  }

  // Not measures teardown code executed after the benchark runs.
  void teardown() { }
}

main() {
  new AStarBenchmark().report();
}
