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
    var ph: Int
    var moisture: Int
    var temperature: Int
    var id: Int
    var date: Date
    
    init(coordinate: CLLocationCoordinate2D, ph: Int, moisture: Int, temperature: Int, id: Int, date: Date) {
        self.coordinate = coordinate //Fås fra telefonen
        self.ph = ph //Fås fra sensor
        self.moisture = moisture //Fås fra sensor
        self.temperature = temperature //Fås fra sensor
        self.id = id //Fås fra sensor
        self.date = date
    }
    
    func asDictionary() -> NSDictionary{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let result = [
            "Latitude" : self.coordinate.latitude,
            "Longitude" : self.coordinate.longitude,
            "PH" : self.ph,
            "Moisture" : self.moisture,
            "Temperature" : self.temperature,
            "ID" : self.id,
            "Date" : formatter.string(from: self.date)
            ] as NSDictionary
        return result
    }
    
}
