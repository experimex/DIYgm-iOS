//
//  BluetoothViewController.swift
//  DIYgm-iOS
//
//  Created by Li, Max on 1/23/19.
//  Copyright © 2019 DIYgm. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import CoreBluetooth

class BluetoothViewController: UIViewController, CBCentralManagerDelegate {
    
    // Objects declared here for global use
    var navView: UIView?
    var mapView: GMSMapView?
    var toolsView: UIView?
    var popupToolsView: UIView?
    var countLabel: UILabel?
    
    var centralManager: CBCentralManager?
    
    var markerCount: Int = 0
    var markers: Array<GMSMarker> = Array()
    var popupToolsHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.976, green: 0.976, blue: 0.976, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Map view
        let camera = GMSCameraPosition.camera(withLatitude: 42.276347, longitude: -83.736247, zoom: 2.0)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 200 - (navigationController?.navigationBar.frame.size.height)! - UIApplication.shared.statusBarFrame.height - 50), camera: camera)
        mapView?.isMyLocationEnabled = true
        mapView?.settings.myLocationButton = true
        mapView?.settings.compassButton = true
        self.view.addSubview(mapView!)
        
        // Tools view
        let toolsRect = CGRect(x: 0, y: (mapView?.frame.size.height)!, width: self.view.frame.size.width, height: 250)
        toolsView = UIView(frame: toolsRect)
        toolsView?.backgroundColor = UIColor.white
        self.view.addSubview(toolsView!)
        
        // Tools view: Button to set count rate
        let setButton = UIButton(type: UIButton.ButtonType.system)
        setButton.frame = CGRect(x: 100, y: 10, width: 60, height: 30)
        setButton.setTitle("Set", for: .normal)
        setButton.titleLabel?.font = setButton.titleLabel?.font.withSize(26)
        setButton.addTarget(self, action: #selector(setCountRate(_:)), for: .touchUpInside)
        toolsView?.addSubview(setButton)
        
        // Tools view: Button to show popup tools
        let showPopupButton = UIButton(type: UIButton.ButtonType.system)
        showPopupButton.frame = CGRect(x: self.view.frame.size.width - 80, y: 10, width: 60, height: 30)
        showPopupButton.setTitle("Tools", for: .normal)
        showPopupButton.titleLabel?.font = showPopupButton.titleLabel?.font.withSize(26)
        showPopupButton.addTarget(self, action: #selector(showPopupTools(_:)), for: .touchUpInside)
        toolsView?.addSubview(showPopupButton)
        
        // Tools view: "Count Rate:" label
        let textLabel = UILabel(frame: CGRect(x: 0, y: 65, width: self.view.frame.size.width, height: 30))
        textLabel.center.x = self.view.center.x
        textLabel.text = "Count Rate:"
        textLabel.textAlignment = .center
        textLabel.font = textLabel.font?.withSize(25)
        toolsView?.addSubview(textLabel)
        
        // Tools view: Count rate value label
        countLabel = UILabel(frame: CGRect(x: 0, y: 45, width: self.view.frame.size.width, height: 200))
        countLabel!.center.x = self.view.center.x
        countLabel!.text = "0"
        countLabel!.textAlignment = .center
        countLabel!.font = countLabel!.font?.withSize(100)
        toolsView?.addSubview(countLabel!)
        
        // Popup tools view
        let popupToolsRect = CGRect(x: self.view.frame.size.width - 200, y: (mapView?.frame.size.height)!, width: 200, height: 130)
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
        
        // Popup tools view: Export data button
        let exportDataButton = UIButton(type: UIButton.ButtonType.system)
        exportDataButton.frame = CGRect(x: 10, y: 90, width: 180, height: 30)
        exportDataButton.setTitle("Export Data", for: .normal)
        exportDataButton.titleLabel?.font = exportDataButton.titleLabel?.font.withSize(24)
        exportDataButton.addTarget(self, action: #selector(exportData(_:)), for: .touchUpInside)
        popupToolsView?.addSubview(exportDataButton)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
            
        } else {
            let alertVC = UIAlertController(title: "Bluetooth isn't working", message: "Make sure your Bluetooth is on.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in alertVC.dismiss(animated: true, completion: nil) })
            alertVC.addAction(okAction)
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let name = peripheral.name {
            print("Name: \(name)")
        }
        print("UUID: \(peripheral.identifier.uuidString)")
        print("RSSI: \(RSSI)")
        print("Ad Data: \(advertisementData)")
        print("------------------")
    }
    
    // For now, it gets randomly generated count rates instead of getting it from Bluetooth
    @objc func setCountRate(_ sender: UIButton) {
        countLabel!.text = String(Int.random(in: 0..<1000))
        if (countLabel!.text == "") {
            print("No count rate entered")
        }
        else if (mapView?.myLocation) == nil {
            print("Location unknown")
        }
        else {
            let marker = GMSMarker()
            let currentLocation = CLLocationCoordinate2D(latitude: (mapView?.myLocation?.coordinate.latitude)!, longitude: (mapView?.myLocation?.coordinate.longitude)!)
            marker.position = currentLocation
            marker.title = "Marker\(markerCount)"
            marker.snippet = countLabel!.text
            
            //Marker's color saturation is based on count rate
            let highValue: CGFloat = 100.0
            let sat = CGFloat(Int(countLabel!.text!)!) / highValue
            marker.icon = GMSMarker.markerImage(with: UIColor(hue: 0.0, saturation: sat, brightness: 1.0, alpha: 1.0))
            
            marker.map = mapView
            markers.append(marker)
            markerCount += 1
            
            //Go to marker
            mapView!.animate(toLocation: currentLocation)
            
            print ("Recorded \(String(describing: marker.snippet)) at \(String(describing: marker.title))")
        }
    }
    
    @objc func showPopupTools(_ sender: UIButton) {
        self.view.bringSubviewToFront(toolsView!)
        
        if (popupToolsHidden) { // Move it up 130 pixels
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.popupToolsView!.frame = CGRect(x: self.view.frame.size.width - 200, y: (self.mapView?.frame.size.height)! - 130, width: 200, height: 170)
            })
        }
        else { // Return to hidden behind keyboard
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
            markers = []
            markerCount = 0
            print("Removed all markers")
        }
        else {
            print("No markers to remove")
        }
    }
    
    @objc func exportData(_ sender: UIButton) {
        let fileName = "diygm_count_rates.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        var csvText = "Latitude,Longitude,Count Rate\n"
        
        if markers.count > 0 {
            
            for marker in markers {
                let newLine = "\(marker.position.latitude),\(marker.position.longitude),\(marker.snippet!)\n"
                csvText = csvText + newLine
            }
            
            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                
                let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
                vc.excludedActivityTypes = [
                    UIActivity.ActivityType.assignToContact,
                    UIActivity.ActivityType.saveToCameraRoll,
                    UIActivity.ActivityType.postToFlickr,
                    UIActivity.ActivityType.postToVimeo,
                    UIActivity.ActivityType.postToTencentWeibo,
                    UIActivity.ActivityType.postToTwitter,
                    UIActivity.ActivityType.postToFacebook,
                    UIActivity.ActivityType.openInIBooks
                ]
                present(vc, animated: true, completion: nil)
                
            } catch {
                print("Failed to create file")
                print("\(error)")
            }
            
        } else {
            print("There is no data to export")
        }
        
    }
}

