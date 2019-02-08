//
//  HomeViewController.swift
//  DIYgm-iOS
//
//  Created by Li, Max on 11/28/18.
//  Copyright © 2018 DIYgm. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    
    // Finding keyboard height for manual mapping is done here because it
    // uses viewDidAppear(), which would occur too late in ManualViewController.
    
    @IBOutlet weak var manualButton: UIButton!
    @IBOutlet weak var bluetoothButton: UIButton!
    
    
    let initialTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    var keyboardHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Detect keyboard opening
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        self.view.addSubview(initialTextField)
        
        manualButton.addTarget(self, action: #selector(goToManual(_:)), for: .touchUpInside)
        bluetoothButton.addTarget(self, action: #selector(goToBluetooth(_:)), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Simulate tap initialTextField to open keyboard
        initialTextField.keyboardType = UIKeyboardType.decimalPad
        initialTextField.becomeFirstResponder()
    }
    
    // Find keyboard height
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            self.view.endEditing(true)
            print(keyboardHeight!)
        }
    }
    
    @objc func goToManual(_ sender: UIButton) {
        let vc = ManualViewController()
        vc.keyboardHeight = keyboardHeight
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goToBluetooth(_ sender: UIButton) {
        let vc = BluetoothViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
