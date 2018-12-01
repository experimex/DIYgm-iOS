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

    var keyboardHeight: CGFloat?
    var mapView: GMSMapView?
    var toolsView: UIView?
    let countField = UITextField(frame: CGRect(x: 10, y: 10, width: 150, height: 30))
    var markerCount: Int = 0
    var markers: Array<GMSMarker> = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Open keyboard automatically
        countField.becomeFirstResponder()
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        // Map view
        let camera = GMSCameraPosition.camera(withLatitude: 42.276347, longitude: -83.736247, zoom: 2.0)
        let heightOffset = (self.navigationController?.toolbar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height //due to notification bar and navigation bar
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: heightOffset, width: self.view.frame.size.width, height: self.view.frame.size.height - heightOffset - keyboardHeight! - 50), camera: camera)
        mapView?.isMyLocationEnabled = true
        mapView?.settings.myLocationButton = true
        mapView?.settings.compassButton = true
        self.view.addSubview(mapView!)
        
        
        // Tools view
        let toolsRect = CGRect(x: 0, y: (self.navigationController?.toolbar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height + (mapView?.frame.size.height)!, width: self.view.frame.size.width, height: 100)
        toolsView = UIView(frame: toolsRect)
        toolsView?.backgroundColor = UIColor.white
        self.view.addSubview(toolsView!)
        
        
        // Text field to enter count rate
        countField.placeholder = "Count Rate"
        countField.textAlignment = .center
        countField.font = countField.font?.withSize(28)
        countField.borderStyle = UITextField.BorderStyle.roundedRect
        countField.keyboardType = UIKeyboardType.decimalPad
        toolsView?.addSubview(countField)
        
        // Set count rate button
        let setButton = UIButton(type: UIButton.ButtonType.system)
        setButton.frame = CGRect(x: countField.frame.size.width + 20, y: 10, width: 60, height: 30)
        setButton.setTitle("Set", for: .normal)
        setButton.titleLabel?.font = setButton.titleLabel?.font.withSize(24)
        setButton.addTarget(self, action: #selector(setCountRate(_:)), for: .touchUpInside)
        toolsView?.addSubview(setButton)
        
        /*
        // Keyboard toolbar with set and done button
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 50))
        let flexSpaceLeft = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let setButton: UIBarButtonItem = UIBarButtonItem(title: "Set Marker", style: .done, target: self, action: #selector(setCountRate(_:)))
        let undoButton: UIBarButtonItem = UIBarButtonItem(title: "Undo Marker", style: .done, target: self, action: #selector(undoMarker(_:)))
        let removeAllButton: UIBarButtonItem = UIBarButtonItem(title: "Remove All", style: .done, target: self, action: #selector(removeAllMarkers(_:)))
        let flexSpaceRight = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpaceLeft, setButton, undoButton, removeAllButton, flexSpaceRight], animated: false)
        toolbar.sizeToFit()
        self.countField.inputAccessoryView = toolbar
        */
    }
    
    // From Set button on keyboard
    @objc func setCountRate(_ sender: UIButton) {
        if (countField.text == "") {
            print("No count rate entered")
        }
        else if (mapView?.myLocation) == nil {
            print("Location unknown")
        }
        else {
            markerCount += 1
            let marker = GMSMarker()
            let currentLocation = CLLocationCoordinate2D(latitude: (mapView?.myLocation?.coordinate.latitude)!, longitude: (mapView?.myLocation?.coordinate.longitude)!)
            marker.position = currentLocation
            marker.title = "Marker\(markerCount)"
            marker.snippet = countField.text
            marker.map = mapView
            markers.append(marker)
            
            //Go to marker
            mapView!.animate(toLocation: currentLocation)
            
            print ("Recorded \(String(describing: marker.snippet)) at \(String(describing: marker.title))")
            countField.text = ""
        }
    }
    
    @objc func undoMarker(_ sender: UIButton) {
        if (markerCount > 0) {
            markers[markerCount - 1].map = nil
            markers.removeLast()
            print("Marker\(markerCount) removed")
            markerCount -= 1
        }
        else {
            print("No markers to remove")
        }
    }
    
    @objc func removeAllMarkers(_ sender: UIButton) {
        if (markers.count > 0) {
            mapView!.clear()
            markerCount = 0
            print("Removed all markers")
        }
        else {
            print("No markers to remove")
        }
        
    }
    
    // From Done button on keyboard
    @objc func closeKeyboard(_ sender: UIButton) {
        self.view.endEditing(true)
    }
}
