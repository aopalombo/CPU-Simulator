//
//  ProgressCodeController.swift
//  TestingIDE
//
//  Created by Andrew Palombo on 03/12/2019.
//  Copyright © 2019 Andrew Palombo. All rights reserved.
//

import UIKit

class ProgressCodeController: UIViewController {
    
    @IBOutlet weak var currentCodeLine: UILabel!
    @IBOutlet weak var currentCodeDescription: UILabel!
    
    @IBAction func advanceButton(_ sender: Any) {
        advanceCode()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let assemblyCode = UserDefaults.standard.object(forKey: "assemblyCode") as! Array<String>
        currentCodeLine.text = assemblyCode[0]
        UserDefaults.standard.set(0, forKey: "progressCodeLineNo")
        
        let description = UserDefaults.standard.object(forKey: "description") as! Array<String>
        currentCodeDescription.text = description[0]
        UserDefaults.standard.set(0, forKey: "descriptionLineNo")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func advanceCode() {
        
        
        let assemblyCode = UserDefaults.standard.object(forKey: "assemblyCode") as! Array<String>
        var currentLineNo = UserDefaults.standard.object(forKey: "progressCodeLineNo") as! Int
        if currentLineNo < assemblyCode.count - 1 {
            currentLineNo += 1
            currentCodeLine.text = assemblyCode[currentLineNo]
            UserDefaults.standard.set(currentLineNo, forKey: "progressCodeLineNo")
        }
        
        let description = UserDefaults.standard.object(forKey: "description") as! Array<String>
        var currentDescriptionLineNo = UserDefaults.standard.object(forKey: "descriptionLineNo") as! Int
        if currentDescriptionLineNo < description.count - 1 {
            currentDescriptionLineNo += 1
            currentCodeDescription.text = description[currentDescriptionLineNo]
            UserDefaults.standard.set(currentDescriptionLineNo, forKey: "descriptionLineNo")
        }
    }

}
