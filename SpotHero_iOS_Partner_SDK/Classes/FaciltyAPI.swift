//
//  FaciltyAPI.swift
//  Pods
//
//  Created by Matthew Reed on 7/20/16.
//
//

import Foundation
import CoreLocation

enum FacilityError: ErrorType {
    case NoFacilitiesFound
}

struct FacilityAPI {
    
    /**
     Returns the facilities near a given location within a range of dates
     
     - parameter location:   location to find facilities near
     - parameter starts:     when the reservation shold start
     - parameter ends:       when the reservation should end
     - parameter completion: closure to call after network call is made. passes in an array of facilities or an error
     */
    static func fetchFacilities(coordinate: CLLocationCoordinate2D,
                                starts: NSDate,
                                ends: NSDate,
                                completion: ([Facility], ErrorType?) -> (Void)) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let startsString = DateFormatter.ISO8601NoSeconds.stringFromDate(starts)
        let endsString = DateFormatter.ISO8601NoSeconds.stringFromDate(ends)
        
        let latitude = "\(coordinate.latitude)"
        let longitude = "\(coordinate.longitude)"
        
        let headers = APIHeaders.defaultHeaders()
        let params = [
            "longitude" : longitude,
            "latitude" : latitude,
            "starts" : startsString,
            "ends" : endsString,
            "include" : "facility"
        ]
        
        SpotHeroPartnerAPIController.getJSONFromEndpoint("partner/v1/facilities/rates",
                                                         withHeaders: headers,
                                                         additionalParams: params,
                                                         errorCompletion: {
                                                            error in
                                                            completion([], error)
        }) {
            JSON in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            do {
                let results = try JSON.shp_array("results") as [JSONDictionary]
                var facilities = [Facility]()
                for result in results {
                    let facility = try Facility(json: result)
                    facilities.append(facility)
                }
                
                let facilitiesWithRates = facilities.filter { !$0.availableRates.isEmpty }
                
                if !facilitiesWithRates.isEmpty {
                    completion(facilitiesWithRates, nil)
                } else {
                    completion([], FacilityError.NoFacilitiesFound)
                }
            } catch let error {
                completion([], error)
            }
        }
    }
}
