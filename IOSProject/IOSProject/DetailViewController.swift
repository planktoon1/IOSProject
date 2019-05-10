//
//  DetailViewController.swift
//  IOSProject
//
//  Created by dmu mac 09 on 24/04/2019.
//  Copyright © 2019 eaaa. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    var data : Data?
    
    @IBOutlet weak var airTempMeasurementLabel: UILabel!
    
    @IBOutlet weak var humidityMeasurementLabel: UILabel!
    
    @IBOutlet weak var soilTempMeasurementLabel: UILabel!
    
    @IBOutlet weak var soilMoistureMeasurementLabel: UILabel!
    
    @IBOutlet weak var phMeasurementLabel: UILabel!
    
    @IBOutlet weak var electricConductMeasurementLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        airTempMeasurementLabel.text = "\(data?.airTemp.description ?? "0") º"
        humidityMeasurementLabel.text = "\(data?.humidity.description ?? "0") %"
        soilTempMeasurementLabel.text = "\(data?.soilTemp.description ?? "0") º"
        soilMoistureMeasurementLabel.text = "\(data?.moisture.description ?? "0") %"
        phMeasurementLabel.text = data?.ph.description ?? "0"
        electricConductMeasurementLabel.text = "\(data?.EC.description ?? "0") S/m"
    }
}
