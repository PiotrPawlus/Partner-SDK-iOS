//
//  StripeWrapperTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 7/26/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest

@testable import SpotHero_iOS_Partner_SDK

class StripeWrapperTests: BaseTests {

    // TODO unskip this when we get a staging stripe token
    func skip_testGetToken() {
        let expectation = self.expectationWithDescription("testGetToken")
        
        StripeWrapper.getToken(Constants.TestCreditCardNumber,
                               expirationMonth: Constants.TestExpirationMonth,
                               expirationYear: Constants.TestExpirationYear,
                               cvc: Constants.TestCVC) {
                                token, error in
                                XCTAssertNil(error)
                                XCTAssertNotNil(token)
                                expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(60, handler: nil)
    }

}
