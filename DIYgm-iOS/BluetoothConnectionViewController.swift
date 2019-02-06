//
//  BluetoothConnectionViewController.swift
//  DIYgm-iOS
//
//  Created by Li, Max on 1/25/19.
//  Copyright © 2019 DIYgm. All rights reserved.
//

import Foundation
import UIKit
import CocoaMQTT

class BluetoothConnectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView?
    
    var names: [String] = []
    var RSSIs: [NSNumber] = []
    
    let mqttClient = CocoaMQTT(clientID: "iOS Device", host: "192.168.0.X", port: 1883)
    
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
        
    }
    
    @objc func refresh(_ sender: UIButton) {
        print("Refresh")
        print(mqttClient.host)
        tableView!.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(names[indexPath.row])")
        
        print("------------------")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath as IndexPath)
        //cell.textLabel!.text =
        cell.textLabel!.font = cell.textLabel!.font.withSize(19)
        cell.textLabel!.numberOfLines = 2
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
}
