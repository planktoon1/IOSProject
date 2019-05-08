//
//  Bluetooth.swift
//  IOSProject
//
//  Created by dmu mac 07 on 24/04/2019.
//  Copyright © 2019 eaaa. All rights reserved.
//

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
        
        if let dataAsArray = data?.components(separatedBy: ",") {
            var lat: Float = Float(dataAsArray[0])
            var long: Float = Float(dataAsArray[1])
            var airTemp: Float = Float(dataAsArray[2])
            var soilTemp: Float = Float(dataAsArray[3])
            var ph: Float = Float(dataAsArray[4])
            var humidity: Float = Float(dataAsArray[5])
            var moisture: Float = Float(dataAsArray[6])
            var EC: Float = Float(dataAsArray[7])
            
            let dataObject = Data(latitude: locationData.latitude, longtitude: locationData.longtitude, airTemp: airTemp, soilTemp: soilTemp, ph: ph, humidity: humidity, moisture: moisture, EC: EC)
            
            FirebaseService.getInstance().pushDataObject(dataObject)
            self.showPopup(msg: "Uploadede nyt datapunkt til databasen")

        }
    }
}

extension BluetoothConnection: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.locationData = locValue;
        print("location = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            self.showPopup(msg: "Kunne ikke få adgang til gps")
        }
    }
}

extension BluetoothConnection: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard let centralManager = centralManager else {return}
        
        switch centralManager.state {
        case .poweredOn:
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            stopScanning(after: 5.0)
        default:
            break
        }
    }
    
    private func stopScanning(after seconds: Double) {
        weak var timer: Timer?
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: true) {
            [unowned self] _ in
            // Tjek om der er blevet fundet nogen enheder
            if let scanning = self.centralManager?.isScanning, scanning == true {
                self.centralManager?.stopScan()
                timer?.invalidate()
                
                // TODO: Send warning at der ikke blev fundet nogen enheder
                self.showPopup(msg: "Der blev ikke fundet nogen enhed")
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Vi har fundet en enhed -> prøv at connect
        if peripheral.name == "BLETest" {
            centralManager?.connect(peripheral, options: ["CBConnectPeripheralOptionNotifyOnNotificationKey" : true])
            self.peripheral = peripheral
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.peripheral?.delegate = self
        centralManager?.stopScan()
        self.peripheral?.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // TODO: Send warning at der ikke kunnes oprettes forbindelse til enhed
        self.showPopup(msg: "Fandt en enhed, men kunne ikke oprette forbindelse")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // TODO: Send warning at der blev disconnected fra enhed
        self.showPopup(msg: "Blev disconnected fra enheden")
    }
    
}

extension BluetoothConnection: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {return}
        
        for service in services {
            self.peripheral?.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {return}
        
        for characteristic in characteristics {
            self.peripheral?.readValue(for: characteristic)
            self.peripheral?.setNotifyValue(true, for: characteristic)
            // TODO: Håndter data
        }
    }
    
    var buffer: String = ""
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            // Ændres til at passe med den data vi får fra dimsen
        if let data = String(bytes: characteristic.value!, encoding: String.Encoding.utf8) {
            
            if data.last == "*" {
                buffer = buffer + data
                self.finishedCollectingData(data: buffer)
                buffer = ""
            } else {
                buffer = buffer + data
            }
        }
    }
    
}
