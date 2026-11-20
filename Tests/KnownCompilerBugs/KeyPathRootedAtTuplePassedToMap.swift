import TupleKit

// Every key path rooted at Tuple crashes IR generation, not only stored ones.
// Workaround: pass ElementwiseTuple.init or a closure to map.
func mapThroughKeyPath() {
  let views = [Tuple(1, 0.5)].map(\.elementwise)  // known-bug
  print(views)
}
