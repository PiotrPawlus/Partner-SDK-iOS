//
//  CheckoutUITests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 10/20/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

import XCTest
import KIF
@testable import SpotHero_iOS_Partner_SDK_Example
@testable import SpotHero_iOS_Partner_SDK

class CheckoutUITests: BaseUITests {
    let emailIndexPath = NSIndexPath(forRow: PersonalInfoRow.Email.row(true), inSection: CheckoutSection.PersonalInfo.rawValue)
    let phoneNumberIndexPath = NSIndexPath(forRow: PersonalInfoRow.Phone.row(true), inSection: CheckoutSection.PersonalInfo.rawValue)
    let licenseIndexPath = NSIndexPath(forRow: PersonalInfoRow.License.row(true), inSection: CheckoutSection.PersonalInfo.rawValue)
    let firstIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    let enteredText = "Chicago"
    let expectedText = "Chicago, IL, United States"
    let visaCreditCard = "4242424242424242"
    let visaCVC = "123"
    let amExCreditCard = "345631899386110"
    let amExCVC = "1234"
    let testEmail = "matt@test.com"
    let testExpiration = "1020"
    
    //MARK: - Helper Methods
    
    private func enterTextInFields(email: String,
                                   creditCardNumber: String,
                                   expiration: String? = nil,
                                   cvc: String? = nil,
                                   expectedCreditCard: String? = nil) {
        
        let lastFour = creditCardNumber.substringWithRange(creditCardNumber.endIndex.advancedBy(-4)..<creditCardNumber.endIndex)
        let expectedCC = expectedCreditCard ?? lastFour
        
        tester().enterText(email, intoViewWithAccessibilityLabel: AccessibilityStrings.EmailTextField)
        tester().enterText(creditCardNumber,
                           intoViewWithAccessibilityLabel: AccessibilityStrings.CreditCardTextField,
                           traits: UIAccessibilityTraitNone,
                           expectedResult: expectedCC)
        if let expiration = expiration {
            var expectedExpiration = expiration
            expectedExpiration.insert("/", atIndex: expectedExpiration.startIndex.advancedBy(2))
            tester().enterText(expiration,
                               intoViewWithAccessibilityLabel: AccessibilityStrings.ExpirationTextField,
                               traits: UIAccessibilityTraitNone,
                               expectedResult: expectedExpiration)

        }
        
        if let cvc = cvc {
            tester().enterText(cvc, intoViewWithAccessibilityLabel: AccessibilityStrings.CVCTextField)
        }
    }
    
    private func purchaseSpot(creditCardNumber: String, cvc: String) {
        self.enterTextInFields(self.testEmail,
                               creditCardNumber: creditCardNumber,
                               expiration: self.testExpiration,
                               cvc: cvc)
        
        guard let button = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.PaymentButton) as? UIButton else {
            XCTFail("Cannot get payment button")
            return
        }
        
        XCTAssert(button.enabled)
        
