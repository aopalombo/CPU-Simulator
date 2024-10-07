//
//  SimulationDescription.swift
//  CPU Simulator Framework
//
//  Created by Andrew Palombo on 02/01/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import UIKit

// Describes a simulation.
public protocol SimulationDescription {
    
    var assemblyCode: AssemblyCode {get set}
	var assemblyCodeErrors: [Int: String] {get set}
	var assemblyCodeErrorsAsString: String {get set}
	var assemblyCodeErroneousLineNos: [Int] {get set}
	var machineCode: String {get set}
    
	var runThrough: RunThrough {get set}
	
	var preferences: Preferences {get set}
}
