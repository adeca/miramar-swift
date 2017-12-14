//
//  SignalSource.swift
//  Miramar
//
//  Created by Agustín de Cabrera on 5/12/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

public class SignalSource<T>: Signal<T> {
    //MARK: Public methods
    
    /// Send an update to all subscribers of this object, with the
    /// given value as a parameter.
    public override func send(_ value: @autoclosure () -> T) {
        super.send(value)
    }
}

extension SignalSource where T == Void {
    public func send() {
        send(())
    }
}
