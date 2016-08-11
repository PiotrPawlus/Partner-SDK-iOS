//
//  BaseUITests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 7/15/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
import KIF
@testable import SpotHero_iOS_Partner_SDK_Example
@testable import SpotHero_iOS_Partner_SDK

class BaseUITests: KIFTestCase {
        
    override func beforeAll() {
        super.beforeAll()
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.LaunchSDK)
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.FindParking)
    }
    
    override func afterAll() {
        super.afterAll()
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.Close)
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.LaunchSDK)
    }
    
    func enterTextIntoSearchBar(text: String) {
        tester().enterText(text,
                           intoViewWithAccessibilityLabel: AccessibilityStrings.SearchBar,
                           traits: UIAccessibilityTraitNone,
                           expectedResult: text)
    }
    
}
