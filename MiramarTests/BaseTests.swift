//
//  BaseTests.swift
//  MiramarTests
//
//  Created by Agustín de Cabrera on 28/11/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

import XCTest

internal var currentTestCase: XCTestCase?

class BaseTestCase: XCTestCase {
    override func setUp() {
        currentTestCase = self
        super.setUp()
    }
}

