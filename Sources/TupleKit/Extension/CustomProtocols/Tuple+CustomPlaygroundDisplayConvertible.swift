extension Tuple: CustomPlaygroundDisplayConvertible {
  /// Displays the built-in tuple of members instead of an array of erased members.
  public var playgroundDescription: Any {
    members
  }
}
