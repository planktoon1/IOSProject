//
//  Bluetooth.swift
//  IOSProject
//
//  Created by dmu mac 07 on 24/04/2019.
//  Copyright © 2019 eaaa. All rights reserved.
//
/*
import Foundation
import CoreBluetooth
import UIKit
import CoreLocation
import MapKit
import CoreLocation

extension Float {
    init(_ value: String){
        self = (value as NSString).floatValue
    }
}

class BluetoothConnection: UIViewController {
    
    var firebaseService = FirebaseService.getInstance()
    let locationManager = CLLocationManager()
    var locationData: CLLocationCoordinate2D?
    var centralManager: CBCentralManager?
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    
    var buffer: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // ****** GPS *******
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    private func showPopup(msg: String){
        let popup = UIAlertController(title: "Bluetooth status", message: msg, preferredStyle: .alert)
        popup.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(popup, animated: true)
    }
    
    private func finishedCollectingData(data: String){
        print(data)
        
        if let dataAsArray = data.components(separatedBy: ",") as? [String] {
            let lat: Float = Float(locationData?.latitude ?? 0)
            let long: Float = Float(locationData?.longitude ?? 0)
            let airTemp: Float = Float(dataAsArray[2])
            let soilTemp: Float = Float(dataAsArray[3])
            let ph: Float = Float(dataAsArray[4])
            let humidity: Float = Float(dataAsArray[5])
            let moisture: Float = Float(dataAsArray[6])
            let EC: Float = Float(dataAsArray[7])
            
            let dataObject = Data(latitude: lat, longitude: long, airTemp: airTemp, soilTemp: soilTemp, ph: ph, humidity: humidity, moisture: moisture, EC: EC, date: Date.init())
            
            FirebaseService.getInstance().pushDataObject(data: dataObject)
            self.showPopup(msg: "Uploadede nyt datapunkt til databasen")

        }
    }
}
*/
