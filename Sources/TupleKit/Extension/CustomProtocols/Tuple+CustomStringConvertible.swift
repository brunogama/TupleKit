/// Prints the members in position order, with text members quoted.
extension Tuple: CustomStringConvertible {
  /// The members, in position order, written as `Tuple(1, "a")`.
  ///
  /// Text members, `String`, `Substring`, and `Character`, are quoted and escaped, so
  /// `Tuple("a, b")` stays distinct from `Tuple("a", "b")`. A nested tuple renders in this
  /// same form. Every other member renders as `String(describing:)` renders it.
  ///
  /// ```swift
  /// let text = Tuple(1, "a").description  // #"Tuple(1, "a")"#
  /// ```
  public var description: String {
    var rendered = ""
    write(to: &rendered)
    return rendered
  }
}

/// Prints the members with their static types, for debugging.
extension Tuple: CustomDebugStringConvertible {
  /// The static member types followed by each member and its type.
  ///
  /// ```swift
  /// let text = Tuple(1, "a").debugDescription  // #"Tuple<Int, String> { 1 (Int), "a" (String) }"#
  /// ```
  public var debugDescription: String {
    var typeNames: [String] = []
    repeat typeNames.append(readableTypeName((each Member).self))
    let header = "Tuple<\(typeNames.joined(separator: ", "))>"
    guard !typeNames.isEmpty else { return "\(header) {}" }
    var rendered = "\(header) { "
    var position = 0
    for member in repeat each members {
      if position > 0 { rendered.write(", ") }
      renderMember(member, into: &rendered)
      rendered.write(" (\(typeNames[position]))")
      position += 1
    }
    rendered.write(" }")
    return rendered
  }
}

extension Tuple: NestedTupleRendering {}

/// Lets a tuple render a nested tuple member as `Tuple(...)` instead of its debug form.
private protocol NestedTupleRendering {
  func write<Target: TextOutputStream>(to target: inout Target)
}

/// Renders one member into a stream: text quoted and escaped, a nested tuple in its plain
/// form, and any other value as `String(describing:)` renders it.
///
/// Only text is quoted. Rendering every member with `String(reflecting:)`, as Swift renders
/// a built-in tuple, would print a private enum case with a memory address that changes
/// between runs.
func renderMember<Target: TextOutputStream>(_ member: Any, into target: inout Target) {
  if let nested = member as? any NestedTupleRendering {
    nested.write(to: &target)
    return
  }
  if member is any StringProtocol || member is Character {
    target.write(String(reflecting: member))
    return
  }
  target.write(String(describing: member))
}

/// The type's name as written in source.
///
/// The runtime spells a nested tuple type `Tuple<Pack{String, Bool}>`. This removes each
/// `Pack{` and its matching `}`, so the name reads `Tuple<String, Bool>`.
private func readableTypeName(_ type: Any.Type) -> String {
  let packOpening = "Pack{"
  var name = ""
  var braces: [Bool] = []
  var remaining = Substring(String(describing: type))
  while let character = remaining.first {
    if remaining.hasPrefix(packOpening) {
      braces.append(true)
      remaining = remaining.dropFirst(packOpening.count)
      continue
    }
    remaining = remaining.dropFirst()
    if character == "{" {
      braces.append(false)
    }
    else if character == "}", let isPack = braces.popLast(), isPack {
      continue
    }
    name.append(character)
  }
  return name
}
