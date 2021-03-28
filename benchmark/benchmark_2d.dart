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

import 'package:a_star/a_star_2d.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

class AStar2DBenchmark extends BenchmarkBase {
  static const String textMap = '''
      soooooooxoxo
      oxxxxxooxoxo
      oxxoxoooxoxx
      oxoooxxxooox
      oooxxoxoxxox
      xxoooxxxooox
      oxxoxxooxoxo
      oxxoxoooxoxx
      oxoooxxxooog
      ''';

  late Maze maze;

  AStar2DBenchmark() : super('AStar2D');

  // The benchmark code.
  @override
  void run() {
    aStar2D(maze);
  }

  // Not measured setup code executed prior to the benchmark runs.
  @override
  void setup() {
    maze = Maze.parse(textMap);
  }

  // Not measures teardown code executed after the benchark runs.
  @override
  void teardown() {}
}

void main() {
  AStar2DBenchmark().report();
}
