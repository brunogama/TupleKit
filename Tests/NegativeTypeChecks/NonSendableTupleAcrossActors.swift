import TupleKit

final class Counter {
  var value = 0
}

actor Receiver {
  func receive(_ box: Tuple<Counter, Int>) {}
}

@MainActor
func send(to receiver: Receiver) async {
  let box = Tuple(Counter(), 1)
  await receiver.receive(box)  // expected-error
  box[\.0].value += 1
}
