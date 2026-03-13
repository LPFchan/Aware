import Foundation
import IOKit
import IOKit.pwr_mgt

/// Wraps IOPMAssertion create/release logic for display sleep prevention.
final class SleepAssertion {
    private var assertionID: IOPMAssertionID = 0
    private let reason = "Aware: user presence detected" as CFString
    
    /// Creates and holds the display sleep prevention assertion.
    /// Returns true if the assertion was successfully created.
    func acquire() -> Bool {
        guard assertionID == 0 else { return true }
        
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
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
