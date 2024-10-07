//
//  AssemblyCode.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 11/12/2019.
//  Copyright © 2019 Andrew Palombo. All rights reserved.
//

import UIKit

public class AssemblyCode: CPUSimulatorString {
    
	//MARK: Assembly Code
    public func getAssemblyCodeErrors() -> [Int: String] {
        // text is automatically uppercased
        let assemblyCodeArray = self.separateByLFToArray()
        
        var errors: [Int: String] = [:]
		
		// maximum line limit: 10,000
		if assemblyCodeArray.count > 10_000 {
			errors[0] = "The maximum line limit is 10,000."
			return errors
		}
        
        // get all the branches that have been created by a colon
        var branches: [String] = []
		var repeatedLabels = [Int: String]()
        for currentIndex in assemblyCodeArray.startIndex ..< assemblyCodeArray.endIndex {
            let potentialLabelDeclaration = CPUSimulatorString(text: assemblyCodeArray[currentIndex]) // needed to apply separateBy...
			if checkLabelDeclaration(potentialLabelDeclaration) {
                let labelName = String(potentialLabelDeclaration.text.dropLast())
				if branches.contains(labelName) {
					repeatedLabels[currentIndex] = labelName
				} else {
					branches.append(labelName)
				}
            }
        }
        
        // check line by line
		let range: Range<Int>?
		if checkAssigningMemoryLine(line: assemblyCodeArray[0]) {
			range = 1 ..< assemblyCodeArray.count
		} else {
			range = 0 ..< assemblyCodeArray.count
		}
		for lineNumber in range! {
            // note that the line below will cause a crash if line has not been found in code
			let checkedLineResults = checkOneLineOfCode(lineString: assemblyCodeArray[lineNumber], branches: branches, lineNumber: lineNumber, repeatedLabels: repeatedLabels)
            let valid = checkedLineResults.valid
            let message = checkedLineResults.message
            
            // here we add an error by its line number to the dictionary of errors
            if !(valid) {
                errors[lineNumber] = message
            }
		}
        return errors
    }
    
	private func checkOneLineOfCode(lineString: String, branches: [String], lineNumber: Int, repeatedLabels: [Int: String]) -> (valid: Bool, message: String?) {
        
		if repeatedLabels[lineNumber] != nil {
			return (false, "Line \(lineNumber): redeclaration of '\(repeatedLabels[lineNumber]!)'.")
		}
		
        if lineString == "" {
            return (true, nil)
        }
        if lineString[lineString.startIndex] == "@" {
            return (true, nil)
        }
		
		// check that tabs (if any) are followed by code
		var onlyTabs = true
		for char in lineString where char != "\t" {
			onlyTabs = false
		}
		if onlyTabs {
			return (false, "Line \(lineNumber): tab(s) must be followed by code.")
		}
        
        let line = CPUSimulatorString(text: lineString)
        var lineAsArray = line.separateBySpaceToArray(removeAssemblyCommas: false)
		if lineAsArray == [""] {
			return (true, nil)
		}
        let function = lineAsArray[0]
        
        // check that line is not too long
        if lineAsArray.count > 4 {
            return (false, "Line \(lineNumber): too many arguments.")
        }
		
		if !(checkSpaces(lineAsArray: lineAsArray)) {
			return (false, "Line \(lineNumber): too many spaces.")
		}
		if checkCommas(lineAsArray: lineAsArray) {
			lineAsArray = line.separateBySpaceToArray(removeAssemblyCommas: true)
		} else {
			return (false, "Line \(lineNumber): incorrect use of commas.")
		}
        
        // either check functional syntax (LDR, STR, B, BEQ are functions) or introduce new branch
        let lastCharacter = String(lineAsArray[0].dropFirst(lineAsArray[0].count - 1)) // drops all but the last character
        if lastCharacter != ":" {
            // this is not trying to be a label
            // check that only required arguments are given for specific function
            let appropriateArguments = ["registerMemory": ["LDR", "STR"],
                                        "registerRegisterOperand": ["ADD", "SUB", "AND", "ORR", "EOR", "LSL", "LSR"],
                                        "registerOperand": ["MOV", "CMP", "MVN"],
                                        "label": ["B", "BEQ", "BNE", "BLT", "BGT"],
                                        "none": ["HALT"]]
            var foundInAppropriateArguments = false
            for (key, values) in appropriateArguments {
                if values.contains(function) {
                    // uses separate function to check for specific correctness
                    if !(checkFunctionArguments(argumentTypes: key, lineAsArray: lineAsArray)) {
                        return (false, "Line \(lineNumber): unrecognised functional syntax for function '\(function)'.")
                    }
					if !(checkNumbers(lineAsArray: lineAsArray)) {
						return (false, "Line \(lineNumber): number given is outside of range 0 to 127.")
					}
                    foundInAppropriateArguments = true
                }
            }
            if !(foundInAppropriateArguments) {
                // this is executed if not a label: or a recognised function
                return (false, "Line \(lineNumber): unrecognised function '\(function)'.")
            }
            
            if appropriateArguments["label"]!.contains(function) {
                // check branching
                let branchLabel = lineAsArray[1]
                if !(branches.contains(branchLabel)) {
                    return (false, "Line \(lineNumber): the label '\(branchLabel)' is not defined.")
                }
            }
		} else if !(checkLabelDeclaration(line)) {
			// trying to be a label but isn't
			return (false, "Line \(lineNumber): label is not alphanumeric.")
		}
        return (true, nil)
    }
	
