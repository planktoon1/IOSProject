//
//  ViewController.swift
//  IOSProject
//
//  Created by dmu mac 08 on 24/04/2019.
//  Copyright © 2019 eaaa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class UserAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

class MapViewController: UIViewController {

    let locationManager = CLLocationManager()
    
    @IBAction func DateChanged(_ sender: UIDatePicker) {
        //Remove all annotations
        mapView.removeAnnotations(mapView.annotations)
        //Get new readings based on the date
        getReadings()
    }
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getReadings()
        
    }
    
    
    func getReadings(){
        //Get Data from firebase.
        /*
        if let data = Data.getData(){
            for reading in data{
                //Check if the date is equal to the date chosen.
                if data.date == datePicker.date{
                    //Latitude and longitude for the coord.
                    let lat = Double(data.coordinates.lat) //Needs data
                    let long = Double(data.coordinates.long) //Needs data
                    if let lat = lat, let long = long{
                        //Make the coord
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                        //Sets region if its the last data
                        if reading == data[data.length]{
                            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 50000, longitudinalMeters: 50000)
                            mapView.setRegion(region, animated: true)
                        }
                        //Make annotation with description
                        let userAnnotation =  UserAnnotation(coordinate: coordinate, title: data.date, subtitle: "ID: \(data.id) PH: \(data.ph) Moist: \(data.moisture) Temp: \(data.temperature)")
                        mapView.addAnnotation(userAnnotation)
                    }
                }
            }
        }
    */
    }

}

extension MapViewController : CLLocationManagerDelegate{
    
}
