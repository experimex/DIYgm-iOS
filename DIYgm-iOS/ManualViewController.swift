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
    // You don't need to modify the default init(nibName:bundle:) method.
    
    var mapView: GMSMapView?
    var toolsView: UIView?
    
    override func viewDidLoad() {
     
        super.viewDidLoad()
        
        //Map view
        let camera = GMSCameraPosition.camera(withLatitude: 42.276347, longitude: -83.736247, zoom: 2.0)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: ((self.navigationController?.toolbar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height + 100), width: self.view.frame.size.width, height: self.view.frame.size.height), camera: camera)
        mapView?.isMyLocationEnabled = true
        self.view.addSubview(mapView!)
        
        //Tools view
        let toolsRect = CGRect(x: 0, y: (self.navigationController?.toolbar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height, width: self.view.frame.size.width, height: 100)
        toolsView = UIView(frame: toolsRect)
        self.view.addSubview(toolsView!)
        
        /*
        let label = UITextField(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))
        label.text = "Hello"
        label.textAlignment = .center
        label.font = label.font.withSize(20)
        toolsView?.addSubview(label)
        */
        
    }

}
