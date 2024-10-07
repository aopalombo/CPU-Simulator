//
//  RunThrough.swift
//  CPU Simulator Framework
//
//  Created by Andrew Palombo on 24/02/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import UIKit

public class RunThrough: Codable, ObservableObject {
	// Composed of all buses and registers, creates run through steps
	@Published public var executingLineNo: Int
	@Published public var inExecution: Bool
	@Published public var isRunning: Bool //not saved as start value is always false
	
	@Published public var memoryValues: [String]
	@Published public var generalPurposeRegisters: [Cell]
	@Published public var generalPurposeRegistersIsRecentlyChanged: Bool
	
	@Published public var addressBus: Cell
	@Published public var dataBus: Cell
//	@Published public var controlBus: Cell

	@Published public var programCounter: Cell
	@Published public var currentInstructionRegister: Cell
	@Published public var memoryBufferRegister: Cell
	@Published public var memoryAddressRegister: Cell
	@Published public var statusRegister: Cell
	
	@Published public var clock: Cell
	@Published public var alu: Cell
	
	@Published public var steps: [(description: String, lineNo: Int, performChanges: () -> Void)]
	@Published public var currentStep: Int
	
	private var machineCodeAsArray = [String]()
	
	public var memoryValuesInHexadecimal: [String] {
		get {
			var output = [String]()
			for memoryValue in self.memoryValues {
				output.append(String(Int(memoryValue, radix: 2)!, radix: 16))
			}
			return output
		}
	}
	
	public var memoryValuesInDecimal: [String] {
		get {
			var output = [String]()
			for memoryValue in self.memoryValues {
				output.append(String(Int(memoryValue, radix: 2)!))
			}
			return output
		}
	}
	
	public var currentDescription: String {
		self.steps[currentStep].description
	}

	//MARK: Initialisation
	public init()
	{
		self.executingLineNo = 0
		self.inExecution = false
		self.isRunning = false
		
		self.memoryValues = [String]()
		self.generalPurposeRegisters = [Cell]()
		self.generalPurposeRegistersIsRecentlyChanged = false
		
		self.addressBus = Cell(cellType: .bus, name: "Address Bus")
		self.dataBus = Cell(cellType: .bus, name: "Data Bus")
//		self.controlBus = Cell(cellType: .bus, name: "Control Bus")
		
		self.programCounter = Cell(cellType: .register, name: "Program Counter (PC)")
		self.currentInstructionRegister = Cell(cellType: .register, name: "CIR")
		self.memoryAddressRegister = Cell(cellType: .register, name: "MAR")
		self.memoryBufferRegister = Cell(cellType: .register, name: "MBR")
		self.statusRegister = Cell(cellType: .statusRegister, name: "Status Register")
		
		self.clock = Cell(cellType: .clock, name: "Clock")
		self.alu = Cell(cellType: .alu, name: "ALU")
		
		self.steps = [(description: String, lineNo: Int, performChanges: () -> Void)]()
		self.currentStep = -1
		
		self.memoryValues = self.setUpMemoryValues()
		self.generalPurposeRegisters = self.setUpGPRegisters()
	}
	
	private enum CodingKeys: CodingKey {
		case executingLineNo
		case inExecution
		
		case memoryValues
		case generalPurposeRegisters
		case generalPurposeRegistersIsRecentlyChanged
		
		case addressBus
		case dataBus
		case controlBus
		
		case programCounter
		case currentIntructionRegister
		case memoryBufferRegister
		case memoryAddressRegister
		case statusRegister
		
		case clock
		case alu
		
		case currentStep
	}
	
	public required init(from decoder: Decoder) throws { //required not needed as class is final
		let container = try decoder.container(keyedBy: CodingKeys.self)
		executingLineNo = try container.decode(Int.self, forKey: .executingLineNo)
//		inExecution = false
		inExecution = try container.decode(Bool.self, forKey: .inExecution)
		isRunning = false
		
		memoryValues = try container.decode([String].self, forKey: .memoryValues)
		generalPurposeRegisters = try container.decode([Cell].self, forKey: .generalPurposeRegisters)
		generalPurposeRegistersIsRecentlyChanged = try container.decode(Bool.self, forKey: .generalPurposeRegistersIsRecentlyChanged)
		
		addressBus = try container.decode(Cell.self, forKey: .addressBus)
		dataBus = try container.decode(Cell.self, forKey: .dataBus)
//		controlBus = try container.decode(Cell.self, forKey: .controlBus)

		programCounter = try container.decode(Cell.self, forKey: .programCounter)
		currentInstructionRegister = try container.decode(Cell.self, forKey: .currentIntructionRegister)
		memoryBufferRegister = try container.decode(Cell.self, forKey: .memoryBufferRegister)
		memoryAddressRegister = try container.decode(Cell.self, forKey: .memoryAddressRegister)
		statusRegister = try container.decode(Cell.self, forKey: .statusRegister)
		
		clock = try container.decode(Cell.self, forKey: .clock)
		alu = try container.decode(Cell.self, forKey: .alu)
		
		steps = [(description: String, lineNo: Int, performChanges: () -> Void)]()
		currentStep = try container.decode(Int.self, forKey: .currentStep)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(executingLineNo, forKey: .executingLineNo)
		try container.encode(inExecution, forKey: .inExecution)
		
		try container.encode(memoryValues, forKey: .memoryValues)
		try container.encode(generalPurposeRegisters, forKey: .generalPurposeRegisters)
		try container.encode(generalPurposeRegistersIsRecentlyChanged, forKey: .generalPurposeRegistersIsRecentlyChanged)
		
		try container.encode(addressBus, forKey: .addressBus)
		try container.encode(dataBus, forKey: .dataBus)
//		try container.encode(controlBus, forKey: .controlBus)

		try container.encode(programCounter, forKey: .programCounter)
		try container.encode(currentInstructionRegister, forKey: .currentIntructionRegister)
		try container.encode(memoryBufferRegister, forKey: .memoryBufferRegister)
		try container.encode(memoryAddressRegister, forKey: .memoryAddressRegister)
		try container.encode(statusRegister, forKey: .statusRegister)
		
		try container.encode(clock, forKey: .clock)
		try container.encode(alu, forKey: .alu)
		
		try container.encode(currentStep, forKey: .currentStep)
		}
	
	private func setUpMemoryValues() -> [String] {
		var output = [String]()
		let binaryValues = "01"
		let memoryLength = 27
		for _ in 0 ..< 128 {
			let randomBitPattern = String((0 ..< memoryLength).map{ _ in binaryValues.randomElement()! })
			output.append(randomBitPattern)
		}
		return output
	}
	
	private func setUpGPRegisters() -> [Cell] {
		var output = [Cell]()
		for _ in 0 ..< 128 {
			output.append(Cell(cellType: .register, name: "GPReg"))
		}
		return output
	}
	
