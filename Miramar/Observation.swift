//
//  Observation.swift
//  Miramar
//
//  Created by Agustín de Cabrera on 28/11/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

/// An Observation is created when someone subscribes to receive updates
/// from an Observable object.
///
/// Observation instances grant the ability to stop receiving these updates.
/// Once canceled an Observation can't be restored and a new one should be created.
///
public final class Observation {
    private var target: Any?
    private var removalBlock: (() -> Void)?
    
    init(target: Any? = nil, remove: @escaping () -> Void) {
        self.target = target
        self.removalBlock = remove
    }
    
    init(target: Any? = nil) {
        self.target = target
    }
    
    public func remove() {
        removalBlock?()
        removalBlock = nil
        target = nil
    }
}

extension Observation {
    /// Convenience method to create a Disposable object that will
    /// cancel the Observation during it's deallocation.
    public var disposable: Disposable {
        return Disposable { self.remove() }
    }
}
