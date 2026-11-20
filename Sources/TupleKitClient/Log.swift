/// Writes a message to standard output in debug builds, and does nothing in release builds.
///
/// The message is an autoclosure, so a release build doesn't evaluate it.
///
/// - Parameter message: The text to write.
func log(_ message: @autoclosure () -> String) {
  #if DEBUG
  // The one sanctioned console write in this package; release builds stay silent.
  // swiftlint:disable:next no_print
  print(message())
  #endif
}
