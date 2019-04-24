//
//  firebase.swift
//  IOSProject
//
//  Created by dmu mac 08 on 24/04/2019.
//  Copyright © 2019 eaaa. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import CoreLocation

class Firebase {
    var reference = Database.database().reference()
    
    let testData = Data(coordinate: CLLocationCoordinate2DMake(0.0, 0.0), ph: 10, moisture: 18, temperature: 7.9, id: 37594395348)
    
    func pushDataObject(data: Data){
        //Incomplete Function
    }
    
    func getDataList(ids: [Int]) -> [Data] {
        //Incomplete Function
        return [testData]
    }
}