	public func restartExecution(assemblyCode: AssemblyCode) -> Void {
		self.inExecution = false
		self.executingLineNo = 0
		self.currentStep = -1
		
		self.generalPurposeRegistersIsRecentlyChanged = false
		
		self.memoryValues = self.setUpMemoryValues()
		if assemblyCode.checkAssigningMemoryLine(line: assemblyCode.separateByLFToArray()[0]) {
			self.addMemoryValues(line: assemblyCode.separateByLFToArray()[0], context: RunThrough()) //this is not effectively a placeholder, context is not relevant
		}
		self.generalPurposeRegisters = self.setUpGPRegisters()
		self.addressBus = Cell(cellType: .bus, name: "Address Bus")
		self.dataBus = Cell(cellType: .bus, name: "Data Bus")
//		self.controlBus = Cell(cellType: .bus, name: "Control Bus")
		
		self.programCounter = Cell(cellType: .register, name: "Program Counter")
		self.currentInstructionRegister = Cell(cellType: .register, name: "CIR")
		self.memoryAddressRegister = Cell(cellType: .register, name: "MAR")
		self.memoryBufferRegister = Cell(cellType: .register, name: "MBR")
		self.statusRegister = Cell(cellType: .statusRegister, name: "Status Register")
		
		self.clock = Cell(cellType: .clock, name: "Clock")
		self.alu = Cell(cellType: .alu, name: "ALU")
	}
	
	//MARK: Generate Steps
	
	public func generateSteps(assemblyCode: AssemblyCode, machineCode: String) -> Void {
		//called by ContentDescription when textview ends editing with no errors and when decoding a document
		
		//prevents infinite loop on file opening with assembly code containing an error
		if assemblyCode.getAssemblyCodeErrors() != [:] {
			return ()
		}
		
		let generationContext = RunThrough()
		
		//gives self.machineCodeAsArray its values
		self.machineCodeAsArray = CPUSimulatorString(text: machineCode).separateByLFToArray()
		
		//reset steps
		self.steps = [(description: String, lineNo: Int, performChanges: () -> Void)]()
		//loading zero into the program counter

		let assemblyCodeArray = assemblyCode.separateByLFToArray()
		//if memory values are set, add them to memoryValues and remove the memory assigning line
		if assemblyCode.checkAssigningMemoryLine(line: assemblyCodeArray[0]) {
			addMemoryValues(line: assemblyCodeArray[0], context: generationContext)
		}
		
		//find line numbers for all labels
		var labelLineNumbers = [String: Int]()
		let range: Range<Int>
		if assemblyCode.checkAssigningMemoryLine(line: assemblyCodeArray[0]) {
			range = 1 ..< assemblyCodeArray.count
		} else {
			range = 0 ..< assemblyCodeArray.count
		}
		for count in range where assemblyCodeArray[count].contains(":") && !(assemblyCodeArray[count].contains("@")) {
			let label = String(assemblyCodeArray[count][assemblyCodeArray[count].startIndex ..< assemblyCodeArray[count].index(before: assemblyCodeArray[count].endIndex)])
			labelLineNumbers[label] = count
			//the label points to the line of the label but that is skipped over
		}
		
		var currentLineNo = 0
		loop: while true {
			//halts on halt function call (in switch statement) and implicitly after last line is executed here
			if currentLineNo > assemblyCodeArray.count - 1 {
				currentLineNo -= 1 //to stay on current line for halting
				halt(currentLineNo: currentLineNo)
				break
			}
			//skips memory assigning line
			if assemblyCode.checkAssigningMemoryLine(line: assemblyCodeArray[currentLineNo]) {
				currentLineNo += 1
				continue
			}
			//skips blank lines
			if assemblyCodeArray[currentLineNo] == "" {
				currentLineNo += 1
				continue
			}
			//skips comments
			if assemblyCodeArray[currentLineNo][assemblyCodeArray[currentLineNo].startIndex] == "@" {
				currentLineNo += 1
				continue
			}
			//skips label declarations
			if assemblyCodeArray[currentLineNo][assemblyCodeArray[currentLineNo].index(before: assemblyCodeArray[currentLineNo].endIndex)] == ":" {
				currentLineNo += 1
				continue
			}
			//calls function specific to current line
			let lineAsArray = CPUSimulatorString(text: assemblyCodeArray[currentLineNo]).separateBySpaceToArray(removeAssemblyCommas: true)
			let operation = lineAsArray[0]
			let valueArray = [String](lineAsArray[1 ..< lineAsArray.count])
			switch operation {
			case "LDR":
				load(valueArray: valueArray, currentLineNo: currentLineNo, context: generationContext)
				currentLineNo += 1
			case "STR":
				store(valueArray: valueArray, currentLineNo: currentLineNo, context: generationContext)
				currentLineNo += 1
			case "ADD":
				add(valueArray: valueArray, currentLineNo: currentLineNo, context: generationContext)
				currentLineNo += 1
			case "SUB":
				subtract(valueArray: valueArray, currentLineNo: currentLineNo, context: generationContext)
				currentLineNo += 1
			case "MOV":
				copy(valueArray: valueArray, currentLineNo: currentLineNo, context: generationContext)
				currentLineNo += 1
			case "CMP":
				compare(valueArray: valueArray, currentLineNo: currentLineNo, context: generationContext)
				currentLineNo += 1
			case "B":
				currentLineNo = branch(valueArray: valueArray, labelLineNos: labelLineNumbers, currentLineNo: currentLineNo, assemblyCode: assemblyCode, context: generationContext)
			case "BEQ":
				currentLineNo = branchIfEqual(valueArray: valueArray, labelLineNos: labelLineNumbers, currentLineNo: currentLineNo, assemblyCode: assemblyCode, context: generationContext)
			case "BNE":
				currentLineNo = branchIfNotEqual(valueArray: valueArray, labelLineNos: labelLineNumbers, currentLineNo: currentLineNo, assemblyCode: assemblyCode, context: generationContext)
			case "BGT":
				currentLineNo = branchIfGreaterThan(valueArray: valueArray, labelLineNos: labelLineNumbers, currentLineNo: currentLineNo, assemblyCode: assemblyCode, context: generationContext)
			case "BLT":
				currentLineNo = branchIfLessThan(valueArray: valueArray, labelLineNos: labelLineNumbers, currentLineNo: currentLineNo, assemblyCode: assemblyCode, context: generationContext)
			case "AND":
				logicalAnd(valueArray: valueArray, currentLineNo: currentLineNo, context: generationContext)
				currentLineNo += 1
			case "ORR":
				logicalOr(valueArray: valueArray, currentLineNo: currentLineNo, context: generationContext)
				currentLineNo += 1
			case "EOR":
				logicalXor(valueArray: valueArray, currentLineNo: currentLineNo, context: generationContext)
				currentLineNo += 1
			case "MVN":
				logicalNot(valueArray: valueArray, currentLineNo: currentLineNo, context: generationContext)
				currentLineNo += 1
			case "LSL":
				logicalShiftLeft(valueArray: valueArray, currentLineNo: currentLineNo, context: generationContext)
				currentLineNo += 1
			case "LSR":
				logicalShiftRight(valueArray: valueArray, currentLineNo: currentLineNo, context: generationContext)
				currentLineNo += 1
			case "HALT":
				fetchDecode(currentLineNo: currentLineNo)
				halt(currentLineNo: currentLineNo)
				break loop
			default:
//				print("Looping infinitely!")
				break
			}
		}
	}
	
