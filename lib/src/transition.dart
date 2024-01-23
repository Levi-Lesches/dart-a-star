import "state.dart";

class AStarTransition<T extends AStarState<T>> {
  final T parent;
  AStarTransition(this.parent);
}
