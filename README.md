# Isolation a Thread-Safea collection of Property Wrappers

A collection of property wrappers that provide thread-safe access to values using different synchronization mechanisms.

## Overview

These property wrappers allow you to manage thread-safe access to values in a concurrent environment with various synchronization options. Each wrapper provides a unique trade-off between performance and functionality.

### Available Property Wrappers

1. `NSLockIsolated`
   - Uses `NSLock` for general-purpose synchronization.
   - Good performance for most use cases.
   - **Non-recursive** by default.
   
2. `LockIsolated`
    - Synchronizes access using a custom lock.
    - Provides more control over the synchronization mechanism.
    - Uses NSRecursiveLock by default.

3. `DispatchQueueIsolated`
   - Synchronizes access using a serial `DispatchQueue`.
   - Ideal for queue-based operations.

4. `UnfairLockIsolated`
   - High-performance synchronization with `os_unfair_lock`.
   - Best for simple and lightweight synchronization needs.
   - **Non-recursive**

## Usage

Here's an example of how to use these property wrappers:

```swift
class MyClass {
    @NSLockIsolated private var counter = 0
    @LockIsolated private var counter = 0
    @DispatchQueueIsolated private var name = "Initial"
    @UnfairLockIsolated private var score = 100
}

// Example usage
let myClass = MyClass()

// Accessing values
myClass.counter += 1
myClass.name = "Updated"
myClass.score += 50

## Choosing a Property Wrapper

Maximum performance: Use **UnfairLockIsolated**.

Queue-based operations: Use **DispatchQueueIsolated**.

General-purpose synchronization: Use **NSLockIsolated** or **LockIsolated**