	private func addMemoryValues(line: String, context: RunThrough) -> Void {
		let separableLine = CPUSimulatorString(text: line)
		let lineAsArray = separableLine.separateBySpaceToArray(removeAssemblyCommas: false)
		var currentMemoryIndex = 0
		for count in 0 ..< lineAsArray.count {
			let word = lineAsArray[count]
			let valueInDecimal: Int
			if count != lineAsArray.count - 1 {
				valueInDecimal = Int(String(word[word.startIndex ..< word.index(before: word.endIndex)]))! //verified in checkAssigningMemoryLine
			} else {
				valueInDecimal = Int(word)!
			}
			let valueInBinary = decimalToBinary(decimal: valueInDecimal, minBitLength: 27)
			self.memoryValues[currentMemoryIndex] = valueInBinary
			context.memoryValues[currentMemoryIndex] = valueInBinary
			currentMemoryIndex += 1
			if currentMemoryIndex == 128 {
				break
			}
		}
	}
	
	private func load(valueArray: [String], currentLineNo: Int, context: RunThrough) -> Void {
		let valueReference = valueArray[0]
		let valueReferenceNumber = Int(String(valueReference[valueReference.index(after: valueReference.startIndex) ..< valueReference.endIndex]))!
		let memLocNumber = Int(valueArray[1])!
		let memLocNumberInBinary = decimalToBinary(decimal: memLocNumber, minBitLength: 27)
		
		self.fetchDecode(currentLineNo: currentLineNo)
		var newDescription = "EXECUTE: The Mememory Location \(memLocNumber) is copied to the MAR and appears on the Address Bus."
		var newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
			self.memoryAddressRegister.cellContents = memLocNumberInBinary
			self.addressBus.cellContents = self.memoryAddressRegister.cellContents
			self.memoryAddressRegister.isRecentlyUsed = true
			self.addressBus.isRecentlyUsed = true
		}
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
		
		newDescription = "EXECUTE: The value held at the given address in Data Memory is loaded onto the Data Bus and stored in the MBR."
		newChanges = {
			self.resetIsRecentlyUsed()
			self.dataBus.cellContents = self.memoryValues[memLocNumber]
			self.memoryBufferRegister.cellContents = self.dataBus.cellContents
			self.dataBus.isRecentlyUsed = true
			self.memoryBufferRegister.isRecentlyUsed = true
		}
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
		
