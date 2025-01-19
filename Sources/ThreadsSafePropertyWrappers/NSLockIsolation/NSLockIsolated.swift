import Foundation

/// A property wrapper that provides thread-safe access to a value using NSLock.
///
/// `NSLockIsolated` provides a simple and reliable way to ensure thread-safe access to a value using Foundation's `NSLock`.
@propertyWrapper
public struct NSLockIsolated<Value>: @unchecked Sendable {
    private var _wrappedValue: Value
    private let lock = NSLock()
    
    public init(wrappedValue: Value) {
        self._wrappedValue = wrappedValue
    }
    
    /// The synchronized value.
    ///
    /// Access to this value is automatically synchronized using an NSLock.
    public var wrappedValue: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _wrappedValue
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _wrappedValue = newValue
        }
    }
}
