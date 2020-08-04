import UIKit

public extension UnsafeMutableRawPointer {
    func assign<T>(_ to: T.Type) -> T {
        return assumingMemoryBound(to: to).pointee
    }
}
