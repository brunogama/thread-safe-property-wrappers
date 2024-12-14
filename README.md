# Thread-Safe Property Wrappers in Swift

A collection of property wrappers that provide thread-safe access to values using different synchronization mechanisms.

## Overview

These property wrappers allow you to manage thread-safe access to values in a concurrent environment with various synchronization options. Each wrapper provides a unique trade-off between performance and functionality.

### Available Property Wrappers

1. `SynchronizedNSLock`
   - Uses `NSLock` for general-purpose synchronization.
   - Good performance for most use cases.

2. `SynchronizedQueue`
   - Synchronizes access using a serial `DispatchQueue`.
   - Ideal for queue-based operations.

3. `SynchronizedUnfairLock`
   - High-performance synchronization with `os_unfair_lock`.
   - Best for simple and lightweight synchronization needs.

4. `SynchronizedActor`
   - Integrates with Swift's structured concurrency using `Actor`.
   - Provides modern async/await capabilities.

## Usage

Here's an example of how to use these property wrappers:

```swift
class MyClass {
    @SynchronizedNSLock private var counter = 0
    @SynchronizedQueue private var name = "Initial"
    @SynchronizedUnfairLock private var score = 100
    @SynchronizedActor private var status = "Active"
}

// Example usage
let myClass = MyClass()

// Accessing values
myClass.counter += 1
myClass.name = "Updated"
myClass.score += 50

// Using async methods for `SynchronizedActor`
Task {
    await myClass.$status.set("Inactive")
    let currentStatus = await myClass.$status.get()
    print(currentStatus)
}

## Choosing a Property Wrapper

Maximum performance: Use **SynchronizedUnfairLock**.

Queue-based operations: Use **SynchronizedQueue**.

Swift concurrency integration: Use **SynchronizedActor**.

General-purpose synchronization: Use **SynchronizedNSLock**.