		newDescription = "EXECUTE: The value held in the MBR is copied to \(valueReference)."
		newChanges = {
			self.resetIsRecentlyUsed()
			self.generalPurposeRegisters[valueReferenceNumber].cellContents = self.memoryBufferRegister.cellContents
			self.generalPurposeRegistersIsRecentlyChanged = true
			self.generalPurposeRegisters[valueReferenceNumber].isRecentlyUsed = true
			self.memoryBufferRegister.isRecentlyUsed = true
		}
		//temporarily apply some changes now so that other methods are aware of new contents
		context.generalPurposeRegisters[valueReferenceNumber].cellContents = context.memoryValues[memLocNumber]
		
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges)) 
	}
	
	private func store(valueArray: [String], currentLineNo: Int, context: RunThrough) -> Void {
		let valueReference = valueArray[0]
		let value = getValue(reference: valueReference, context: context)
		let valueReferenceNumber = Int(String(valueReference[valueReference.index(after: valueReference.startIndex) ..< valueReference.endIndex]))!
		let memLocNumber = Int(valueArray[1])!
		let memLocNumberInBinary = decimalToBinary(decimal: memLocNumber, minBitLength: 27)
		
		self.fetchDecode(currentLineNo: currentLineNo)
		var newDescription = "EXECUTE: The value stored in \(valueReference) is copied to the MBR and appears on the Data Bus. Simultaneously, the destination memory address is copied to the MAR and appears on the Address Bus."
		var newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
			self.memoryBufferRegister.cellContents = value
			self.dataBus.cellContents = self.memoryBufferRegister.cellContents
			self.memoryAddressRegister.cellContents = memLocNumberInBinary
			self.addressBus.cellContents = self.memoryAddressRegister.cellContents
			self.generalPurposeRegistersIsRecentlyChanged = true
			self.generalPurposeRegisters[valueReferenceNumber].isRecentlyUsed = true
			self.memoryBufferRegister.isRecentlyUsed = true
			self.dataBus.isRecentlyUsed = true
		}
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
		
		newDescription = "EXECUTE: The value on the Data Bus is saved to Memory Location \(memLocNumberInBinary) (\(memLocNumber))."
		newChanges = {
			self.resetIsRecentlyUsed()
			self.memoryValues[memLocNumber] = self.dataBus.cellContents
			self.dataBus.isRecentlyUsed = true
		}
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
		
		//temporarily apply some changes now so that other methods are aware of new contents
		context.memoryValues[memLocNumber] = value
	}
	
	private func add(valueArray: [String], currentLineNo: Int, bitLength: Int = 7, context: RunThrough) -> Void {
		let resultRegister = valueArray[0]
		let resultRegisterNumber = Int(String(resultRegister[resultRegister.index(after: resultRegister.startIndex) ..< resultRegister.endIndex]))!
		let firstValueReference = valueArray[1]
		let firstValue = getValue(reference: firstValueReference, context: context)
		let firstValueReferenceNumber = Int(String(firstValueReference[firstValueReference.index(after: firstValueReference.startIndex) ..< firstValueReference.endIndex]))!
		let secondValueReference = valueArray[2]
		let secondValue = getValue(reference: secondValueReference, context: context)
		let secondValueReferenceNumber = Int(String(secondValueReference[secondValueReference.index(after: secondValueReference.startIndex) ..< secondValueReference.endIndex]))!
		
		let resultInDecimal = binaryToDecimal(binary: firstValue) + binaryToDecimal(binary: secondValue)
		var resultInBinary = decimalToBinary(decimal: resultInDecimal, minBitLength: 27)
		var overflowOccurs = false
		if resultInBinary.count > 27 {
			overflowOccurs = true
			while resultInBinary.count > 27 {
				resultInBinary = String(resultInBinary[resultInBinary.index(after: resultInBinary.startIndex) ..< resultInBinary.endIndex])
			}
		}
		
		self.fetchDecode(currentLineNo: currentLineNo)
		var newDescription: String
		if getOperandTwoType(reference: secondValueReference) == "direct" {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform an ADD operation on the values stored in \(firstValueReference) and \(secondValueReference), and store the result in \(resultRegister)."
		} else {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform an ADD operation on the value stored in \(firstValueReference) and the immediate value \(secondValueReferenceNumber), and store the result in \(resultRegister)."
		}
		if overflowOccurs {
			newDescription += " Overflow has occurred, causing some accuracy to be lost, this is shown in the fifth bit [OV] of the Status Register."
		}
		let newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
			self.generalPurposeRegisters[resultRegisterNumber].cellContents = resultInBinary
			self.alu.cellContents = "Performing ADD"
			self.generalPurposeRegistersIsRecentlyChanged = true
			self.generalPurposeRegisters[resultRegisterNumber].isRecentlyUsed = true
			self.alu.isRecentlyUsed = true
			self.generalPurposeRegisters[firstValueReferenceNumber].isRecentlyUsed = true
			if self.getOperandTwoType(reference: secondValueReference) == "direct" {
				self.generalPurposeRegisters[secondValueReferenceNumber].isRecentlyUsed = true
			}
			if overflowOccurs {
				self.statusRegister.cellContents = String(self.statusRegister.cellContents[self.statusRegister.cellContents.startIndex ..< self.statusRegister.cellContents.index(before: self.statusRegister.cellContents.endIndex)]) + "1"
				self.statusRegister.isRecentlyUsed = true
			}
		}
		//temporarily apply some changes now so that other methods are aware of new contents
		context.generalPurposeRegisters[resultRegisterNumber].cellContents = resultInBinary
		
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
	}
	
	private func subtract(valueArray: [String], currentLineNo: Int, bitLength: Int = 7, context: RunThrough) -> Void {
		let resultRegister = valueArray[0]
		let resultRegisterNumber = Int(String(resultRegister[resultRegister.index(after: resultRegister.startIndex) ..< resultRegister.endIndex]))!
		let firstValueReference = valueArray[1]
		let firstValue = getValue(reference: firstValueReference, context: context)
		let firstValueReferenceNumber = Int(String(firstValueReference[firstValueReference.index(after: firstValueReference.startIndex) ..< firstValueReference.endIndex]))!
		let secondValueReference = valueArray[2]
		let secondValue = getValue(reference: secondValueReference, context: context)
		let secondValueReferenceNumber = Int(String(secondValueReference[secondValueReference.index(after: secondValueReference.startIndex) ..< secondValueReference.endIndex]))!
		
		var resultInDecimal = binaryToDecimal(binary: firstValue) - binaryToDecimal(binary: secondValue)
		var overflowOccurs = false
		if resultInDecimal < 0 {
			overflowOccurs = true
			resultInDecimal = Int(2 ** Double(bitLength)) - 1 + resultInDecimal
		}
		let resultInBinary = decimalToBinary(decimal: resultInDecimal, minBitLength: 27)
		
		self.fetchDecode(currentLineNo: currentLineNo)
		var newDescription: String
		if getOperandTwoType(reference: secondValueReference) == "direct" {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform an SUB operation on the values stored in \(firstValueReference) and \(secondValueReference), and store the result in \(resultRegister)."
		} else {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform an SUB operation on the value stored in \(firstValueReference) and the immediate value \(secondValueReferenceNumber), and store the result in \(resultRegister)."
		}
		if overflowOccurs {
			newDescription += " Overflow has occurred, causing some accuracy to be lost, this is shown in the fifth bit [OV] of the Status Register."
		}
		let newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
			self.generalPurposeRegisters[resultRegisterNumber].cellContents = resultInBinary
			self.alu.cellContents = "Performing SUB"
			self.generalPurposeRegistersIsRecentlyChanged = true
			self.generalPurposeRegisters[resultRegisterNumber].isRecentlyUsed = true
			self.alu.isRecentlyUsed = true
			self.generalPurposeRegisters[firstValueReferenceNumber].isRecentlyUsed = true
			if self.getOperandTwoType(reference: secondValueReference) == "direct" {
				self.generalPurposeRegisters[secondValueReferenceNumber].isRecentlyUsed = true
			}
			if overflowOccurs {
				self.statusRegister.cellContents = String(self.statusRegister.cellContents[self.statusRegister.cellContents.startIndex ..< self.statusRegister.cellContents.index(before: self.statusRegister.cellContents.endIndex)]) + "1"
				self.statusRegister.isRecentlyUsed = true
			}
		}
		//temporarily apply some changes now so that other methods are aware of new contents
		context.generalPurposeRegisters[resultRegisterNumber].cellContents = resultInBinary
		
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
	}
	
	private func copy(valueArray: [String], currentLineNo: Int, context: RunThrough) -> Void {
		let resultRegister = valueArray[0]
		let resultRegisterNumber = Int(String(resultRegister[resultRegister.index(after: resultRegister.startIndex) ..< resultRegister.endIndex]))!
		let valueReference = valueArray[1]
		let value = getValue(reference: valueReference, context: context)
		let valueReferenceNumber = Int(String(valueReference[valueReference.index(after: valueReference.startIndex) ..< valueReference.endIndex]))!
		
		self.fetchDecode(currentLineNo: currentLineNo)
		let newDescription: String
		if getOperandTwoType(reference: valueReference) == "direct" {
			newDescription = "EXECUTE: The Control Unit copies the value stored in \(valueReference) into \(resultRegister)."
		} else {
			newDescription = "EXECUTE: The Control Unit copies the immediate value \(valueReferenceNumber) into \(resultRegister)."
		}
		let newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
			self.generalPurposeRegisters[resultRegisterNumber].cellContents = value
			self.generalPurposeRegisters[resultRegisterNumber].isRecentlyUsed = true
			if self.getOperandTwoType(reference: valueReference) == "direct" {
				self.generalPurposeRegisters[valueReferenceNumber].isRecentlyUsed = true
			}
		}
		//temporarily apply some changes now so that other methods are aware of new contents
		context.generalPurposeRegisters[resultRegisterNumber].cellContents = value
		
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
	}
	
	private func compare(valueArray: [String], currentLineNo: Int, context: RunThrough) -> Void {
		let firstValueReference = valueArray[0]
		let firstValue = getValue(reference: firstValueReference, context: context)
		let firstValueReferenceNumber = Int(String(firstValueReference[firstValueReference.index(after: firstValueReference.startIndex) ..< firstValueReference.endIndex]))!
		let secondValueReference = valueArray[1]
		let secondValue = getValue(reference: secondValueReference, context: context)
		let secondValueReferenceNumber = Int(String(secondValueReference[secondValueReference.index(after: secondValueReference.startIndex) ..< secondValueReference.endIndex]))!

		var result: String?
		if firstValue == secondValue {
			result = "1000"
		} else if binaryToDecimal(binary: firstValue) < binaryToDecimal(binary: secondValue) {
			result = "0101"
		} else { //isGreaterThan
			result = "0110"
		}
		
		self.fetchDecode(currentLineNo: currentLineNo)
		let newDescription: String
		if getOperandTwoType(reference: secondValueReference) == "direct" {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform four Logical Comparisons [EQ][NE][GT][LT] on the values stored in \(firstValueReference) and \(secondValueReference), and update the Status Register with these results."
		} else {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform four Logical Comparisons [EQ][NE][GT][LT] on the value stored in \(firstValueReference) and the immediate value \(secondValueReferenceNumber), and update the Status Register with these results."
		}
		let newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
			self.statusRegister.cellContents = result! + String(self.statusRegister.cellContents[self.statusRegister.cellContents.index(before: self.statusRegister.cellContents.endIndex)])
			self.alu.cellContents = "Performing Logical Comparisons"
			self.statusRegister.isRecentlyUsed = true
			self.alu.isRecentlyUsed = true
			self.generalPurposeRegistersIsRecentlyChanged = true
			self.generalPurposeRegisters[firstValueReferenceNumber].isRecentlyUsed = true
			if self.getOperandTwoType(reference: secondValueReference) == "direct" {
				self.generalPurposeRegisters[secondValueReferenceNumber].isRecentlyUsed = true
			}
		}
		//temporarily apply some changes now so that other methods are aware of new contents
		context.statusRegister.cellContents = result! + String(context.statusRegister.cellContents[context.statusRegister.cellContents.index(before: context.statusRegister.cellContents.endIndex)])
		
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
	}
	
	private func branch(valueArray: [String], labelLineNos: [String: Int], currentLineNo: Int, assemblyCode: AssemblyCode, context: RunThrough) -> Int {
		let label = valueArray[0]
		let possibleNextLineNo = labelLineNos[label]!
		let nextLineNo = getNextExecutableLineNo(lineNo: possibleNextLineNo, forAssemblyCode: assemblyCode)
		var displayedNextLineNo = nextLineNo
		if nextLineNo > assemblyCode.separateByLFToArray().count - 1 {
			//if label is at end of assembly code then display details of current line but return a higher line number to cause halt
			displayedNextLineNo = currentLineNo
		}
		let nextLineNoInBinary = decimalToBinary(decimal: displayedNextLineNo, minBitLength: 27)
		
		self.fetchDecode(currentLineNo: currentLineNo)
		let newDescription = "EXECUTE: The Control Unit branches unconditionally by updating the PC to Instruction Memory location \(nextLineNoInBinary) (\(displayedNextLineNo))."
		let newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
			self.programCounter.cellContents = nextLineNoInBinary
			self.programCounter.isRecentlyUsed = true
		}
		self.steps.append((description: newDescription, lineNo: displayedNextLineNo, performChanges: newChanges))
		
		//temporarily apply some changes now so that other methods are aware of new contents
		context.programCounter.cellContents = nextLineNoInBinary
		
		return nextLineNo
	}
	
	private func branchIfEqual(valueArray: [String], labelLineNos: [String: Int], currentLineNo: Int, assemblyCode: AssemblyCode, context: RunThrough) -> Int {
		let isEqualFlag = String(context.statusRegister.cellContents[context.statusRegister.cellContents.startIndex])
		var nextLineNo = currentLineNo + 1
		var branching = false
		var displayedNextLineNo = nextLineNo
		if isEqualFlag == "1" {
			let label = valueArray[0]
			let possibleNextLineNo = labelLineNos[label]!
			nextLineNo = getNextExecutableLineNo(lineNo: possibleNextLineNo, forAssemblyCode: assemblyCode)
			if nextLineNo > assemblyCode.separateByLFToArray().count - 1 {
				//if label is at end of assembly code then display details of current line but return a higher line number to cause halt
				displayedNextLineNo = currentLineNo
			}
			branching = true
		}
		let nextLineNoInBinary = decimalToBinary(decimal: displayedNextLineNo, minBitLength: 27)
		
		self.fetchDecode(currentLineNo: currentLineNo)
		let newDescription: String
		if branching {
			newDescription = "EXECUTE: The Control Unit checks if the first bit [EQ] of the Status Register is 1. It is, so the PC is updated to Instruction Memory location \(nextLineNoInBinary) (\(displayedNextLineNo))."
		} else {
			newDescription = "EXECUTE: The Control Unit checks if the first bit [EQ] of the Status Register is 1. It is not, so the PC is unchanged."
		}
		let newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
			self.statusRegister.isRecentlyUsed = true
			if branching {
				self.programCounter.cellContents = nextLineNoInBinary
				self.programCounter.isRecentlyUsed = true
			}
		}
		self.steps.append((description: newDescription, lineNo: displayedNextLineNo, performChanges: newChanges))
		
		//temporarily apply some changes now so that other methods are aware of new contents
		context.programCounter.cellContents = nextLineNoInBinary
		
		return nextLineNo
	}
	
	private func branchIfNotEqual(valueArray: [String], labelLineNos: [String: Int], currentLineNo: Int, assemblyCode: AssemblyCode, context: RunThrough) -> Int {
		let isNotEqualFlag = String(context.statusRegister.cellContents[context.statusRegister.cellContents.index(context.statusRegister.cellContents.startIndex, offsetBy: 1)])
		var nextLineNo = currentLineNo + 1
		var branching = false
		var displayedNextLineNo = nextLineNo
		if isNotEqualFlag == "1" {
			let label = valueArray[0]
			let possibleNextLineNo = labelLineNos[label]!
			nextLineNo = getNextExecutableLineNo(lineNo: possibleNextLineNo, forAssemblyCode: assemblyCode)
			if nextLineNo > assemblyCode.separateByLFToArray().count - 1 {
				//if label is at end of assembly code then display details of current line but return a higher line number to cause halt
				displayedNextLineNo = currentLineNo
			}
			branching = true
		}
		let nextLineNoInBinary = decimalToBinary(decimal: displayedNextLineNo, minBitLength: 27)
		
		self.fetchDecode(currentLineNo: currentLineNo)
		let newDescription: String
		if branching {
			newDescription = "EXECUTE: The Control Unit checks if the second bit [NE] of the Status Register is 1. It is, so the PC is updated to Instruction Memory location \(nextLineNoInBinary) (\(displayedNextLineNo))."
		} else {
			newDescription = "EXECUTE: The Control Unit checks if the second bit [NE] of the Status Register is 1. It is not, so the PC is unchanged."
		}
		let newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
			self.statusRegister.isRecentlyUsed = true
			if branching {
				self.programCounter.cellContents = nextLineNoInBinary
				self.programCounter.isRecentlyUsed = true
			}
		}
		self.steps.append((description: newDescription, lineNo: displayedNextLineNo, performChanges: newChanges))
		
		//temporarily apply some changes now so that other methods are aware of new contents
		context.programCounter.cellContents = nextLineNoInBinary
		
		return nextLineNo
	}
	
	private func branchIfGreaterThan(valueArray: [String], labelLineNos: [String: Int], currentLineNo: Int, assemblyCode: AssemblyCode, context: RunThrough) -> Int {
		let isGreaterThanFlag = String(context.statusRegister.cellContents[context.statusRegister.cellContents.index(context.statusRegister.cellContents.startIndex, offsetBy: 2)])
		var nextLineNo = currentLineNo + 1
		var branching = false
		var displayedNextLineNo = nextLineNo
		if isGreaterThanFlag == "1" {
			let label = valueArray[0]
			let possibleNextLineNo = labelLineNos[label]!
			nextLineNo = getNextExecutableLineNo(lineNo: possibleNextLineNo, forAssemblyCode: assemblyCode)
			if nextLineNo > assemblyCode.separateByLFToArray().count - 1 {
				//if label is at end of assembly code then display details of current line but return a higher line number to cause halt
				displayedNextLineNo = currentLineNo
			}
			branching = true
		}
		let nextLineNoInBinary = decimalToBinary(decimal: displayedNextLineNo, minBitLength: 27)
		
		self.fetchDecode(currentLineNo: currentLineNo)
		let newDescription: String
		if branching {
			newDescription = "EXECUTE: The Control Unit checks if the third bit [GT] of the Status Register is 1. It is, so the PC is updated to Instruction Memory location \(nextLineNoInBinary) (\(displayedNextLineNo))."
		} else {
			newDescription = "EXECUTE: The Control Unit checks if the third bit [GT] of the Status Register is 1. It is not, so the PC is unchanged."
		}
		let newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
			self.statusRegister.isRecentlyUsed = true
			if branching {
				self.programCounter.cellContents = nextLineNoInBinary
				self.programCounter.isRecentlyUsed = true
			}
		}
		self.steps.append((description: newDescription, lineNo: displayedNextLineNo, performChanges: newChanges))
		
		//temporarily apply some changes now so that other methods are aware of new contents
		context.programCounter.cellContents = nextLineNoInBinary
		
		return nextLineNo
	}
	
	private func branchIfLessThan(valueArray: [String], labelLineNos: [String: Int], currentLineNo: Int, assemblyCode: AssemblyCode, context: RunThrough) -> Int {
		let isLessThanFlag = String(context.statusRegister.cellContents[context.statusRegister.cellContents.index(context.statusRegister.cellContents.startIndex, offsetBy: 3)])
		var nextLineNo = currentLineNo + 1
		var branching = false
		var displayedNextLineNo = nextLineNo
		if isLessThanFlag == "1" {
			let label = valueArray[0]
			let possibleNextLineNo = labelLineNos[label]!
			nextLineNo = getNextExecutableLineNo(lineNo: possibleNextLineNo, forAssemblyCode: assemblyCode)
			if nextLineNo > assemblyCode.separateByLFToArray().count - 1 {
				//if label is at end of assembly code then display details of current line but return a higher line number to cause halt
				displayedNextLineNo = currentLineNo
			}
			branching = true
		}
		let nextLineNoInBinary = decimalToBinary(decimal: displayedNextLineNo, minBitLength: 27)
		
		self.fetchDecode(currentLineNo: currentLineNo)
		let newDescription: String
		if branching {
			newDescription = "EXECUTE: The Control Unit checks if the fourth bit [LT] of the Status Register is 1. It is, so the PC is updated to Instruction Memory location \(nextLineNoInBinary) (\(displayedNextLineNo))."
		} else {
			newDescription = "EXECUTE: The Control Unit checks if the fourth bit [LT] of the Status Register is 1. It is not, so the PC is unchanged."
		}
		let newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
			self.statusRegister.isRecentlyUsed = true
			if branching {
				self.programCounter.cellContents = nextLineNoInBinary
				self.programCounter.isRecentlyUsed = true
			}
		}
		self.steps.append((description: newDescription, lineNo: displayedNextLineNo, performChanges: newChanges))
		
		//temporarily apply some changes now so that other methods are aware of new contents
		context.programCounter.cellContents = nextLineNoInBinary
		
		return nextLineNo
	}
	
	private func logicalAnd(valueArray: [String], currentLineNo: Int, context: RunThrough) -> Void {
		let resultRegister = valueArray[0]
		let resultRegisterNumber = Int(String(resultRegister[resultRegister.index(after: resultRegister.startIndex) ..< resultRegister.endIndex]))!
		let firstValueReference = valueArray[1]
		let firstValue = getValue(reference: firstValueReference, context: context)
		let secondValueReference = valueArray[2]
		let secondValue = getValue(reference: secondValueReference, context: context)
		let secondValueReferenceNumber = Int(String(secondValueReference[secondValueReference.index(after: secondValueReference.startIndex) ..< secondValueReference.endIndex]))!
		
		var result = ""
		for intIndex in 0 ..< 27 {
			let firstValueCharacter = String(firstValue[firstValue.index(firstValue.startIndex, offsetBy: intIndex)])
			let secondValueCharacter = String(secondValue[firstValue.index(firstValue.startIndex, offsetBy: intIndex)])
			if firstValueCharacter == "1" && secondValueCharacter == "1" {
				result += "1"
			} else {
				result += "0"
			}
		}
		
		self.fetchDecode(currentLineNo: currentLineNo)
		let newDescription: String
		if getOperandTwoType(reference: secondValueReference) == "direct" {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform a Logical AND operation on the values stored in \(firstValueReference) and \(secondValueReference), and store the result in \(resultRegister)."
		} else {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform a Logical AND operation on the value stored in \(firstValueReference) and the immediate value \(secondValueReferenceNumber), and store the result in \(resultRegister)."
		}
		let newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
			self.generalPurposeRegisters[resultRegisterNumber].cellContents = result
			self.alu.cellContents = "Performing Logical AND"
			self.alu.isRecentlyUsed = true
			self.generalPurposeRegistersIsRecentlyChanged = true
			self.generalPurposeRegisters[resultRegisterNumber].isRecentlyUsed = true
			if self.getOperandTwoType(reference: secondValueReference) == "direct" {
				self.generalPurposeRegisters[secondValueReferenceNumber].isRecentlyUsed = true
			}
		}
		//temporarily apply some changes now so that other methods are aware of new contents
		context.generalPurposeRegisters[resultRegisterNumber].cellContents = result
		
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
	}
	
	private func logicalOr(valueArray: [String], currentLineNo: Int, context: RunThrough) -> Void {
		let resultRegister = valueArray[0]
		let resultRegisterNumber = Int(String(resultRegister[resultRegister.index(after: resultRegister.startIndex) ..< resultRegister.endIndex]))!
		let firstValueReference = valueArray[1]
		let firstValue = getValue(reference: firstValueReference, context: context)
		let secondValueReference = valueArray[2]
		let secondValue = getValue(reference: secondValueReference, context: context)
		let secondValueReferenceNumber = Int(String(secondValueReference[secondValueReference.index(after: secondValueReference.startIndex) ..< secondValueReference.endIndex]))!
		
		var result = ""
		for intIndex in 0 ..< 27 {
			let firstValueCharacter = String(firstValue[firstValue.index(firstValue.startIndex, offsetBy: intIndex)])
			let secondValueCharacter = String(secondValue[firstValue.index(firstValue.startIndex, offsetBy: intIndex)])
			if firstValueCharacter == "1" || secondValueCharacter == "1" {
				result += "1"
			} else {
				result += "0"
			}
		}
		
		self.fetchDecode(currentLineNo: currentLineNo)
		let newDescription: String
		if getOperandTwoType(reference: secondValueReference) == "direct" {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform a Logical OR operation on the values stored in \(firstValueReference) and \(secondValueReference), and store the result in \(resultRegister)."
		} else {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform a Logical OR operation on the value stored in \(firstValueReference) and the immediate value \(secondValueReferenceNumber), and store the result in \(resultRegister)."
		}
		let newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
			self.generalPurposeRegisters[resultRegisterNumber].cellContents = result
			self.alu.cellContents = "Performing Logical OR"
			self.alu.isRecentlyUsed = true
			self.generalPurposeRegistersIsRecentlyChanged = true
			self.generalPurposeRegisters[resultRegisterNumber].isRecentlyUsed = true
			if self.getOperandTwoType(reference: secondValueReference) == "direct" {
				self.generalPurposeRegisters[secondValueReferenceNumber].isRecentlyUsed = true
			}
		}
		//temporarily apply some changes now so that other methods are aware of new contents
		context.generalPurposeRegisters[resultRegisterNumber].cellContents = result
		
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
	}
	
	private func logicalXor(valueArray: [String], currentLineNo: Int, context: RunThrough) -> Void {
		let resultRegister = valueArray[0]
		let resultRegisterNumber = Int(String(resultRegister[resultRegister.index(after: resultRegister.startIndex) ..< resultRegister.endIndex]))!
		let firstValueReference = valueArray[1]
		let firstValue = getValue(reference: firstValueReference, context: context)
		let secondValueReference = valueArray[2]
		let secondValue = getValue(reference: secondValueReference, context: context)
		let secondValueReferenceNumber = Int(String(secondValueReference[secondValueReference.index(after: secondValueReference.startIndex) ..< secondValueReference.endIndex]))!
		
		var result = ""
		for intIndex in 0 ..< 27 {
			let firstValueCharacter = String(firstValue[firstValue.index(firstValue.startIndex, offsetBy: intIndex)])
			let secondValueCharacter = String(secondValue[firstValue.index(firstValue.startIndex, offsetBy: intIndex)])
			if (firstValueCharacter == "1" && secondValueCharacter == "0")  || (firstValueCharacter == "0" && secondValueCharacter == "1") {
				result += "1"
			} else {
				result += "0"
			}
		}
		
		self.fetchDecode(currentLineNo: currentLineNo)
		let newDescription: String
		if getOperandTwoType(reference: secondValueReference) == "direct" {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform a Logical XOR operation on the values stored in \(firstValueReference) and \(secondValueReference), and store the result in \(resultRegister)."
		} else {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform a Logical XOR operation on the value stored in \(firstValueReference) and the immediate value \(secondValueReferenceNumber), and store the result in \(resultRegister)."
		}
		let newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
			self.generalPurposeRegisters[resultRegisterNumber].cellContents = result
			self.alu.cellContents = "Performing Logical XOR"
			self.alu.isRecentlyUsed = true
			self.generalPurposeRegistersIsRecentlyChanged = true
			self.generalPurposeRegisters[resultRegisterNumber].isRecentlyUsed = true
			if self.getOperandTwoType(reference: secondValueReference) == "direct" {
				self.generalPurposeRegisters[secondValueReferenceNumber].isRecentlyUsed = true
			}
		}
		//temporarily apply some changes now so that other methods are aware of new contents
		context.generalPurposeRegisters[resultRegisterNumber].cellContents = result
		
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
	}
	
	private func logicalNot(valueArray: [String], currentLineNo: Int, context: RunThrough) -> Void {
		//doesn't use utf8, can't convert String to utf8 and would need utf7
		let resultRegister = valueArray[0]
		let resultRegisterNumber = Int(String(resultRegister[resultRegister.index(after: resultRegister.startIndex) ..< resultRegister.endIndex]))!
		let valueReference = valueArray[1]
		let value = getValue(reference: valueReference, context: context)
		let valueReferenceNumber = Int(String(valueReference[valueReference.index(after: valueReference.startIndex) ..< valueReference.endIndex]))!
		
		var result = ""
		for character in value {
			if character == "0" {
				result += "1"
			} else {
				result += "0"
			}
		}
		
		self.fetchDecode(currentLineNo: currentLineNo)
		let newDescription: String
		if getOperandTwoType(reference: valueReference) == "direct" {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform a Logical NOT operation on the value stored in \(valueReference) and store the result in \(resultRegister)."
		} else {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform a Logical NOT operation on the immediate value \(valueReferenceNumber) and store the result in \(resultRegister)."
		}
		let newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
			self.generalPurposeRegisters[resultRegisterNumber].cellContents = result
			self.alu.cellContents = "Performing Logical NOT"
			self.alu.isRecentlyUsed = true
			self.generalPurposeRegistersIsRecentlyChanged = true
			self.generalPurposeRegisters[resultRegisterNumber].isRecentlyUsed = true
			if self.getOperandTwoType(reference: valueReference) == "direct" {
				self.generalPurposeRegisters[valueReferenceNumber].isRecentlyUsed = true
			}
		}
		//temporarily apply some changes now so that other methods are aware of new contents
		context.generalPurposeRegisters[resultRegisterNumber].cellContents = result
		
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
	}
	
	private func logicalShiftLeft(valueArray: [String], currentLineNo: Int, context: RunThrough) -> Void {
		let resultRegister = valueArray[0]
		let resultRegisterNumber = Int(String(resultRegister[resultRegister.index(after: resultRegister.startIndex) ..< resultRegister.endIndex]))!
		let valueReference = valueArray[1]
		let value = getValue(reference: valueReference, context: context)
		let valueReferenceNumber = Int(String(valueReference[valueReference.index(after: valueReference.startIndex) ..< valueReference.endIndex]))!
		let shiftByReference = valueArray[2]
		let shiftByReferenceNumber = Int(String(shiftByReference[shiftByReference.index(after: shiftByReference.startIndex) ..< shiftByReference.endIndex]))!
		let shiftByInDecimal = getValue(reference: shiftByReference, context: context)
		let shiftBy = binaryToDecimal(binary: shiftByInDecimal)
		
		let resultInDecimal = binaryToDecimal(binary: value) * Int(2 ** Double(shiftBy))
		var resultInBinary = decimalToBinary(decimal: resultInDecimal, minBitLength: 27)
		var overflowOccurs = false
		while resultInBinary.count > 27 {
			let bitLost = String(resultInBinary[resultInBinary.startIndex])
			resultInBinary = String(resultInBinary[resultInBinary.index(after: resultInBinary.startIndex) ..< resultInBinary.endIndex])
			if bitLost == "1" {
				overflowOccurs = true
			}
		}
		
		self.fetchDecode(currentLineNo: currentLineNo)
		var newDescription: String
		if getOperandTwoType(reference: valueReference) == "direct" {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform a Logical Shift Left operation on the value stored in \(valueReference) by the value stored in \(shiftByReference) and store the result in \(resultRegister)."
		} else {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform a Logical Shift Left operation on the value stored in \(valueReference) by the immediate value \(shiftByReferenceNumber) and store the result in \(resultRegister)."
		}
		if overflowOccurs {
			newDescription += " Overflow has occurred, causing some accuracy to be lost, this is shown in the fifth bit [OV] of the Status Register."
		}
		let newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
			self.generalPurposeRegisters[resultRegisterNumber].cellContents = resultInBinary
			self.alu.cellContents = "Performing LSL"
			self.alu.isRecentlyUsed = true
			self.generalPurposeRegistersIsRecentlyChanged = true
			self.generalPurposeRegisters[resultRegisterNumber].isRecentlyUsed = true
			self.generalPurposeRegisters[valueReferenceNumber].isRecentlyUsed = true
			if self.getOperandTwoType(reference: shiftByReference) == "direct" {
				self.generalPurposeRegisters[shiftByReferenceNumber].isRecentlyUsed = true
			}
			if overflowOccurs {
				self.statusRegister.cellContents = String(self.statusRegister.cellContents[self.statusRegister.cellContents.startIndex ..< self.statusRegister.cellContents.index(before: self.statusRegister.cellContents.endIndex)]) + "1"
				self.statusRegister.isRecentlyUsed = true
			}
		}
		//temporarily apply some changes now so that other methods are aware of new contents
		context.generalPurposeRegisters[resultRegisterNumber].cellContents = resultInBinary
		
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
	}
	
	private func logicalShiftRight(valueArray: [String], currentLineNo: Int, context: RunThrough) -> Void {
		let resultRegister = valueArray[0]
		let resultRegisterNumber = Int(String(resultRegister[resultRegister.index(after: resultRegister.startIndex) ..< resultRegister.endIndex]))!
		let valueReference = valueArray[1]
		let value = getValue(reference: valueReference, context: context)
		let valueReferenceNumber = Int(String(valueReference[valueReference.index(after: valueReference.startIndex) ..< valueReference.endIndex]))!
		let shiftByReference = valueArray[2]
		let shiftByReferenceNumber = Int(String(shiftByReference[shiftByReference.index(after: shiftByReference.startIndex) ..< shiftByReference.endIndex]))!
		let shiftByInDecimal = getValue(reference: shiftByReference, context: context)
		let shiftBy = binaryToDecimal(binary: shiftByInDecimal)
		
		let resultInDecimal = Int(floor(Double(binaryToDecimal(binary: value)) / (2 ** Double(shiftBy))))
		let resultInBinary = decimalToBinary(decimal: resultInDecimal, minBitLength: 27)
		
		self.fetchDecode(currentLineNo: currentLineNo)
		let newDescription: String
		if getOperandTwoType(reference: valueReference) == "direct" {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform a Logical Shift Right operation on the value stored in \(valueReference) by the value stored in \(shiftByReference) and store the result in \(resultRegister)."
		} else {
			newDescription = "EXECUTE: The Control Unit signals the ALU to perform a Logical Shift Right operation on the value stored in \(valueReference) by the immediate value \(shiftByReferenceNumber) and store the result in \(resultRegister)."
		}
		let newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
			self.generalPurposeRegisters[resultRegisterNumber].cellContents = resultInBinary
			self.alu.cellContents = "Performing LSR"
			self.alu.isRecentlyUsed = true
			self.generalPurposeRegistersIsRecentlyChanged = true
			self.generalPurposeRegisters[resultRegisterNumber].isRecentlyUsed = true
			self.generalPurposeRegisters[valueReferenceNumber].isRecentlyUsed = true
			if self.getOperandTwoType(reference: shiftByReference) == "direct" {
				self.generalPurposeRegisters[shiftByReferenceNumber].isRecentlyUsed = true
			}
		}
		//temporarily apply some changes now so that other methods are aware of new contents
		context.generalPurposeRegisters[resultRegisterNumber].cellContents = resultInBinary
		
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
	}
	
	private func halt(currentLineNo: Int) -> Void {
		let newDescription = "EXECUTE: The program has halted."
		let newChanges: () -> Void = {
			self.resetIsRecentlyUsed()
		}
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
	}
	
	private func fetchDecode(currentLineNo: Int) -> Void {
		var newDescription = "FETCH: The address of the next instruction is copied from the PC to the MAR and appears on the Address Bus."
		var newChanges: () -> Void = {
			self.programCounter.cellContents = self.decimalToBinary(decimal: currentLineNo, minBitLength: 27)
			self.resetIsRecentlyUsed()
			self.memoryAddressRegister.cellContents = self.programCounter.cellContents
			self.addressBus.cellContents = self.memoryAddressRegister.cellContents
			self.programCounter.isRecentlyUsed = true
			self.memoryAddressRegister.isRecentlyUsed = true
			self.addressBus.isRecentlyUsed = true
		}
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
		
		newDescription = "FETCH: The instruction held at the given address in Instruciton Memory is loaded onto the Data Bus and stored in the MBR. Simultaneously, the PC is incremented by one."
		newChanges = {
			self.resetIsRecentlyUsed()
			self.dataBus.cellContents = self.machineCodeAsArray[self.binaryToDecimal(binary: self.addressBus.cellContents)]
			self.memoryBufferRegister.cellContents = self.dataBus.cellContents
			self.programCounter.cellContents = self.decimalToBinary(decimal: Int(self.programCounter.cellContentsInDecimal)! + 1, minBitLength: 27)
			self.dataBus.isRecentlyUsed = true
			self.memoryBufferRegister.isRecentlyUsed = true
			self.programCounter.isRecentlyUsed = true
		}
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
		
		newDescription = "FETCH: The contents of the MBR are copied to the CIR so that the MBR can be used in execution."
		newChanges = {
			self.resetIsRecentlyUsed()
			self.currentInstructionRegister.cellContents = self.memoryBufferRegister.cellContents
			self.memoryBufferRegister.isRecentlyUsed = true
			self.currentInstructionRegister.isRecentlyUsed = true
		}
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
		
		newDescription = "DECODE: The instruction held in the CIR is decoded by the Control Unit. This includes separating the instruction into the Opcode and Operand(s)."
		newChanges = {
			self.resetIsRecentlyUsed()
			self.currentInstructionRegister.isRecentlyUsed = true
		}
		self.steps.append((description: newDescription, lineNo: currentLineNo, performChanges: newChanges))
	}
	
	private func resetIsRecentlyUsed() -> Void {
		generalPurposeRegistersIsRecentlyChanged = false
		addressBus.isRecentlyUsed = false
		dataBus.isRecentlyUsed = false
//		controlBus.isRecentlyUsed = false
		programCounter.isRecentlyUsed = false
		currentInstructionRegister.isRecentlyUsed = false
		memoryBufferRegister.isRecentlyUsed = false
		memoryAddressRegister.isRecentlyUsed = false
		statusRegister.isRecentlyUsed = false
		clock.isRecentlyUsed = false
		alu.isRecentlyUsed = false
		for generalPurposeRegister in generalPurposeRegisters {
			generalPurposeRegister.isRecentlyUsed = false
		}
		
		//also resets alu contents as operation will have finished
		alu.cellContents = "No Operation"
		//also resets overflow status in status register as operation will have finished
		self.statusRegister.cellContents = String(self.statusRegister.cellContents[self.statusRegister.cellContents.startIndex ..< self.statusRegister.cellContents.index(before: self.statusRegister.cellContents.endIndex)]) + "0"
	}
	
	private func getValue(reference: String, context: RunThrough) -> String {
		// takes a register, memory reference or immediate value and determines the binary value stored there
		let firstCharacter = String(reference[reference.startIndex])
		var result: String?
		if firstCharacter == "R" {
			let registerNumber = Int(reference[reference.index(after: reference.startIndex) ..< reference.endIndex])!
			result = context.generalPurposeRegisters[registerNumber].cellContents
		} else {
			let decimalResult = Int(String(reference[reference.index(after: reference.startIndex) ..< reference.endIndex]))!
			result = decimalToBinary(decimal: decimalResult, minBitLength: 27)
		}
		return result!
	}
	
	private func getOperandTwoType(reference: String) -> String {
		if reference.first == "R" {
			return "direct"
		}
		return "immediate"
	}
	
	private func getNextExecutableLineNo(lineNo: Int, forAssemblyCode assemblyCode: AssemblyCode) -> Int {
		let assemblyCodeArray = assemblyCode.separateByLFToArray()
		var nextExecutableLineNo = lineNo
		var lineIsExecutable = false
		while !(lineIsExecutable) {
			//if label is at end of assembly code
			if nextExecutableLineNo > assemblyCodeArray.count - 1 {
				return nextExecutableLineNo
				//causes halt at start of loop in generateSteps
			}
			//skips blank lines
			if assemblyCodeArray[nextExecutableLineNo] == "" {
				nextExecutableLineNo += 1
				continue
			}
			//skips comments
			if assemblyCodeArray[nextExecutableLineNo][assemblyCodeArray[nextExecutableLineNo].startIndex] == "@" {
				nextExecutableLineNo += 1
				continue
			}
			//skips label declarations
			if assemblyCodeArray[nextExecutableLineNo][assemblyCodeArray[nextExecutableLineNo].index(before: assemblyCodeArray[nextExecutableLineNo].endIndex)] == ":" {
				nextExecutableLineNo += 1
				continue
			}
			lineIsExecutable = true
		}
		return nextExecutableLineNo
	}
	
	private func binaryToDecimal(binary: String) -> Int {
		Int(binary, radix: 2)!
	}
	
	public func decimalToBinary(decimal: Int, minBitLength: Int = 7) -> String {
		//public to be accessible to ContentDescription to set new program counter value
		if minBitLength < 1 || decimal < 0 {
			return ""
		}
		var result = String(decimal, radix: 2)
		while result.count < minBitLength {
			result = "0" + result
		}
		return result
	}
}