	public func checkAssigningMemoryLine(line: String) -> Bool {
		if line.isEmpty {
			return false
		}
		let separableLine = CPUSimulatorString(text: line)
		let lineAsArray = separableLine.separateBySpaceToArray(removeAssemblyCommas: false)
		var valid = true
		for count in 0 ..< lineAsArray.count {
			let word = lineAsArray[count]
			if word.isEmpty {
				return false
			}
			if count != lineAsArray.count - 1 {
				let potentialNumber = Int(String(word[word.startIndex ..< word.index(before: word.endIndex)]))
				let potentialComma = String(word[word.index(before: word.endIndex)])
				if potentialNumber == nil || potentialComma != "," {
					valid = false
					break
				}
			} else { //for last value
				let potentialNumber = Int(word)
				if potentialNumber == nil {
					valid = false
				} else if potentialNumber! < 0 || potentialNumber! > 4_194_303 {
					valid = false
				}
			}
		}
		return valid
	}
    
    private func checkFunctionArguments(argumentTypes: String, lineAsArray: [String]) -> Bool {
        switch argumentTypes {
        case "registerMemory" :
            if lineAsArray.count == 3 {
                if !(checkIsRegister(value: lineAsArray[1])) || !(checkIsMemory(value: lineAsArray[2])){
                    return false
                }
            } else {
                return false
            }
        case "registerRegisterOperand" :
            if lineAsArray.count == 4 {
                if !(checkIsRegister(value: lineAsArray[1])) || !(checkIsRegister(value: lineAsArray[2])) || !(checkIsOperand(value: lineAsArray[3])) {
                    return false
                }
            } else {
                return false
            }
        case "registerOperand" :
            if lineAsArray.count == 3 {
                if !(checkIsRegister(value: lineAsArray[1])) || !(checkIsOperand(value: lineAsArray[2]))  {
                    return false
                }
            } else {
                return false
            }
        case "label" :
            if lineAsArray.count != 2 {
                return false
                // will only say 'invalid functional syntax' if wrong length, else the possible error is unrecognised branch label
            }
        case "none" :
            if lineAsArray.count != 1 {
                return false
            }
        default :
            break
        }
        
        return true
    }
	
	private func checkLabelDeclaration(_ potentialLabelDeclaration: CPUSimulatorString) -> Bool {
		if potentialLabelDeclaration.separateBySpaceToArray(removeAssemblyCommas: false).count != 1 {
			return false
		}
		if potentialLabelDeclaration.text.last != ":" {
			return false
		}
		let potentialLabel = String(potentialLabelDeclaration.text.dropLast())
		if potentialLabel.isEmpty {
			return false
		}
		if potentialLabel.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil {
			return false
		}
		return true
	}
	
	private func checkSpaces(lineAsArray: [String]) -> Bool {
		//also checks tabs \t
		for value in lineAsArray where value == "" {
			return false
		}
		return true
	}
	
