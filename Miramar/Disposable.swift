//
//  Disposable.swift
//  Miramar
//
//  Created by Agustín de Cabrera on 28/11/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

/// Instances of this class will execute a block of code when they are deallocated.
public final class Disposable {
    /// The block that will be called during deallocation.
    private let dispose: () -> Void
    
    /// Creates a new instance that will execute the given block when it is deallocated.
    public init(_ dispose: @escaping () -> Void) {
        self.dispose = dispose
    }
    
    deinit {
        dispose()
    }
}

extension Disposable {
    /// All elements in the array will be removed during this object's deallocation.
    public convenience init<T>(_ values: [T]) {
        var copy = values
        self.init {
            copy.removeAll()
        }
    }
    
    /// Combine the current object and the given disposable into a new Disposable
    /// that will retain both until it's deallocated.
    public func combine(_ other: Disposable?) -> Disposable {
        guard let other = other else { return self }
        
        return Disposable([self, other])
    }
    
    /// Attach the disposable to a target object, which causes it to remain
    /// alive until the target is deallocated.
    func on(_ target: AnyObject) {
        objc_setAssociatedObject(target, &DisposableTargetKey, self, .OBJC_ASSOCIATION_RETAIN)
    }
}

private var DisposableTargetKey: UInt8 = 0

public func + (lhs: Disposable, rhs: Disposable) -> Disposable {
    return lhs.combine(rhs)
}
public func += (lhs: inout Disposable, rhs: Disposable) {
    lhs = lhs + rhs
}

public func + (lhs: Disposable?, rhs: Disposable) -> Disposable {
    return lhs?.combine(rhs) ?? rhs
}
public func += (lhs: inout Disposable?, rhs: Disposable) {
    lhs = lhs + rhs
}

