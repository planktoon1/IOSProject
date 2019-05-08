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
    var mapController : MapViewController?
    
    var dataList: [Data]
    
    private static var instance: FirebaseService?
    
    
    private init() {
        dataList = []
        /*
        reference = Database.database().reference().child("x")
       reference.observe(.childAdded, with: { (snapshot) in
            print(snapshot)
        })
         */
        
        reference.observe(DataEventType.childAdded) { (snapshot) in
            self.dataList.append(self.firebaseToData(snapshot))
            self.updateDataList()
        }
    }
    
    func updateDataList(){
        mapController?.getReadings()
    }
 
    static func getInstance() -> FirebaseService {
        if let instance = instance {
            return instance
        }else {
            instance = FirebaseService()
            return instance!
        }
    }
    let testData = Data(latitude: 56.124572, longitude: 10.157000, airTemp: 22.1, soilTemp: 15.0, ph: 5.1, humidity: 73.7, moisture: 51.2, EC: 1.002, date: Date.init())

    func pushTestData(){
        pushDataObject(data: testData)
    }
    
    func pushDataObject(data: Data){
        reference.childByAutoId().setValue(data.asDictionary())
        let user = UserDefaults()
        if var idList = user.array(forKey: "IdList") as? [Int]{
            if !idList.contains(data.id){
                idList.append(data.id)
                user.set(idList, forKey: "IdList")
            }
            print(idList)
        }else{
            user.set([data.id], forKey: "IdList")
            print("Test")
        }
        //Incomplete Function
    }
    
    func firebaseToData(_ snapshot: DataSnapshot) -> Data {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dataDict = snapshot.value as? [String: AnyObject] ?? [:]
        
        //let coordinate = CLLocationCoordinate2D.init(latitude: dataDict["Latitude"] as! CLLocationDegrees,longitude: dataDict["Longitude"] as! CLLocationDegrees)
        let lat = dataDict["Latitude"] as! Float
        let long = dataDict["Longitude"] as! Float
        let airTemp = dataDict["airTemp"] as! Float
        let soilTemp = dataDict["soilTemp"] as! Float
        let ph = dataDict["PH"] as! Float
        let humidity = dataDict["Humidity"] as! Float
        let moisture = dataDict["Moisture"] as! Float
        let ec = dataDict["EC"] as! Float
        let tempDate = dataDict["Date"] as! String
        let date = formatter.date(from: tempDate) as! Date
        
        
        return Data(latitude: lat, longitude: long, airTemp: airTemp, soilTemp: soilTemp, ph: ph, humidity: humidity, moisture: moisture, EC: ec, date: date)
    }
    
    func getDataLists() -> [Data]? {
        return dataList
    }
    
    func getDataList(ids: [Int]) -> [Data]? {
        print("Get DataList")
        let result = dataList
        print(result as Any)
        return result
    }
}
