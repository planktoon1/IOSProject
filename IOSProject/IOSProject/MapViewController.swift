//
//  ViewController.swift
//  IOSProject
//
//  Created by dmu mac 08 on 24/04/2019.
//  Copyright © 2019 eaaa. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit
import CoreLocation
import MapKit

class MyAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var data: Data?
    
    override init(){
        self.coordinate = CLLocationCoordinate2D()
        self.title = "nil"
        self.subtitle = "nil"
        self.data = nil
    }
}


class MapViewController: UIViewController, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    var dataToSend: Data?
    
    //Bluetooth:
    var locationData: CLLocationCoordinate2D?
    var centralManager: CBCentralManager?
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    
    var buffer: String = ""
    
    @IBAction func DateChanged(_ sender: UIDatePicker) {
        //Remove all annotations
        mapView.removeAnnotations(mapView.annotations)
        //Get new readings based on the date
        getReadings()
    }
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            mapView.delegate = self
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseService.getInstance().mapController = self
        getReadings()
        
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let tempAnno = view.annotation as? MyAnnotation
        if let tempoAnnotation = tempAnno as? MyAnnotation{
            dataToSend = tempoAnnotation.data
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MyAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
            
            let rightButton = UIButton(type: UIButton.ButtonType.detailDisclosure)
            
            annotationView!.rightCalloutAccessoryView = rightButton
            
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegue(withIdentifier: "readingDetails", sender: view)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "readingDetails" )
        {
            let destination = segue.destination as! DetailViewController
            destination.data = dataToSend //Data we wanna pass
        }
    }
    
    
    func getReadings(){
        //Get Data from firebase.
        if let data = FirebaseService.getInstance().getDataLists() {
            for reading in data{
                //Check if the date is equal to the date chosen.
                if removeTimeStamp(fromDate: reading.date) == removeTimeStamp(fromDate: datePicker.date){
                    //Make the coord
                    let coordinate = reading.coordinate
                    
                    //Sets region if its the last data
                    
                    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 50000, longitudinalMeters: 50000)
                    mapView.setRegion(region, animated: true)
                    
                    //Make annotation with description
                    let annotation = MyAnnotation()
                    annotation.title = reading.date.description
                    annotation.subtitle = "PH: \(reading.ph) Moist: \(reading.moisture) Temp: \(reading.soilTemp) Humid: \(reading.humidity)"
                    annotation.coordinate = coordinate
                    let data = Data(latitude: Float(reading.coordinate.latitude), longitude: Float(reading.coordinate.longitude), airTemp: reading.airTemp, soilTemp: reading.soilTemp, ph: reading.ph, humidity: reading.humidity, moisture: reading.moisture, EC: reading.EC, date: reading.date)
                    annotation.data = data
                    
                    mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    func removeTimeStamp(fromDate: Date) -> Date{
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: fromDate))else{
            fatalError("Failed to strip time to from Date object")
        }
        return date
    }
    
    func showPopup(msg: String){
        let popup = UIAlertController(title: "Bluetooth status", message: msg, preferredStyle: .alert)
        popup.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(popup, animated: true)
    }
    
    func finishedCollectingData(data: String){
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
            //self.showPopup(msg: "Uploadede nyt datapunkt til databasen")
            
        }
    }
    
}


extension Float {
    init(_ value: String){
        self = (value as NSString).floatValue
    }
}

extension MapViewController: CLLocationManagerDelegate {
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

extension MapViewController: CBCentralManagerDelegate {
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

extension MapViewController: CBPeripheralDelegate {
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
