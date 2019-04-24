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
    var coordinate: CLLocationCoordinate2D?
    var ph: Int?
    var moisture: Int?
    var temperature: Decimal?
    var id: Int?
    var date: Date?
    
    init(coordinate: CLLocationCoordinate2D, ph: Int, moisture: Int, temperature: Decimal, id: Int) {
        self.coordinate = coordinate //Fås fra telefonen
        self.ph = ph //Fås fra sensor
        self.moisture = moisture //Fås fra sensor
        self.temperature = temperature //Fås fra sensor
        self.id = id //Fås fra sensor
        self.date = Date.init()
    }
    
}
