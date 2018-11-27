//
//  MapViewController.swift
//  DIYgm-iOS
//
//  Created by Li, Max on 11/19/18.
//  Copyright © 2018 DIYgm. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class ManualViewController: UIViewController {
    
    var mapView: GMSMapView?
    var toolsView: UIView?
    let countField = UITextField(frame: CGRect(x: 10, y: 10, width: 180, height: 40))
    let setButton = UIButton(type: UIButton.ButtonType.system)
    var markerCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Map view
        let camera = GMSCameraPosition.camera(withLatitude: 42.276347, longitude: -83.736247, zoom: 2.0)
        let heightOffset = (self.navigationController?.toolbar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height + 100 //due to notification bar and navigation bar
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: heightOffset, width: self.view.frame.size.width, height: self.view.frame.size.height - heightOffset), camera: camera)
        mapView?.isMyLocationEnabled = true
        mapView?.settings.myLocationButton = true
        mapView?.settings.compassButton = true
        self.view.addSubview(mapView!)
        
        // Tools view
        let toolsRect = CGRect(x: 0, y: (self.navigationController?.toolbar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height, width: self.view.frame.size.width, height: 100)
        toolsView = UIView(frame: toolsRect)
        self.view.addSubview(toolsView!)
        
        // Text field to enter count rate
        countField.placeholder = "Count Rate"
        countField.textAlignment = .center
        countField.font = countField.font?.withSize(28)
        countField.borderStyle = UITextField.BorderStyle.roundedRect
        countField.keyboardType = UIKeyboardType.decimalPad
        toolsView?.addSubview(countField)
        
        // Keyboard toolbar with set and done button
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil) //flexible space on the left in toolbar
        let setButton: UIBarButtonItem = UIBarButtonItem(title: "Set", style: .done, target: self, action: #selector(setCountRate(_:)))
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(closeKeyboard(_:)))
        toolbar.setItems([flexSpace, setButton, doneButton], animated: false)
        toolbar.sizeToFit()
        self.countField.inputAccessoryView = toolbar
    }
    
    // Run when Set button on keyboard is pressed
    @objc func setCountRate(_ sender: UIButton) {
        if (countField.text == "") {
            print("No count rate entered")
        }
        else if (mapView?.myLocation) == nil {
            print("Location unknown")
        }
        else {
            let marker = GMSMarker()
            let currentLocation = CLLocationCoordinate2D(latitude: (mapView?.myLocation?.coordinate.latitude)!, longitude: (mapView?.myLocation?.coordinate.longitude)!)
            marker.position = currentLocation
            marker.title = "Count\(markerCount)"
            marker.snippet = countField.text
            marker.map = mapView
            
            //Go to marker
            mapView!.animate(toLocation: currentLocation)
            
            print ("Recorded \(String(describing: marker.snippet)) at \(String(describing: marker.title))")
            countField.text = ""
            markerCount += 1
        }
    }
    
    // Run when Done button on keyboard is pressed
    @objc func closeKeyboard(_ sender: UIButton) {
        self.view.endEditing(true)
    }
}
