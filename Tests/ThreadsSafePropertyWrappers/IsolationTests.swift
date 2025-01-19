import Foundation
import Testing

@testable import Isolation

@Suite("NSLock isolation")
struct NSLock_isolation_Tests {

    @Test("Basic Usage")
    func simpleAccess() {
        let initialValue = Int.random(in: 0...1_000)
        let mutationValue = Int.random(in: 0...1_000)
        let iterationsTotal = Int.random(in: 0...1_000 )

        @NSLockIsolated var sut: Int = initialValue

        #expect(sut == initialValue)

        sut = mutationValue

        #expect(sut == mutationValue)
        
        sut = 0
        
        #expect(sut == 0)
        
        for _ in (0...iterationsTotal) {
            sut += 1
        }
        
        #expect(sut == iterationsTotal + 1)
    }

    @Test
    func concurrentSetting() async {
        var consumer = Consumer()
        let iterations = 1000
        
        await withTaskGroup(of: Void.self) { taskGroup in
            for _ in 1...iterations {
                taskGroup.addTask {
                    consumer.increment()
                }
                
            }
        }
    }
}

private struct Consumer {
    @NSLockIsolated var value: Int = 0
    
    mutating func increment() {
        value += 1
    }
}
