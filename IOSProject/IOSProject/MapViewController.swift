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


class MapViewController: UIViewController, MKMapViewDelegate {
    
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
            mapView.delegate = self
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseService.getInstance().mapController = self
        getReadings()
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
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
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "readingDetails" )
        {
            var destination = segue.destination as! DetailViewController
            //Send data to detailView (ID of chosen pin) or reference somewhere to get in the next viewcontroller
        }
    }
    
    
    func getReadings(){
        //Get Data from firebase.
        if let data = FirebaseService.getInstance().getDataLists() {
            for reading in data{
                //Check if the date is equal to the date chosen.
                if removeTimeStamp(fromDate: reading.date) == removeTimeStamp(fromDate: datePicker.date){
                    //Make the coord
                    
                    print("Test")
                    print(reading.date)
                    print(datePicker.date)
                    let coordinate = reading.coordinate
                    
                    //Sets region if its the last data
                    
                    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 50000, longitudinalMeters: 50000)
                    mapView.setRegion(region, animated: true)
                    
                    //Make annotation with description
                    let annotation = MKPointAnnotation()
                    annotation.title = reading.date.description
                    annotation.subtitle = "PH: \(reading.ph) Moist: \(reading.moisture) Temp: \(reading.soilTemp) Humid: \(reading.humidity)"
                    annotation.coordinate = coordinate
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
    
}



extension MapViewController : CLLocationManagerDelegate{
    
}
