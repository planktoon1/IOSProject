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

class BluetoothConnection: ViewController {
    
    var firebaseService = FirebaseService()
    var centralManager: CBCentralManager?
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    
    override func viewDidLoad() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
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
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // TODO: Send warning at der blev disconnected fra enhed
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
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Ændres til at passe med den data vi får fra dimsen
        let data = String(bytes: characteristic.value!, encoding: String.Encoding.utf8)
        if let data = data?.components(separatedBy: ":") {
            if data.count > 3 {
                // TODO: Opret data og gem i firebase
                let id = data[0]
                let moist = data[1]
                let ph = data[2]
                let temp = data[3]
                
                //let testData = Data(coordinate: CLLocationCoordinate2DMake(0.0, 0.0), ph: ph, moisture: moist, temperature: temp, id: id, date: Date.init())
                //firebaseService.pushDataObject(data: testData)
            }
        }
    }
}
