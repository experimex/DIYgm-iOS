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

class BluetoothConnectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate {
    
    var tableView: UITableView!
    
    var centralManager: CBCentralManager!
    
    var names: [String] = []
    var RSSIs: [NSNumber] = []
    
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
        centralManager!.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(names[indexPath.row])")
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
        
        tableView!.reloadData()
    }
    
}
