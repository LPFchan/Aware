import Foundation
import IOKit
import IOKit.pwr_mgt

/// Wraps IOPMAssertion logic for keeping the display and screensaver timers reset.
final class SleepAssertion {
    private var assertionID: IOPMAssertionID = 0
    private let reason = "Aware: user presence detected" as CFString

    /// Declares local user activity, resetting both the display-sleep and screensaver idle timers.
    /// Safe to call repeatedly — releases the previous assertion before creating a new one.
    /// Returns true if the assertion was successfully created.
    @discardableResult
    func acquire() -> Bool {
        if assertionID != 0 {
            IOPMAssertionRelease(assertionID)
            assertionID = 0
        }
        let result = IOPMAssertionDeclareUserActivity(
            reason,
            kIOPMUserActiveLocal,
            &assertionID
        )
        return result == kIOReturnSuccess
    }
    
    /// Releases the display sleep prevention assertion.
    func release() {
        guard assertionID != 0 else { return }
        
        IOPMAssertionRelease(assertionID)
        assertionID = 0
    }
    
    /// Returns whether the assertion is currently held.
    var isActive: Bool {
        assertionID != 0
    }
}

/// Returns true if any process other than this one currently holds a display- or system-sleep-prevention assertion.
/// Used to skip the camera check when another app (e.g. a browser playing video) is already keeping the Mac awake.
func externalSleepAssertionIsActive() -> Bool {
    var assertionsByPID: Unmanaged<CFDictionary>?
    guard IOPMCopyAssertionsByProcess(&assertionsByPID) == kIOReturnSuccess else { return false }
    let dict = assertionsByPID!.takeRetainedValue() as NSDictionary

    let myPID = Int(ProcessInfo.processInfo.processIdentifier)
    let preventTypes: Set<String> = [
        kIOPMAssertionTypePreventUserIdleDisplaySleep,
        kIOPMAssertionTypePreventUserIdleSystemSleep,
        kIOPMAssertionTypeNoDisplaySleep,
    ]

    for (key, value) in dict {
        guard let pid = (key as? NSNumber)?.intValue, pid != myPID else { continue }
        guard let assertions = value as? [[String: Any]] else { continue }
        for assertion in assertions {
            if let assertionType = assertion[kIOPMAssertionTypeKey] as? String,
               preventTypes.contains(assertionType) {
                return true
            }
        }
    }
    return false
}
