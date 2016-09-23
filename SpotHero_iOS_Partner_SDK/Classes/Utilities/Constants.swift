//
//  Constants.swift
//  Pods
//
//  Created by Husein Kareem on 7/13/16.
//
//

import Foundation
import CoreLocation

enum Constants {
    static let ChicagoLocation = CLLocation(latitude: 41.894503, longitude: -87.636659)
    static let ViewAnimationDuration: NSTimeInterval = 0.3
    static let ThirtyMinutesInSeconds: NSTimeInterval = 30 * 60
    static let SixHoursInSeconds: NSTimeInterval = 6 * UnitsOfMeasurement.SecondsInHour
    static let TestCreditCardNumber = "4242424242424242"
    static let TestExpirationMonth = "12"
    static let TestExpirationYear = "2020"
    static let TestCVC = "123"
    
    enum UnitsOfMeasurement {
        static let MetersPerMile = 1609.344
        static let SecondsInHour: NSTimeInterval = 60 * 60
    }
    
    enum Segue {
        static let Confirmation = "confirmation"
    }
}
