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

class FirebaseService {
    var database = Database.database()
    var reference = Database.database().reference()
    
    var dataList: [Data]
    
    init() {
        dataList = []
        reference.observe(DataEventType.childAdded) { (snapshot) in
            self.dataList.append(self.firebaseToData(snapshot))
            print("Got snapshot")
            print(self.dataList.count)
            self.getDataList(ids: [123])
        }
    }
    
    let testData = Data(coordinate: CLLocationCoordinate2DMake(0.0, 0.0), ph: 10, moisture: 18, temperature: 8, id: 37594395348, date: Date.init())
    
    func pushTestData(){
        pushDataObject(data: testData)
    }
    
    func pushDataObject(data: Data){
        reference.childByAutoId().setValue(data.asDictionary())
        //Incomplete Function
    }
    
    func firebaseToData(_ snapshot: DataSnapshot) -> Data {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dataDict = snapshot.value as? [String: AnyObject] ?? [:]
        
        let coordinate = CLLocationCoordinate2D.init(latitude: dataDict["Latitude"] as! CLLocationDegrees,longitude: dataDict["Longitude"] as! CLLocationDegrees)
        let date = formatter.date(from: dataDict["Date"] as! String)
        
        let temperature = dataDict["Temperature"] as! Int
        let ph = dataDict["PH"] as! Int
        let moisture = dataDict["Moisture"] as! Int
        let id = dataDict["ID"] as! Int
        
        
        return Data(coordinate: coordinate, ph: ph, moisture: moisture, temperature: temperature, id: id, date: date!)
    }
    
    func getDataList(ids: [Int]) -> [Data]? {
        print("Get DataList")
        //Incomplete Function
        let result = dataList
        print(result as Any)
        return result
    }
}