	private func checkCommas(lineAsArray: [String]) -> Bool {
		if lineAsArray.count == 0 {
			return true
		}
		if lineAsArray.first!.last! == "," || lineAsArray.last!.last! == "," {
			return false
		}
		if lineAsArray.count > 2 {
			for i in 1 ..< (lineAsArray.count - 1) {
				if lineAsArray[i].last! != "," {
					return false
				}
			}
		}
		if lineAsArray.count == 1 {
			if lineAsArray[0].contains(",") {
				return false
			} else {
				return true
			}
		}
		let correctNoCommas = lineAsArray.count - 2
		var actualNoCommas = 0
		for value in lineAsArray {
			for char in value where char == "," {
				actualNoCommas += 1
			}
		}
		if actualNoCommas != correctNoCommas {
			return false
		}
		return true
	}
	
	private func checkNumbers(lineAsArray: [String]) -> Bool {
		//called if not a label and everything else with statement is fine
		if ["B", "BEQ", "BNE", "BGT", "BLT", "HALT"].contains(lineAsArray[0]) {
			return true
		}
		for i in 1 ..< lineAsArray.count {
			var number = -1
			if lineAsArray[i].first! == "R" || lineAsArray[i].first! == "#" {
				number = Int(String(lineAsArray[i].dropFirst()))!
			} else {
				number = Int(lineAsArray[i])!
			}
			if (number > 127) || (number < 0) {
				return false
			}
		}
		return true
	}
    
    private func checkIsRegister(value: String) -> Bool {
		if value.count < 2 {
			return false
		}
        let firstCharacter = value.dropLast(value.count - 1)
        let suffix = String(value.dropFirst())
        if firstCharacter == "R" && Int(suffix) != nil {
			return true
//			return (Int(suffix)! <= 127) && (Int(suffix)! >= 0) ? true : false
        }
        return false
    }

    private func checkIsMemory(value: String) -> Bool {
        if Int(value) != nil {
			return true
//            return (Int(value)! <= 127) && (Int(value)! >= 0) ? true : false
        }
        return false
    }

    private func checkIsOperand(value: String) -> Bool {
		if value.count < 2 {
			return false
		}
        if checkIsRegister(value: value) {
            return true
        }
        let firstCharacter = value.dropLast(value.count - 1)
        let suffix = String(value.dropFirst())
        if firstCharacter == "#" && Int(suffix) != nil {
			return true
//            return (Int(suffix)! <= 127) && (Int(suffix)! >= 0) ? true : false
        }
        return false
    }
	
	//MARK: Machine Code
    
