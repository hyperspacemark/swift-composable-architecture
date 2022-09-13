import ComposableArchitecture
import Dependencies
import XCTest

final class DependencyKeyTests: XCTestCase {
  func testTestDependencyKeyDefaultPreviewValue() {
    enum Key: TestDependencyKey {
      typealias Value = Int
      static let testValue = 42
    }

    XCTAssertEqual(42, Key.previewValue)
  }

  func testMissingPreviewValue_CascadesToLiveValue() {
    enum Key: DependencyKey {
      static let liveValue = 42
    }
    XCTAssertEqual(42, Key.previewValue)
  }

  func testMissingPreviewValue_CascadeToLiveValue() {
    enum Key: DependencyKey {
      typealias Value = Int
      static let liveValue = 42
      static let testValue = 1729
    }

    XCTAssertEqual(42, Key.previewValue)
  }

  func testMissingTestValue_CascadesToPreviewValue_WithTestFailure() {
    struct Feature: ReducerProtocol {
      @Dependency(\.myValue) var myValue
      func reduce(into state: inout Int, action: Void) -> Effect<Void, Never> {
        state += self.myValue
        return .none
      }
    }
    let store = TestStore(initialState: 0, reducer: Feature())

    XCTExpectFailure {
      _ = store.send(()) {
        $0 = 1729
      }
    } issueMatcher: { issue in
      issue.compactDescription == """
        A dependency is being used in a test environment without providing a test implementation:

          Key:
            MyValueKey
          Dependency:
            Int

        Dependencies registered with the library are not allowed to use their live implementations \
        when run in a 'TestStore'.

        To fix, make sure that MyValueKey provides an implementation of 'testValue' in its \
        conformance to the 'DependencyKey` protocol.
        """
    }
  }
}

private enum MyValueKey: DependencyKey {
  static let liveValue = 42
  static let previewValue = 1729
}
extension DependencyValues {
  fileprivate var myValue: Int {
    self[MyValueKey.self]
  }
}
