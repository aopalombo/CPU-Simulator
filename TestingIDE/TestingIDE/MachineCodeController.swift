//
//  MachineCodeController.swift
//  TestingIDE
//
//  Created by Andrew Palombo on 18/08/2019.
//  Copyright © 2019 Andrew Palombo. All rights reserved.
//

import Foundation
import UIKit

class MachineCodeController: UIViewController {
    
    @IBOutlet weak var machineCodeField: UITextView!
    
    override func viewDidLoad() {
        let machineCode = UserDefaults.standard.object(forKey: "machineCode") as! String
        machineCodeField.text = machineCode
    }
    
    
}

