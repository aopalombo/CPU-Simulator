//
//  ContentDescription.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 04/12/2019.
//  Copyright © 2019 Andrew Palombo. All rights reserved.
//

import UIKit

public final class ContentDescription: Codable, ObservableObject, SimulationDescription {
    
	@Published public var assemblyCode: AssemblyCode
	@Published public var assemblyCodeErrors: [Int: String]
	@Published public var assemblyCodeErrorsAsString: String // these two properties are not computed because they are
	@Published public var assemblyCodeErroneousLineNos: [Int] // both computed in the method 'updateAssemblyCodeErrors'
    @Published public var machineCode: String
	
	@Published public var runThrough: RunThrough
	
	@Published public var preferences: Preferences
	
	@Published public var toggleToRefreshView: Bool
	
	var simulationTimer: Timer?
	
	public var machineCodeInHexadecimal: String {
		get {
			let machineCodeSplittable = CPUSimulatorString(text: self.machineCode)
			let machineCodeAsArray = machineCodeSplittable.separateByLFToArray()
			var result = ""
			for line in machineCodeAsArray {
				if line != "" {
					result += String(Int(line, radix: 2)!, radix: 16) + "\n"
				} else {
					result += "\n"
				}
			}
			if result.last == "\n" {
				result = String(result.dropLast())
			}
			return result
		}
	}
	public var machineCodeInDecimal: String {
		get {
			let machineCodeSplittable = CPUSimulatorString(text: self.machineCode)
			let machineCodeAsArray = machineCodeSplittable.separateByLFToArray()
			var result = ""
			for line in machineCodeAsArray {
				if line != "" {
					result += String(Int(line, radix: 2)!) + "\n"
				} else {
					result += "\n"
				}
			}
			return result
		}
	}
	public var assemblyCodeIsValid: Bool {
		self.machineCode != ""
	}
    
	// initialises properties
    public init() {
		self.assemblyCode = AssemblyCode(text: "")
		self.assemblyCodeErrors = [:]
		self.assemblyCodeErrorsAsString = ""
		self.assemblyCodeErroneousLineNos = []
		self.machineCode = ""
		
		self.runThrough = RunThrough()
		self.preferences = Preferences()
		
		self.toggleToRefreshView = false
    }

	// "cases serve as the authoritative list of properties that must be included when instances of a codable type are encoded or decoded" - Apple
	enum CodingKeys: CodingKey {
		case preferences
		
		case assemblyCode
		case assemblyCodeErrors
		case assemblyCodeErrorsAsString
		case assemblyCodeErroneousLineNumbers

		case machineCode
		
		case runThrough
	}
	
	public init(from decoder: Decoder) throws { //required not needed as class is final
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		preferences = try container.decode(Preferences.self, forKey: .preferences)
		
		assemblyCode = try container.decode(AssemblyCode.self, forKey: .assemblyCode)
		assemblyCodeErrors = try container.decode([Int: String].self, forKey: .assemblyCodeErrors)
		assemblyCodeErrorsAsString = try container.decode(String.self, forKey: .assemblyCodeErrorsAsString)
		assemblyCodeErroneousLineNos = try container.decode([Int].self, forKey: .assemblyCodeErroneousLineNumbers)

		machineCode = try container.decode(String.self, forKey: .machineCode)
		
		runThrough = try container.decode(RunThrough.self, forKey: .runThrough)
		toggleToRefreshView = false
		
		self.updateAssemblyCodeErrors()
		self.generateSteps()
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(preferences, forKey: .preferences)
		
		try container.encode(assemblyCode, forKey: .assemblyCode)
		try container.encode(assemblyCodeErrors, forKey: .assemblyCodeErrors)
		try container.encode(assemblyCodeErrorsAsString, forKey: .assemblyCodeErrorsAsString)
		try container.encode(assemblyCodeErroneousLineNos, forKey: .assemblyCodeErroneousLineNumbers)

		try container.encode(machineCode, forKey: .machineCode)
		
		try container.encode(runThrough, forKey: .runThrough)
	}
	
