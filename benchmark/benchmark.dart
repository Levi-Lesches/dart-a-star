import 'package:a_star/traverser.dart';

// TODO: use benchmark harness

main() {
  
  var textMap = """
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
  
  Maze maze = parseTiles(textMap);
  print('Start is at ${maze.start}');
  print('Goal is at ${maze.goal}');
  
  print('Warming up');
  
  for (var i = 0; i < 1000; i++) {
    aStar(maze);
  }
  
  print('Starting test');
  
  var stopwatch = new Stopwatch()..start();
  for (var i = 0; i < 10000; i++) {
    aStar(maze);
  }
  stopwatch.stop();
  
  print(stopwatch.elapsedMilliseconds);
}