        tester().tapViewWithAccessibilityLabel(AccessibilityStrings.PaymentButton)
        
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.ConfirmationScreen)
    }
        
    private func goToCheckoutScreen(searchBarText: String? = nil) {
        // Enter text into search bar and press return
        self.enterTextIntoSearchBar(searchBarText ?? self.enteredText, expectedText: searchBarText ?? self.enteredText)
        
        guard let predictionTableView = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.PredictionTableView) as? UITableView else {
            XCTFail("Cannot get predictions")
            return
        }
        
        tester().tapRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), inTableView: predictionTableView)
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.SearchSpots)
        
        // Get collection view and tap book it button
        guard
            let collectionView = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.SpotCards) as? UICollectionView else {
                XCTFail("Cannot get spot cards collection view")
                return
        }
        
        tester().waitForCellAtIndexPath(firstIndexPath, inCollectionView: collectionView)
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.BookIt)
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.CheckoutScreen)
    }
    
    private func verifyPaymentButtonDisabled(file: StaticString = #file, line: UInt = #line) {
        guard let paymentButton = tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.PaymentButton) as? UIButton else {
            XCTFail("Cannot get payment button")
            return
        }
        
        XCTAssertFalse(paymentButton.enabled, file: file, line: line)
    }
    
    //MARK: - Test Lifecycle
    
    override func tearDown() {
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.Close)
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.LaunchSDK)
        super.tearDown()
    }
    
    //MARK: - Test Methods
    
    func testBuySpot() {
        //GIVEN: I see the Checkout Table View
        self.goToCheckoutScreen()
        //WHEN: I enter an email, credit card number, expiration number and cvc
        //THEN: I see the confirmation screen
        self.purchaseSpot(self.visaCreditCard, cvc: self.visaCVC)
    }
    
    func testBuySpotAmEx() {
        //GIVEN: I see the Checkout Table View
        self.goToCheckoutScreen()
        //WHEN: I enter an email, american express credit card number, expiration number and cvc
        //THEN: I should see the confirmation screen
        self.purchaseSpot(self.amExCreditCard, cvc: self.amExCVC)
    }
    
    func testBookAnotherButton() {
        //GIVEN: I see the confimation screen
        self.goToCheckoutScreen()
        self.purchaseSpot(self.visaCreditCard, cvc: self.visaCVC)
        
        //WHEN: I tap the Book Another button
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.BookAnother)
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.BookAnother)
        
        //THEN: I should see the Map View
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.MapView)
    }
    
    func testDoneButton() {
        //GIVEN: I see the confimation screen
        self.goToCheckoutScreen()
        self.purchaseSpot(self.visaCreditCard, cvc: self.visaCVC)
        
        //WHEN: I tap the Book Another button
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.Done)
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.Done)
        
        //THEN: The view should dismiss
        tester().waitForViewWithAccessibilityLabel(LocalizedStrings.LaunchSDK)
        
        // Relaunch SDK
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.LaunchSDK)
    }
    
    func testInvalidEmail() {
        //GIVEN: I see the checkout screen
        self.goToCheckoutScreen()
        //WHEN: I enter an invalid email and valid credit card, experiration date and cvc
        self.enterTextInFields("matt@test",
                               creditCardNumber: self.visaCreditCard,
                               expiration: self.testExpiration,
                               cvc: self.visaCVC)
        
        //THEN: The payment button should be disabled
        self.verifyPaymentButtonDisabled()
    }
    
    func testInvalidCreditCardNumber() {
        //GIVEN: I see the checkout screen
        self.goToCheckoutScreen()
        //WHEN: I enter an invalid credit card number
        self.enterTextInFields(self.testEmail,
                               creditCardNumber: "1234567812345678",
                               expectedCreditCard: "1234 5678 1234 5678")
        
        //THEN: The payment button should be disabled
        self.verifyPaymentButtonDisabled()
    }
    
    func testInvalidExpiration() {
        //GIVEN: I see the checkout screen
        self.goToCheckoutScreen()
        //WHEN: I enter an invalid expiration date
        self.enterTextInFields(self.testEmail,
                               creditCardNumber: self.visaCreditCard,
                               expiration: "1013",
                               cvc: self.visaCVC)
        
        //THEN: The payment button should be disabled
        self.verifyPaymentButtonDisabled()
    }
    
    func testEmptyCreditCard() {
        //GIVEN: I see the checkout screen
        self.goToCheckoutScreen()
        //WHEN: I fill out all the fields except the credit card fields
        tester().enterText(self.testEmail, intoViewWithAccessibilityLabel: AccessibilityStrings.EmailTextField)
        
        //THEN: The payment button should be disabled
        self.verifyPaymentButtonDisabled()
    }
    
    func testEmptyExpirationDate() {
        //GIVEN: I see the checkout screen
        self.goToCheckoutScreen()
        //WHEN: I fill out all the fields except the expiration date
        self.enterTextInFields(self.testEmail,
                               creditCardNumber: self.visaCreditCard,
                               expiration: nil,
                               cvc: self.visaCVC)
        //THEN: The payment button should be disabled
        self.verifyPaymentButtonDisabled()
    }
    
    func testEmptyCVC() {
        //GIVEN: I see the checkout screen
        self.goToCheckoutScreen()
        //WHEN: I fill out all the fields except the cvc
        self.enterTextInFields(self.testEmail,
                               creditCardNumber: self.visaCreditCard,
                               expiration: self.testExpiration,
                               cvc: nil)
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.Done)
        //THEN: The payment button should be disabled
        self.verifyPaymentButtonDisabled()
    }
    
    func testEmptyExpirationDateAndCVC() {
        //GIVEN: I see the checkout screen
        self.goToCheckoutScreen()
        //WHEN: I fill out all the fields except the expiration date and cvc
        self.enterTextInFields(self.testEmail, creditCardNumber: self.visaCreditCard)
        tester().tapViewWithAccessibilityLabel(LocalizedStrings.Done)
        //THEN: The payment button should be disabled
        self.verifyPaymentButtonDisabled()
    }
    
    func testEmailOnlyCheckout() {
        //GIVEN: I select a spot that only required an email address
        //WHEN: I see the checkout screen
        self.goToCheckoutScreen("318 South Federal")
        //THEN: I should only see the email field
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.EmailTextField)
        tester().waitForAbsenceOfViewWithAccessibilityLabel(AccessibilityStrings.PhoneTextField)
        tester().waitForAbsenceOfViewWithAccessibilityLabel(AccessibilityStrings.LicenseTextField)
    }
    
    func testEmailandPhoneOnlyCheckout() {
        //GIVEN: I select a spot that only required an email address
        //WHEN: I see the checkout screen
        self.goToCheckoutScreen("100 West Monroe")
        //THEN: I should only see the email and phone fields
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.EmailTextField)
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.PhoneTextField)
        tester().waitForAbsenceOfViewWithAccessibilityLabel(AccessibilityStrings.LicenseTextField)
    }
    
    func testEmailAndLicenseOnlyCheckout() {
        //GIVEN: I select a spot that only required an email address
        //WHEN: I see the checkout screen
        self.goToCheckoutScreen("328 South Wabash")
        //THEN: I should only see the email and license fields
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.EmailTextField)
        tester().waitForAbsenceOfViewWithAccessibilityLabel(AccessibilityStrings.PhoneTextField)
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.LicenseTextField)
    }
    
    func testEmailPhoneAndLicenseCheckout() {
        //GIVEN: I select a spot that only required an email address
        //WHEN: I see the checkout screen
        self.goToCheckoutScreen("525 South Wabash")
        //THEN: I should see the email, phone and license fields
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.EmailTextField)
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.PhoneTextField)
        tester().waitForViewWithAccessibilityLabel(AccessibilityStrings.LicenseTextField)
    }
}