	public func updateAssemblyCodeErrors() -> Void {
		self.assemblyCodeErrors = self.assemblyCode.getAssemblyCodeErrors()
		
		var string = ""
		var lineNumbers = [Int]()
		let errorsDict = self.assemblyCodeErrors
		for (number, _) in errorsDict {
			lineNumbers.append(number)
		}
		lineNumbers.sort()
		for lineNumber in lineNumbers {
			string += errorsDict[lineNumber]! + "\n"
		}
		string = String(string.dropLast())
		self.assemblyCodeErroneousLineNos = lineNumbers
		self.assemblyCodeErrorsAsString = string
	}
	
	public func generateSteps() -> Void {
		self.runThrough.generateSteps(assemblyCode: assemblyCode, machineCode: machineCode)
	}
	
	@objc public func advanceStep() -> Void {
		if self.assemblyCodeIsValid {
			if self.runThrough.currentStep < self.runThrough.steps.count - 1 {
				//go to next step, if there is one
				self.runThrough.inExecution = true
				self.runThrough.currentStep += 1
				if self.runThrough.executingLineNo == 0 && self.assemblyCode.checkAssigningMemoryLine(line: self.assemblyCode.separateByLFToArray()[0]) {
					self.runThrough.executingLineNo = 1
					self.runThrough.programCounter.cellContents = self.runThrough.decimalToBinary(decimal: 1, minBitLength: 27)
				}
				self.runThrough.executingLineNo = self.runThrough.steps[self.runThrough.currentStep].lineNo
				self.runThrough.steps[self.runThrough.currentStep].performChanges()
			} else if self.runThrough.isRunning {
				//no next step and is running - stop
				self.stop()
			}
			self.toggleToRefreshView.toggle()
		}
	}
	
	public func run() -> Void {
		if self.assemblyCodeIsValid {
			if self.runThrough.currentStep == self.runThrough.steps.count - 1 {
				self.restartExecution()
			}
			self.runThrough.isRunning = true
			switch self.preferences.runSpeed {
			case "0.5Hz":
				simulationTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(advanceStep), userInfo: nil, repeats: true)
			case "1Hz":
				simulationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(advanceStep), userInfo: nil, repeats: true)
			case "2Hz":
				simulationTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(advanceStep), userInfo: nil, repeats: true)
			case "5Hz":
				simulationTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(advanceStep), userInfo: nil, repeats: true)
			case "0.1GHz":
				simulationTimer = Timer.scheduledTimer(timeInterval: 0.000001, target: self, selector: #selector(advanceStep), userInfo: nil, repeats: true)
			default:
				break
			}
			runThrough.clock.cellContents = "[Running at \(self.preferences.runSpeed)]"
			self.toggleToRefreshView.toggle()
		}
	}
	
	public func stop() -> Void {
		self.runThrough.isRunning = false
		self.simulationTimer?.invalidate()
		self.runThrough.clock.cellContents = "[Not Running]"
		self.toggleToRefreshView.toggle()
	}
	
	public func restartExecution() -> Void {
		self.runThrough.restartExecution(assemblyCode: assemblyCode)
		self.toggleToRefreshView.toggle()
	}

}

    
//    private enum Keys: String, CustomStringConvertible {
//		case preferences = "preferences"
//
//		case addressbus = "addressBus"
//		case dataBus = "memoryBus"
//		case controlBus = "controlBus"
//		case programCounter = "programCounter"
//		case currentIntructionRegister = "currentIntructionRegister"
//		case memoryBufferRegister = "memoryBufferRegister"
//		case memoryAddressRegister = "memoryAddressRegister"
//		case statusIsEqualRegister = "statusIsEqualRegister"
//		case statusIsNotEqualRegister = "statusIsNotEqualRegister"
//		case statusLessThanRegister = "statusLessThanRegister"
//
//		case statusGreaterThanRegister = "statusGreaterThanRegister"
//
//        case assemblyCode = "assemblyCode"
//		case title = "title"
//        case executingLineNo = "executingLineNo"
//        case machineCode = "machineCode"
//        case simulation = "simulation"
//
//        // CustomStringConvertible conformance
//        var description: String {
//            return self.rawValue
//        }
//
//    }
    
    // NSObject conformance
    // coonformance needed to allow encoding/decoding of data which could include UIImage, for example
	// first value passed is from self.property
