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
    
    private static var instance: FirebaseService?
    
    private init() {
        dataList = []
        reference.observe(DataEventType.childAdded) { (snapshot) in
            self.dataList.append(self.firebaseToData(snapshot))
        }
    }
    
    static func getInstance() -> FirebaseService {
        if let instance = instance {
            return instance
        }else {
            instance = FirebaseService()
            return instance!
        }
    }
    
    let testData = Data(coordinate: CLLocationCoordinate2DMake(0.0, 0.0), ph: 10, moisture: 18, humidity: 25, temperature: 8, id: 3348, date: Date.init())

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
        let result = dataList
        print(result as Any)
        return result
    }
}
