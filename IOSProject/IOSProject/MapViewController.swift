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
        //Test Data
        let annotation = MKPointAnnotation()
        annotation.title = datePicker.date.description
        annotation.subtitle = "ID: 123 PH: 12.5 Moist: 11.5 Temp: 5 degress"
        let lat = Double(56.120698)
        let long = Double(10.146591)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
        
        //Get Data from firebase.
        /*
        if let data = Data.getData(){
            for reading in data{
                //Check if the date is equal to the date chosen.
                if data.date == datePicker.date{
                    //Latitude and longitude for the coord.
                    let lat = Double(data.coordinates.lat)
                    let long = Double(data.coordinates.long)
                    if let lat = lat, let long = long{
                        //Make the coord
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                        //Sets region if its the last data
                        if reading == data[data.length]{
                            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 50000, longitudinalMeters: 50000)
                            mapView.setRegion(region, animated: true)
                        }
                        //Make annotation with description
                        let annotation = MKPointAnnotation()
                        annotation.title = data.date
                        annotation.subtitle = "PH: \(data.ph) Moist: \(data.moisture) Temp: \(data.temperature) Humid: \(data.humidity)"
                        annotation.coordinate = coordinate
                        mapView.addAnnotation(annotation)
                    }
                }
            }
        }
    */
    }
    

}



extension MapViewController : CLLocationManagerDelegate{
    
}
