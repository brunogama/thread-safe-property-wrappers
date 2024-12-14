import Foundation
import os.lock

/// A collection of property wrappers that provide thread-safe access to values using different synchronization mechanisms.
///
/// These property wrappers provide different approaches to synchronizing access to values in a concurrent environment.
/// Each implementation offers different trade-offs between performance, complexity, and usage patterns.

// MARK: - Using NSLock

/// A property wrapper that provides thread-safe access to a value using NSLock.
///
/// `SynchronizedNSLock` provides a simple and reliable way to ensure thread-safe access to a value using Foundation's `NSLock`.
@propertyWrapper
public struct SynchronizedNSLock<Value: Sendable>: Sendable {
    private var value: Value
    private let lock = NSLock()

    /// Creates a new synchronized value.
    /// - Parameter wrappedValue: The initial value to store.
    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    /// The synchronized value.
    ///
    /// Access to this value is automatically synchronized using an NSLock.
    public var wrappedValue: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return value
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            value = newValue
        }
    }
}

// MARK: - Using DispatchQueue

/// A property wrapper that provides thread-safe access to a value using a serial DispatchQueue.
///
/// `SynchronizedQueue` uses GCD's `DispatchQueue` to provide synchronized access to a value.
@propertyWrapper
public struct SynchronizedQueue<Value: Sendable>: Sendable {
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
        get {
            queue.sync { _value }
        }
        set {
            queue.sync(flags: .barrier) {
                _value = newValue
            }
        }
    }
}

// MARK: - Using OSUnfairLock (Most Lightweight)

/// A property wrapper that provides high-performance thread-safe access using os_unfair_lock.
///
/// `SynchronizedUnfairLock` provides the highest performance synchronization using the lightweight `os_unfair_lock`.
@propertyWrapper
public struct SynchronizedUnfairLock<Value: Sendable>: ~Copyable, @unchecked Sendable {
    private var value: Value
    private let lock: os_unfair_lock_t

    /// Creates a new synchronized value.
    /// - Parameter wrappedValue: The initial value to store.
    public init(wrappedValue: Value) {
        self.value = wrappedValue
        self.lock = .allocate(capacity: 1)
        self.lock.initialize(to: os_unfair_lock())
    }

    /// The synchronized value.
    ///
    /// Access to this value is automatically synchronized using an os_unfair_lock.
    public var wrappedValue: Value {
        get {
            os_unfair_lock_lock(lock)
            defer { os_unfair_lock_unlock(lock) }
            return value
        }
        set {
            os_unfair_lock_lock(lock)
            defer { os_unfair_lock_unlock(lock) }
            value = newValue
        }
    }

    deinit {
        lock.deinitialize(count: 1)
        lock.deallocate()
    }
}

// MARK: - Using Actor (Swift Concurrency)

/// A property wrapper that provides thread-safe access using Swift actors.
///
/// `SynchronizedActor` integrates with Swift's structured concurrency system using actors.
@propertyWrapper
public struct SynchronizedActor<Value: Sendable>: Sendable {
    /// The actor that provides synchronized storage for the value.
    public actor Storage: Sendable {
        public var value: Value

        /// Creates a new storage with the given initial value.
        /// - Parameter value: The initial value to store.
        public init(value: Value) {
            self.value = value
        }

        /// Gets the current value.
        /// - Returns: The stored value.
        public func get() -> Value {
            value
        }

        /// Sets a new value.
        /// - Parameter newValue: The new value to store.
        public func set(_ newValue: Value) {
            value = newValue
        }
    }

    private let storage: Storage

    /// Creates a new synchronized value.
    /// - Parameter wrappedValue: The initial value to store.
    public init(wrappedValue: Value) {
        storage = Storage(value: wrappedValue)
    }

    /// The synchronized value.
    ///
    /// Direct access to this value will result in a fatal error. Use the async methods instead.
    public var wrappedValue: Value {
        fatalError(
            """
            SynchronizedActor property wrapper requires async access.
            Instead of direct access, use:
                await $propertyName.get()
                await $propertyName.set(newValue)
            """
        )
    }

    /// The projected value provides access to the underlying actor storage.
    public var projectedValue: Storage {
        storage
    }

    /// Gets the current value asynchronously.
    /// - Returns: The stored value.
    public func get() async -> Value {
        await storage.get()
    }

    /// Sets a new value asynchronously.
    /// - Parameter newValue: The new value to store.
    public func set(_ newValue: Value) async {
        await storage.set(newValue)
    }
}
