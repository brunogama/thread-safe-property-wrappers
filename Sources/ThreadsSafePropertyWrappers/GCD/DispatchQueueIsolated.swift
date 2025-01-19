import Foundation

/// A property wrapper that provides thread-safe access to a value using a serial DispatchQueue.
///
/// `DispatchQueueIsolated` uses GCD's `DispatchQueue` to provide synchronized access to a value.
@propertyWrapper
public struct DispatchQueueIsolated<Value: Sendable>: Sendable {
    private let queue = DispatchQueue(label: "com.synchronized.queue", attributes: .concurrent)
    private var _value: Value

    /// Creates a new synchronized value.
    /// - Parameter wrappedValue: The initial value to store.
    public init(wrappedValue: Value) {
        self._value = wrappedValue
    }

    /// The synchronized value.
    ///
    /// Access to this value is automatically synchronized using a concurrent dispatch queue with a barrier for writing.
    public var wrappedValue: Value {
        get { queue.sync { _value } }
        set { queue.sync(flags: .barrier) { _value = newValue } }
    }
}
