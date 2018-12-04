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

    // Declare here for global use
    var navView: UIView?
    var mapView: GMSMapView?
    var toolsView: UIView?
    var popupToolsView: UIView?
    var countField: UITextField?
    var heatmapSwitch = UISwitch()
    
    var keyboardHeight: CGFloat?
    var markerCount: Int = 0
    var markers: Array<GMSMarker> = Array()
    var popupToolsHidden = true
    var heatmapOn = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.976, green: 0.976, blue: 0.976, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        
        // Map view
        let camera = GMSCameraPosition.camera(withLatitude: 42.276347, longitude: -83.736247, zoom: 2.0)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - keyboardHeight! - (navigationController?.navigationBar.frame.size.height)! - UIApplication.shared.statusBarFrame.height - 50), camera: camera)
        mapView?.isMyLocationEnabled = true
        mapView?.settings.myLocationButton = true
        mapView?.settings.compassButton = true
        self.view.addSubview(mapView!)
        
        // Tools view
        let toolsRect = CGRect(x: 0, y: (mapView?.frame.size.height)!, width: self.view.frame.size.width, height: keyboardHeight! + 50)
        toolsView = UIView(frame: toolsRect)
        toolsView?.backgroundColor = UIColor.white
        self.view.addSubview(toolsView!)
        
        // Tools view: Text field to enter count rate
        countField = UITextField(frame: CGRect(x: 20, y: 10, width: 150, height: 30))
        countField!.placeholder = "Count Rate"
        countField!.textAlignment = .center
        countField!.font = countField!.font?.withSize(28)
        countField!.borderStyle = UITextField.BorderStyle.roundedRect
        countField!.keyboardType = UIKeyboardType.decimalPad
        countField!.becomeFirstResponder() // Open keyboard automatically
        toolsView?.addSubview(countField!)
        
        // Tools view: Button to set count rate
        let setButton = UIButton(type: UIButton.ButtonType.system)
        setButton.frame = CGRect(x: countField!.frame.size.width + 25, y: 10, width: 60, height: 30)
        setButton.setTitle("Set", for: .normal)
        setButton.titleLabel?.font = setButton.titleLabel?.font.withSize(26)
        setButton.addTarget(self, action: #selector(setCountRate(_:)), for: .touchUpInside)
        toolsView?.addSubview(setButton)
        
        // Tools view: Button to show popup tools
        let showPopupButton = UIButton(type: UIButton.ButtonType.system)
        showPopupButton.frame = CGRect(x: self.view.frame.size.width - 80, y: 10, width: 60, height: 30)
        showPopupButton.setTitle("Tools", for: .normal)
        showPopupButton.titleLabel?.font = setButton.titleLabel?.font.withSize(26)
        showPopupButton.addTarget(self, action: #selector(showPopupTools(_:)), for: .touchUpInside)
        toolsView?.addSubview(showPopupButton)
        
        // Popup tools view
        let popupToolsRect = CGRect(x: self.view.frame.size.width - 200, y: (mapView?.frame.size.height)!, width: 200, height: 170)
        popupToolsView = UIView(frame: popupToolsRect)
        popupToolsView!.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.875)
        self.view.addSubview(popupToolsView!)
        self.view.bringSubviewToFront(toolsView!)
        
        // Popup tools view: Undo marker button
        let undoMarkerButton = UIButton(type: UIButton.ButtonType.system)
        undoMarkerButton.frame = CGRect(x: 10, y: 10, width: 180, height: 30)
        undoMarkerButton.setTitle("Undo Marker", for: .normal)
        undoMarkerButton.titleLabel?.font = undoMarkerButton.titleLabel?.font.withSize(24)
        undoMarkerButton.addTarget(self, action: #selector(undoMarker(_:)), for: .touchUpInside)
        popupToolsView?.addSubview(undoMarkerButton)
        
        // Popup tools view: Remove all markers button
        let removeAllButton = UIButton(type: UIButton.ButtonType.system)
        removeAllButton.frame = CGRect(x: 10, y: 50, width: 180, height: 30)
        removeAllButton.setTitle("Remove All", for: .normal)
        removeAllButton.titleLabel?.font = removeAllButton.titleLabel?.font.withSize(24)
        removeAllButton.addTarget(self, action: #selector(removeAllMarkers(_:)), for: .touchUpInside)
        popupToolsView?.addSubview(removeAllButton)
        
        // Popup tools view: Heatmap button
        let heatmapButton = UIButton(type: UIButton.ButtonType.system)
        heatmapButton.frame = CGRect(x: 20, y: 90, width: 100, height: 30)
        heatmapButton.setTitle("Heatmap", for: .normal)
        heatmapButton.titleLabel?.font = heatmapButton.titleLabel?.font.withSize(24)
        heatmapButton.addTarget(self, action: #selector(toggleHeatmap(_:)), for: .touchUpInside)
        heatmapButton.contentHorizontalAlignment = .left
        popupToolsView?.addSubview(heatmapButton)
        
        // Popup tools view: Heatmap switch
        heatmapSwitch.frame = CGRect(x: 130, y: 90, width: 50, height: 30)
        heatmapSwitch.addTarget(self, action: #selector(toggleHeatmap(_:)), for: .touchUpInside)
        popupToolsView?.addSubview(heatmapSwitch)
        
        // Popup tools view: Export data button
        let exportDataButton = UIButton(type: UIButton.ButtonType.system)
        exportDataButton.frame = CGRect(x: 10, y: 130, width: 180, height: 30)
        exportDataButton.setTitle("Export Data", for: .normal)
        exportDataButton.titleLabel?.font = exportDataButton.titleLabel?.font.withSize(24)
        exportDataButton.addTarget(self, action: #selector(exportData(_:)), for: .touchUpInside)
        popupToolsView?.addSubview(exportDataButton)
    }
    
    @objc func setCountRate(_ sender: UIButton) {
        if (countField!.text == "") {
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
            marker.snippet = countField!.text
            marker.map = mapView
            markers.append(marker)
            
            //Go to marker
            mapView!.animate(toLocation: currentLocation)
            
            print ("Recorded \(String(describing: marker.snippet)) at \(String(describing: marker.title))")
            countField!.text = ""
        }
    }
    
    @objc func showPopupTools(_ sender: UIButton) {
        self.view.bringSubviewToFront(toolsView!)
        
        if (popupToolsHidden) { // Move it up 170 pixels
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.popupToolsView!.frame = CGRect(x: self.view.frame.size.width - 200, y: (self.mapView?.frame.size.height)! - 170, width: 200, height: 170)
            })
        }
        else { // Move it down 200 pixels
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.popupToolsView!.frame = CGRect(x: self.view.frame.size.width - 200, y: (self.mapView?.frame.size.height)!, width: 200, height: 170)
            })
        }
        self.popupToolsHidden = !self.popupToolsHidden
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
    
    @objc func toggleHeatmap(_ sender: UIButton) {
        if (heatmapOn) { // toggle off
            // implement later
            heatmapSwitch.setOn(false, animated: true)
            print("Toggled heatmap off")
        }
        else {
            // implement later
            heatmapSwitch.setOn(true, animated: true)
            print("Toggled heatmap on")
        }
        heatmapOn = !heatmapOn
    }
    
    @objc func exportData(_ sender: UIButton) {
        // implement later
        print("Data exported")
    }
    
}
