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

class BluetoothViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // Objects declared here for global use
    var tableView: UITableView?
    var mapView: GMSMapView?
    var toolsView: UIView?
    var markButton: UIButton?
    var disabledMarkLabel: UILabel?
    var popupToolsView: UIView?
    var countLabel: UILabel?
    var autoMarkSwitch: UISwitch?
    var centralManager: CBCentralManager?
    var diygm: CBPeripheral?
    
    // Bluetooth
    var peripherals: [CBPeripheral] = []
    var names: [String] = []
    var RSSIs: [NSNumber] = []
    let serviceCBUUID = CBUUID(string: "ec00")
    let characteristicCBUUID = CBUUID(string: "ec00")
    
    // Marker data
    var markerCount: Int = 0
    var markers: [GMSMarker] = []
    var popupToolsHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Bluetooth instantiation
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Navigation controller instantiation
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.976, green: 0.976, blue: 0.976, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "Bluetooth Connection"
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh(_:)))
        self.navigationItem.rightBarButtonItem = refreshButton
        
        // Map view instantiation
        let camera = GMSCameraPosition.camera(withLatitude: 42.276347, longitude: -83.736247, zoom: 2.0)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 200 - (navigationController?.navigationBar.frame.size.height)! - UIApplication.shared.statusBarFrame.height - 50), camera: camera)
        mapView?.isMyLocationEnabled = true
        mapView?.settings.myLocationButton = true
        mapView?.settings.compassButton = true
        self.view.addSubview(mapView!)
        
        // Tools view instantiation
        let toolsRect = CGRect(x: 0, y: (mapView?.frame.size.height)!, width: self.view.frame.size.width, height: 250)
        toolsView = UIView(frame: toolsRect)
        toolsView?.backgroundColor = UIColor.white
        self.view.addSubview(toolsView!)
        self.view.sendSubviewToBack(toolsView!)
        
        // Tools view: Button to mark count rate
        markButton = UIButton(type: UIButton.ButtonType.system)
        markButton!.frame = CGRect(x: 0, y: 10, width: self.view.frame.size.width / 2, height: 30)
        markButton!.setTitle("Mark", for: .normal)
        markButton!.titleLabel?.font = markButton!.titleLabel?.font.withSize(26)
        markButton!.titleLabel?.textAlignment = .center
        markButton!.addTarget(self, action: #selector(markCountRate(_:)), for: .touchUpInside)
        toolsView?.addSubview(markButton!)
        
        // Tools view: Label for disabled mark button
        disabledMarkLabel = UILabel(frame: CGRect(x: 0, y: 10, width: self.view.frame.size.width / 2, height: 30))
        disabledMarkLabel!.text = "Auto-Marking"
        disabledMarkLabel!.textAlignment = .center
        disabledMarkLabel!.font = disabledMarkLabel!.font?.withSize(18)
        disabledMarkLabel!.isHidden = true
        toolsView?.addSubview(disabledMarkLabel!)
        
        // Tools view: Button to show popup tools
        let showPopupButton = UIButton(type: UIButton.ButtonType.system)
        showPopupButton.frame = CGRect(x: self.view.frame.size.width / 2, y: 10, width: self.view.frame.size.width / 2, height: 30)
        showPopupButton.setTitle("Tools", for: .normal)
        showPopupButton.titleLabel?.font = showPopupButton.titleLabel?.font.withSize(26)
        showPopupButton.titleLabel?.textAlignment = .center
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
        
        // Popup tools view instantiation
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
        
        // Popup tools view: Export data button
        let exportDataButton = UIButton(type: UIButton.ButtonType.system)
        exportDataButton.frame = CGRect(x: 10, y: 90, width: 180, height: 30)
        exportDataButton.setTitle("Export Data", for: .normal)
        exportDataButton.titleLabel?.font = exportDataButton.titleLabel?.font.withSize(24)
        exportDataButton.addTarget(self, action: #selector(exportData(_:)), for: .touchUpInside)
        popupToolsView?.addSubview(exportDataButton)
        
        // Popup tools view: Auto-mark label
        let autoMarkLabel = UILabel(frame: CGRect(x: 10, y: 130, width: 120, height: 30))
        autoMarkLabel.text = "Auto-Mark"
        autoMarkLabel.font = autoMarkLabel.font.withSize(24)
        autoMarkLabel.textAlignment = .center
        popupToolsView?.addSubview(autoMarkLabel)
        
        // Popup tools view: Auto-mark switch
        autoMarkSwitch = UISwitch(frame: CGRect(x: 140, y: 130, width: 40, height: 30))
        autoMarkSwitch!.addTarget(self, action: #selector(disableMarkButton(_:)), for: .touchUpInside)
        popupToolsView?.addSubview(autoMarkSwitch!)
        
        // Bluetooth device table view setup
        tableView = UITableView(frame: CGRect(x: 0, y: (mapView?.frame.size.height)!, width: self.view.frame.size.width, height: 250))
        tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        tableView!.dataSource = self
        tableView!.delegate = self
        self.view!.addSubview(tableView!)
        self.view!.bringSubviewToFront(tableView!)
    }

}

// Tool button functions
extension BluetoothViewController {
    
    @objc func markCountRate(_ sender: AnyObject?) {
        if (countLabel == nil) {
            print("No count rate")
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
            
            // Marker's color saturation is based on count rate
            let highValue: CGFloat = 100.0
            let sat = CGFloat(Int(countLabel!.text!)!) / highValue
            marker.icon = GMSMarker.markerImage(with: UIColor(hue: 0.0, saturation: sat, brightness: 1.0, alpha: 1.0))
            
            marker.map = mapView
            markers.append(marker)
            markerCount += 1
            
            // Go to marker
            mapView!.animate(toLocation: currentLocation)
            
            print ("Recorded \(String(describing: marker.snippet)) at \(String(describing: marker.title))")
        }
    }
    
    @objc func showPopupTools(_ sender: UIButton) {
        self.view.bringSubviewToFront(toolsView!)
        
        if (popupToolsHidden) { // Move it up 130 pixels
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.popupToolsView!.frame = CGRect(x: self.view.frame.size.width - 200, y: (self.mapView?.frame.size.height)! - 170, width: 200, height: 170)
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
                
                let vc = UIActivityViewController(activityItems: [path as Any], applicationActivities: [])
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
    
    // Disable mark button when auto-marking
    @objc func disableMarkButton(_ sender: UISwitch) {
        if (autoMarkSwitch!.isOn) {
            markButton!.isHidden = true
            disabledMarkLabel!.isHidden = false
        } else {
            markButton!.isHidden = false
            disabledMarkLabel!.isHidden = true
        }
    }
}

// TableView functions
extension BluetoothViewController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(names[indexPath.row])")
        diygm = peripherals[indexPath.row]
        diygm!.delegate = self
        centralManager!.connect(diygm!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(names[indexPath.row])\n\(RSSIs[indexPath.row])"
        cell.textLabel!.font = cell.textLabel!.font.withSize(19)
        cell.textLabel!.numberOfLines = 2
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Nearby Raspberry Pis:"
    }
}

// Bluetooth functions
extension BluetoothViewController {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            showBluetoothAlert(message: "Unknown cause")
        case .resetting:
            showBluetoothAlert(message: "Bluetooth is resetting. Try again.")
        case .unsupported:
            showBluetoothAlert(message: "This app does not support the version of Bluetooth on your device.")
        case .unauthorized:
            showBluetoothAlert(message: "You need to allow this app to use Bluetooth.")
        case .poweredOff:
            showBluetoothAlert(message: "Make sure Bluetooth is turned on.")
        case .poweredOn:
            central.scanForPeripherals(withServices: [serviceCBUUID], options: nil)
        }
    }
    
    func showBluetoothAlert(message: String) {
        let alertVC = UIAlertController(title: "Bluetooth isn't working", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in alertVC.dismiss(animated: true, completion: nil) })
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        peripherals.append(peripheral)
        if let name = peripheral.name {
            names.append(name)
            print("Name: \(name)")
        } else {
            names.append(peripheral.identifier.uuidString)
        }
        RSSIs.append(RSSI)
        
        print("UUID: \(peripheral.identifier.uuidString)")
        print("Ad Data: \(advertisementData)")
        print("------------------")
        
        tableView!.reloadData()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        
        diygm!.discoverServices(nil)
        
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        tableView?.isHidden = true
        
        for service in services {
            print(service)
            diygm!.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let countRate = String(data: characteristic.value!, encoding: String.Encoding.utf8) {
            
            countLabel!.text = countRate
            
            if (autoMarkSwitch!.isOn) {
                markCountRate(nil) //nil means it is called without button
            }
        }
        
    }
    
    @objc func refresh(_ sender: UIButton) {
        print("Refresh")
        names = []
        RSSIs = []
        tableView!.reloadData()
        centralManager!.stopScan()
        centralManager!.scanForPeripherals(withServices: [serviceCBUUID], options: nil)
    }
}

