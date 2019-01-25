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

class BluetoothConnectionViewController: UIViewController, CBCentralManagerDelegate {
    
    var centralManager: CBCentralManager?
    
    var names: [String] = []
    var RSSIs: [NSNumber] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
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
            names.append(name)
        } else {
            names.append(peripheral.identifier.uuidString)
        }
        RSSIs.append(RSSI)
        
        print("UUID: \(peripheral.identifier.uuidString)")
        print("RSSI: \(RSSI)")
        print("Ad Data: \(advertisementData)")
        print("------------------")
    }
    
}
