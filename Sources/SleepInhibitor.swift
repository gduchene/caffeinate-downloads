import IOKit.pwr_mgt

actor SleepInhibitor {
  var assertionID = IOPMAssertionID?.none
  var isInhibitingSleep: Bool { self.assertionID != nil }

  func create(name: String, details: String) throws {
    guard self.assertionID == nil else {
      return
    }

    var assertionID = IOPMAssertionID(0)
    let ioReturn = IOPMAssertionCreateWithDescription(
      kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
      name as CFString,
      details as CFString,
      nil, nil, 0, nil,
      &assertionID
    )
    guard ioReturn == kIOReturnSuccess else {
      throw SleepInhibitorError(ioReturn: ioReturn)
    }
    self.assertionID = assertionID
  }

  func release() throws {
    guard let assertionID = self.assertionID else {
      return
    }

    let ioReturn = IOPMAssertionRelease(assertionID)
    guard ioReturn == kIOReturnSuccess else {
      throw SleepInhibitorError(ioReturn: ioReturn)
    }
    self.assertionID = nil
  }
}

struct SleepInhibitorError: CustomStringConvertible, Error {
  let ioReturn: IOReturn

  var description: String {
    guard let cString = mach_error_string(self.ioReturn) else {
      return self.ioReturn.description
    }
    return String(cString: cString)
  }
}
