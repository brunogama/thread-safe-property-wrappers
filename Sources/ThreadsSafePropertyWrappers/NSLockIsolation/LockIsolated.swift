@propertyWrapper
public struct LockIsolated<Value: Sendable>: Sendable {
    private var value: _RecursiveLockIsolated<Value>

    public init(wrappedValue: Value) {
        self.value = _RecursiveLockIsolated<Value>(wrappedValue)
    }

    public var wrappedValue: Value {
        get { value.withLock { $0 } }
        set { value.withLock { $0 = newValue } }
    }
}
