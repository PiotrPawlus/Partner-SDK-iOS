//
//  GooglePlacesUITests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 7/15/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
import KIF
@testable import SpotHero_iOS_Partner_SDK_Example
@testable import SpotHero_iOS_Partner_SDK

class GooglePlacesUITests: BaseUITests {
    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    func typeInAddress() {
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.SearchBar)
        tester().enterText("325 W Huron", intoViewWithAccessibilityLabel: AccessibilityStrings.SearchBar)
    }
    
    func testGetPredictions() {
        //GIVEN: I see the search bar and type in an address
        self.typeInAddress()
        
        //THEN: I see a table with predictions
        guard let tableView = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.PredictionTableView) as? UITableView else {
            XCTFail("No Prediction table view")
            return
        }
        
        guard let cell = tester().waitForCellAtIndexPath(indexPath, inTableView: tableView) as? PredictionTableViewCell else {
            XCTFail("No Cells in table view")
            return
        }
        
        //THEN: The cell has an address in it
        XCTAssertEqual(cell.addressLabel.text, "325")
        XCTAssertEqual(cell.cityLabel.text, "W Huron St, Chicago, IL")
    }
    
    func testTapAPlace() {
        //GIVEN: I see the search bar and type in an address
        self.typeInAddress()
        
        //WHEN: I see a table with predictions and tap a row
        guard let tableView = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.PredictionTableView) as? UITableView else {
            XCTFail("No Prediction table view")
            return
        }
        
        tester().tapRowAtIndexPath(indexPath, inTableView: tableView)
        
        //THEN: The tableview collapses
        XCTAssertEqual(tableView.frame.height, 0)
        
        //THEN: The search bar has the address in it
        guard let searchBar = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.SearchBar) as? UISearchBar else {
            XCTFail("Search bar is noty visible")
            return
        }
        
        tester().expectView(searchBar, toContainText: "325 W Huron St, Chicago, IL, United States")
        
        //TODO: Search for place
    }
}