	public func assemblyToMachine() -> String {
        // 'operand2' is the operand that is either immediate or direct
        let operand2InSecondPosition = ["MOV", "CMP", "MVN"]
        let operand2InThirdPosition = ["ADD", "SUB", "AND", "ORR", "EOR", "LSL", "LSR"]
        
        let operationToBinaryRepresentation: [String: String] = ["LDR": "00000",
                                                                 "STR": "00001",
                                                                 "ADD": "00010",
                                                                 "SUB": "00011",
                                                                 "MOV": "00100",
                                                                 "CMP": "00101",
                                                                 "B": "00110",
                                                                 "BEQ": "00111",
                                                                 "BNE": "01000",
                                                                 "BGT": "01001",
                                                                 "BLT": "01010",
                                                                 "AND": "01011",
                                                                 "ORR": "01100",
                                                                 "EOR": "01101",
                                                                 "MVN": "01110",
                                                                 "LSL": "01111",
                                                                 "LSR": "10000",
                                                                 "HALT": "10001"]
        
        
        
        // assembly code is automatically uppercased
        let extraction = extractLabelsFromAssemblyCode() // also removes blank lines and labels that are succeeded by colons
        let labels = extraction.labels
		let textWithoutLabels = CPUSimulatorString(text: extraction.newAssemblyCode)

        var assemblyCodeArray = textWithoutLabels.separateByLFToArray()
		var machineCode: String = ""
		if checkAssigningMemoryLine(line: assemblyCodeArray[0]) {
			//assigning memory values are not part of machine code
			assemblyCodeArray.remove(at: 0)
			machineCode += "\n"
		}
        for lineString in assemblyCodeArray {
            var machineCodeLine: String = ""
            
            if lineString.count == 0 {
                machineCode += "\n"
                continue
            }
            
            if lineString[lineString.startIndex] == "@" {
                machineCode += "\n"
                continue
            }
            
            // Operation
            let line = CPUSimulatorString(text: lineString)
            let lineAsArray = line.separateBySpaceToArray(removeAssemblyCommas: true)
			if lineAsArray == [""] {
				machineCode += "\n"
				continue
			}
            let operation = lineAsArray[0]
            machineCodeLine += operationToBinaryRepresentation[operation]!
            // error here if operation is not found in the large dictionary above
            
            let branchingOperations = ["B", "BEQ", "BNE", "BGT", "BLT"]
            if !(branchingOperations.contains(operation)) {
                // Direct/Indirect
                if operand2InSecondPosition.contains(operation) {
                    let operand2 = lineAsArray[2]
                    if operand2[operand2.startIndex] == "#" {
                        machineCodeLine += "1"
                    } else {
                        machineCodeLine += "0"
                    }
                } else if operand2InThirdPosition.contains(operation) {
                    let operand2 = lineAsArray[3]
                    if operand2[operand2.startIndex] == "#" {
                        machineCodeLine += "1"
                    } else {
                        machineCodeLine += "0"
                    }
                } else {
                    machineCodeLine += "0"
                }
                
                // Destination registry, operand(s), memory reference
                // any accompanying Rs or #s are ignored and only the number stored
                for operand in lineAsArray.dropFirst() {
                    if operand[operand.startIndex] == "R" || operand[operand.startIndex] == "#" {
                        let newOperandRange = operand.index(operand.startIndex, offsetBy: 1) ..< operand.endIndex
                        let newOperand = String(operand[newOperandRange])
                        let binaryOperand = decimalToBinary(value: Int(newOperand)!, maxBitLength: 7)
                        machineCodeLine += binaryOperand!
                    } else {
                        let binaryOperand = decimalToBinary(value: Int(operand)!, maxBitLength: 7)
                        machineCodeLine += binaryOperand!
                    }
                }
                
            } else {
                // Branching
                let labelPosition = lineAsArray.index(lineAsArray.startIndex, offsetBy: 1)
                let branchingLabel = lineAsArray[labelPosition]
                var binaryLabelNumber: String?
                for label in labels where label.labelName == branchingLabel {
                    let lineNumber = label.lineNumber
                    binaryLabelNumber = String(decimalToBinary(value: lineNumber, maxBitLength: 22)!)
                }
                machineCodeLine += binaryLabelNumber!
            }
            
            while machineCodeLine.count < 27 {
                machineCodeLine += "0"
            }
            
            machineCode += machineCodeLine
            machineCode += "\n"
        }
		
		//check machine code is not just blank lines (e.g. from only comments)
		var isOnlyLFs = true
		for character in machineCode {
			if character != "\n" {
				isOnlyLFs = false
			}
		}
		if isOnlyLFs {
			return ""
		}
        
        return machineCode
    }
    
    private func extractLabelsFromAssemblyCode() -> (labels: [(lineNumber: Int, labelName: String)], newAssemblyCode: String) {
        var labels = [(lineNumber: Int, labelName: String)]()
        let assemblyCodeSeparatedByLF = self.separateByLFToArray()
        
        var newAssemblyCode = ""
        var lineNumber = 0
		for line in assemblyCodeSeparatedByLF {
            if checkLabelDeclaration(CPUSimulatorString(text: line)) {
                let labelNameRange = line.startIndex...line.index(line.endIndex, offsetBy: -2)
                let labelName = String(line[labelNameRange])
                labels.append((lineNumber: lineNumber, labelName: labelName))
				
				newAssemblyCode += "\n" //new
				lineNumber += 1
            } else {
                newAssemblyCode += line + "\n"
                lineNumber += 1
            }
        }
        // to remove the last blank line
        newAssemblyCode = String(newAssemblyCode.dropLast())
        
        return (labels, newAssemblyCode)
    }
    
    private func decimalToBinary(value: Int, maxBitLength: Int) -> String? {
        // returns nil if not possible, rather than truncate because too large of a number
		// should be guarded against
        
        if value < 0 {
            return nil
        }
        
        let largestPossibleValueGivenBitLength = Double(2) ** Double(maxBitLength) - 1
        if Double(value) <= largestPossibleValueGivenBitLength {
            var binaryValue: String = ""
            var workingValue = value
            for subtract in 0 ... (maxBitLength - 1) {
                let index = maxBitLength - 1 - subtract
                if Double(workingValue) - 2 ** Double(index) >= 0 {
                    workingValue -= Int(2 ** Double(index))
                    binaryValue += "1"
                } else {
                    binaryValue += "0"
                }
            }
            return binaryValue
        } else {
            return nil
        }
    }
}

infix operator ** : MultiplicationPrecedence
func ** (base: Double, index: Double) -> Double {
    return pow(base, index)
}