//    public func encode(with coder: NSCoder) {
//		coder.encode(preferences, forKey: Keys.preferences.description)
//
//		coder.encode(addressBus, forKey: Keys.addressbus.description)
//		coder.encode(memoryBus, forKey: Keys.memoryBus.description)
//		coder.encode(controlBus, forKey: Keys.controlBus.description)
//
//		coder.encode(statusGreaterThanRegister, forKey: Keys.statusGreaterThanRegister.description)
//		coder.encode(programCounter, forKey: Keys.programCounter.description)
//		coder.encode(currentIntructionRegister, forKey: Keys.currentIntructionRegister.description)
//		coder.encode(memoryAddressRegister, forKey: Keys.memoryAddressRegister.description)
//		coder.encode(memoryBufferRegister, forKey: Keys.memoryBufferRegister.description)
//		coder.encode(statusIsEqualRegister, forKey: Keys.statusIsEqualRegister.description)
//		coder.encode(statusIsNotEqualRegister, forKey: Keys.statusIsNotEqualRegister.description)
//		coder.encode(statusLessThanRegister, forKey: Keys.statusLessThanRegister.description)
//
//        coder.encode(simulation, forKey: Keys.simulation.description)
//		coder.encode(title, forKey: Keys.title.description)
//        coder.encode(assemblyCode, forKey: Keys.assemblyCode.description)
//		coder.encode(executingLineNo, forKey: Keys.executingLineNo.description)
//        coder.encode(machineCode, forKey: Keys.machineCode.description)
//    }
    
    // NSObject conformance
    // this function decodes stored data to data objects that can be displayed and manipulated
    // where values are not optional, default values are given by ??
	// Called when data not yet decoded; a decoder
//    public required init?(coder decoder: NSCoder) {
//
//        // guard for failure when for example, file is empty
//        guard let plugin = decoder.decodeObject(forKey: Keys.simulation.description) as? String else {
//            return nil
//        }
//        // guards needed for any other data extraction that could fail - none needed
//        simulation = plugin // if this works i hope it will for the rest!
//		title = decoder.decodeObject(forKey: Keys.title.description) as? String
//        assemblyCode = decoder.decodeObject(forKey: Keys.assemblyCode.description) as? String ?? "not decoded"
//        //executingLineNo = decoder.decodeObject(forKey: Keys.executingLineNo.description) as? Int ?? 1
//        machineCode = decoder.decodeObject(forKey: Keys.machineCode.description) as? String
//		print("line 141")
//		preferences = decoder.decodeObject(forKey: Keys.preferences.description) as! Preferences
//
//		addressBus = decoder.decodeObject(forKey: Keys.addressbus.description) as! Cell
//		memoryBus = decoder.decodeObject(forKey: Keys.memoryBus.description) as! Cell
//		controlBus = decoder.decodeObject(forKey: Keys.controlBus.description) as! Cell
//
//		statusGreaterThanRegister = decoder.decodeObject(forKey: Keys.statusGreaterThanRegister.description) as! Cell
//		programCounter = decoder.decodeObject(forKey: Keys.programCounter.description) as! Cell
//		currentIntructionRegister = decoder.decodeObject(forKey: Keys.currentIntructionRegister.description) as! Cell
//		memoryAddressRegister = decoder.decodeObject(forKey: Keys.memoryAddressRegister.description) as! Cell
//		memoryBufferRegister = decoder.decodeObject(forKey: Keys.memoryBufferRegister.description) as! Cell
//		statusIsEqualRegister = decoder.decodeObject(forKey: Keys.statusIsEqualRegister.description) as! Cell
//		statusIsNotEqualRegister = decoder.decodeObject(forKey: Keys.statusIsNotEqualRegister.description) as! Cell
//		statusLessThanRegister = decoder.decodeObject(forKey: Keys.statusLessThanRegister.description) as! Cell
//    }
    
//	required public init(from: Decoder) throws {
//		<#code#>
//	}
//
//	public func encode(to encoder: Encoder) throws {
//		<#code#>
//	}
//
//}
