//
//  Data.swift
//  IOSProject
//
//  Created by dmu mac 08 on 24/04/2019.
//  Copyright © 2019 eaaa. All rights reserved.
//

import Foundation
import CoreLocation

class Data {
    var coordinate: CLLocationCoordinate2D
    var airTemp: Float
    var soilTemp: Float
    var ph: Float
    var humidity: Float
    var moisture: Float
    var EC: Float
    var id: Int
    var date: Date
    
    init(latitude: Float, longtitude: Float, airTemp: Float, soilTemp: Float, ph: Float, humidity: Float, moisture: Float, EC: Float) {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude) //Fås fra telefonen
        self.airTemp = airTemp //Fås fra sensor
        self.soilTemp = soilTemp //Fås fra sensor
        self.ph = ph //Fås fra sensor
        self.humidity = humidity //Fås fra sensor
        self.moisture = moisture //Fås fra sensor
        self.EC = EC //Fås fra sensor
        self.id = id
        self.date = Date.init()
    }
    
    func asDictionary() -> NSDictionary{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let result = [
            "Latitude" : self.coordinate.latitude,
            "Longitude" : self.coordinate.longitude,
            "airTemp" : self.airTemp,
            "soilTemp" : self.soilTemp,
            "PH" : self.ph,
            "Humidity" : self.humidity,
            "Moisture" : self.moisture,
            "EC" : self.EC,
            "ID" : self.id,
            "Date" : formatter.string(from: self.date)
            ] as NSDictionary
        return result
    }
    
}
