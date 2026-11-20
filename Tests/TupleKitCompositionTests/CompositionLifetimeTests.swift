import Testing
import TupleKitComposition

/// An object whose deallocation a test can observe through a weak reference.
private final class Tracked {
  let identifier: Int

  init(_ identifier: Int) {
    self.identifier = identifier
  }
}

/// Each test keeps only weak references outside a scope and expects the objects to be freed
/// when nothing in the API should still hold them.
struct CompositionLifetimeTests {
  @Test func predicatePatternReleasesTheObjectsItsPredicateCaptures() {
    weak var weakCaptured: Tracked?
    do {
      let captured = Tracked(2)
      weakCaptured = captured
      let multiple = PredicatePattern<Int> { $0.isMultiple(of: captured.identifier) }
      #expect(multiple.matches(4))
    }
    #expect(weakCaptured == nil)
  }

  @Test func boundedHistoryReleasesValuesItDrops() {
    weak var weakFirst: Tracked?
    do {
      var history = AccumulatingValue(wrappedValue: Tracked(1), capacity: 1)
      weakFirst = history.wrappedValue
      history.wrappedValue = Tracked(2)
      #expect(weakFirst == nil)
      #expect(history.projectedValue.map(\.identifier) == [2])
    }
  }

  @Test func historyReleasesEveryValueWhenItGoesAway() {
    weak var weakFirst: Tracked?
    weak var weakSecond: Tracked?
    do {
      var history = AccumulatingValue(wrappedValue: Tracked(1))
      weakFirst = history.wrappedValue
      history.wrappedValue = Tracked(2)
      weakSecond = history.wrappedValue
      #expect(history.projectedValue.count == 2)
    }
    #expect(weakFirst == nil)
    #expect(weakSecond == nil)
  }
}
