import XCTest
@testable import AngryPomodoro

final class TimerViewModelTests: XCTestCase {
    func testFormattedTime() {
        let vm = TimerViewModel()
        vm.resetTimer()
        XCTAssertEqual(vm.formattedTimeRemaining, "25:00")
    }

    func testNextSessionSwitches() {
        let vm = TimerViewModel()
        vm.resetTimer()
        // Fast-forward by invoking the internal transition via reflection
        // Not ideal, so we simulate by setting remaining to zero and starting
        vm.toggleTimer()
        vm.timeRemainingSeconds = 0
        // Next tick should flip session
        let exp = expectation(description: "tick")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            XCTAssertFalse(vm.isWorkSession)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3)
        vm.toggleTimer()
    }
}
