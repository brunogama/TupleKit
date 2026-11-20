/// Lists every combination of member cases when every member is `CaseIterable`.
///
/// `allCases` is the cartesian product of the members' cases, in position order: the last
/// member varies fastest. The count is the product of the member counts, so it grows quickly
/// with every added member.
///
/// ```swift
/// enum Size: CaseIterable { case small, large }
/// enum Tone: CaseIterable { case light, dark }
/// let variants = Tuple<Size, Tone>.allCases
/// // variants is [Tuple(.small, .light), Tuple(.small, .dark), Tuple(.large, .light),
/// //               Tuple(.large, .dark)]
/// ```
extension Tuple: CaseIterable where repeat each Member: CaseIterable {
  /// Every combination of member cases, in position order with the last member varying
  /// fastest.
  ///
  /// An empty array when any member has no cases. An empty tuple has exactly one case.
  public static var allCases: [Self] {
    var memberCases: [Any] = []
    repeat memberCases.append((each Member).allCases)
    var radices: [Int] = []
    repeat radices.append((each Member).allCases.count)
    guard !radices.contains(0) else { return [] }
    var digits = [(radix: Int, stride: Int)]()
    digits.reserveCapacity(radices.count)
    var stride = 1
    for radix in radices.reversed() {
      digits.append((radix: radix, stride: stride))
      stride *= radix
    }
    digits.reverse()
    let total = radices.reduce(1, *)
    var cases: [Self] = []
    cases.reserveCapacity(total)
    for ordinal in 0..<total {
      cases.append(combination(ordinal, digits: digits, memberCases: memberCases))
    }
    return cases
  }

  /// Builds one combination by reading `ordinal` as a mixed-radix number whose least
  /// significant digit selects the last member's case.
  private static func combination(
    _ ordinal: Int,
    digits: [(radix: Int, stride: Int)],
    memberCases: [Any]
  ) -> Self {
    var position = 0
    func pick<Case: CaseIterable>(_: Case.Type) -> Case {
      defer { position += 1 }
      let entry = digits[position]
      let digit = ordinal / entry.stride % entry.radix
      guard let cases = memberCases[position] as? Case.AllCases else {
        preconditionFailure("Member case table does not match the member types")
      }
      return cases[cases.index(cases.startIndex, offsetBy: digit)]
    }
    return Tuple(members: (repeat pick((each Member).self)))
  }
}
