//
//  BluetoothConnectionViewController.swift
//  DIYgm-iOS
//
//  Created by Li, Max on 1/25/19.
//  Copyright © 2019 DIYgm. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class BluetoothConnectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var tableView: UITableView?
    
    var centralManager: CBCentralManager?
    var diygm: CBPeripheral?
    
    var countRate: Int?
    
    var peripherals: [CBPeripheral] = []
    var names: [String] = []
    var RSSIs: [NSNumber] = []
    
    let serviceCBUUID = CBUUID(string: "ec00")
    let characteristicCBUUID = CBUUID(string: "ec00")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Bluetooth Connection"
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh(_:)))
        self.navigationItem.rightBarButtonItem = refreshButton
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - (navigationController!.navigationBar.frame.size.height) - UIApplication.shared.statusBarFrame.height - 50))
        tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        tableView!.dataSource = self
        tableView!.delegate = self
        self.view!.addSubview(tableView!)
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @objc func refresh(_ sender: UIButton) {
        print("Refresh")
        names = []
        RSSIs = []
        tableView!.reloadData()
        centralManager!.stopScan()
        centralManager!.scanForPeripherals(withServices: [serviceCBUUID], options: nil)
    }
    
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
        
        if let countRate = Int(String(data: characteristic.value!, encoding: String.Encoding.utf8)!) {
            
            print(countRate)
        }
        
    }
}
