//
//  AnyObservable.swift
//  Miramar
//
//  Created by Agustín de Cabrera on 6/12/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

public protocol AnyObservable {
    ///
    @discardableResult
    func observeChange(_ handler: @escaping () -> Void) -> Observation
}
