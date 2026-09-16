#if canImport(IOKit.pwr_mgt)
import IOKit.pwr_mgt

func withSleepInhibited(operation: () async throws -> Void) async throws {
  let assertionID = try {
    var assertionID = IOPMAssertionID(0)
    let ioReturn = IOPMAssertionCreateWithDescription(
      kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
      "caffeinate-downloads" as CFString,
      "There are files being downloaded" as CFString,
      nil, nil, 0, nil,
      &assertionID
    )
    guard ioReturn == kIOReturnSuccess else {
      throw SleepInhibitionError("failed to inhibit sleep", ioReturn)
    }
    return assertionID
  }()

  do {
    try await operation()
  } catch is CancellationError {
  }

  let ioReturn = IOPMAssertionRelease(assertionID)
  guard ioReturn == kIOReturnSuccess else {
    throw SleepInhibitionError("failed to allow sleep", ioReturn)
  }
}

struct SleepInhibitionError: CustomStringConvertible, Error {
    let description: String

    init(_ description: String, _ code: IOReturn) {
        if let code = mach_error_string(code) {
            self.description = "\(description): \(String(cString: code))"
        } else {
            self.description = "\(description): \(code)"
        }
    }
}
#endif
