//
//  Config.swift
//  Pods
//
//  Created by SpotHeroMatt on 10/4/16.
//
//

import Foundation

class Config {
    static let sharedInstance = Config()
    
    var googleApiKey = ""
    var stripeApiKey = ""
    var mixpanelApiKey = ""
    
    typealias APIKeyCompletion = (Bool) -> ()
    func getKeys(completion: APIKeyCompletion) {
        let endpoint = "api/v1/mobile-config/iossdk/"
        let headers = APIHeaders.defaultHeaders()
        SpotHeroPartnerAPIController.getJSONFromEndpoint(endpoint,
                                                         withHeaders: headers,
                                                         errorCompletion: {
                                                            error in
                                                            assertionFailure("Cannot get json, error \(error)")
                                                            completion(false)
            }) {
                JSON in
                do {
                    let data = try JSON.shp_dictionary("data") as JSONDictionary
                    self.googleApiKey = try data.shp_string("google_places_api_key")
                    self.stripeApiKey = try data.shp_string("stripe_public_api_key")
                    self.mixpanelApiKey = try data.shp_string("mixpanel_api_key")
                    completion(true)
                } catch let error {
                    assertionFailure("Cannot parse json, error \(error)")
                    completion(false)
                }
        }
    }
}
