//
//  Signal.swift
//  Miramar
//
//  Created by Agustin De Cabrera on 5/12/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

public class Signal<T>: Stream<T> {
    //MARK: Public methods
    
    /// Send an update to all subscribers of this object, with the
    /// given value as a parameter.
    public override func notify(_ value: T) {
        super.notify(value)
    }
}
