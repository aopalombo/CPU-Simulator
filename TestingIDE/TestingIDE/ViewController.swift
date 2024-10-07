//
//  ViewController.swift
//  TestingIDE
//
//  Created by Andrew Palombo on 10/07/2019.
//  Copyright © 2019 Andrew Palombo. All rights reserved.
//

import UIKit
import Foundation


class ViewController: UIViewController {

    @IBOutlet weak var assemblyCodeField: UITextView!
    @IBOutlet weak var errorTextField: UITextView!
    
    @IBOutlet weak var realtimeSwitch: UISwitch!
    
    @IBOutlet weak var checkForErrorsButton: UIButton!
    @IBOutlet weak var convertToMachineButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        assemblyCodeField.textColor = UIColor.lightGray
        
        assemblyCodeField.delegate = self
        
        /* NOTE
        add UITextViewDelegate to the class and set textView.delegate = self to use the text view’s delegate methods.
        add functionality to disable comvertToMachine button as soon as text field ends editing
        */
    }

    @IBAction func realtimeSwitchPressed(_ sender: Any) {
        if realtimeSwitch.isOn {
            checkForErrorsButton.isEnabled = false
        } else {
            checkForErrorsButton.isEnabled = true
        }
    }
    
    @IBAction func checkForErrorsTapped(_ sender: Any) {
        if ["", "Enter assembly code here"].contains(assemblyCodeField.text) {
            errorTextField.textColor = UIColor.lightGray
            errorTextField.text = "Errors will be displayed here"
        } else {
            let errors = getAssemblyCodeErrors(assemblyCode: assemblyCodeField.text)
            if errors.isEmpty {
                errorTextField.textColor = UIColor.black
                errorTextField.text = "No errors"
                convertToMachineButton.isEnabled = true
            } else {
                errorTextField.textColor = UIColor.black
                errorTextField.text = errorsToErrorText(errors: errors)
            }
        }
    }
    
    @IBAction func convertToMachineTapped(_ sender: Any) {
        // having the conversion happen before the segue results in finding nil when implicitly unwrapping field.text so segue must be done first
        
        let errors = getAssemblyCodeErrors(assemblyCode: assemblyCodeField.text)
        if errors.isEmpty {
            let machineCode = assemblyToMachine(assemblyCode: assemblyCodeField.text)
            UserDefaults.standard.set(machineCode, forKey: "machineCode")
            let assemblyCodeAsArray = seperateByLfToArray(text: assemblyCodeField.text)
            UserDefaults.standard.set(assemblyCodeAsArray, forKey: "assemblyCode")
            
            let description = ["The control unit copies the value in the program counter register to the memory address register and onto the address bus",
            "The control unit tells the memory store to look at the address on the address bus and load the value stored there onto the data bus.",
            "The control unit stores the value on the data bus into the memory data register.",
            "The control unit copies the value from the memory data register into the current intruction register.",
            "The control unit increments the program counter",
            "The decode unit breaks the value in the current instruction register into the opcode and operand.",
            "The opcode 00010 means 'add'"]
            UserDefaults.standard.set(description, forKey: "description")
            
            performSegue(withIdentifier: "machineSegue", sender: self)
        } else {
            convertToMachineButton.isEnabled = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        assemblyCodeField.resignFirstResponder()
    }
}



extension ViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter assembly code here"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if ["", "Enter assembly code here"].contains(textView.text) {
            errorTextField.textColor = UIColor.lightGray
            errorTextField.text = "Errors will be displayed here"
        } else {
            let errors = getAssemblyCodeErrors(assemblyCode: textView.text)
            if errors.isEmpty {
                if realtimeSwitch.isOn {
                    errorTextField.textColor = UIColor.black
                    errorTextField.text = "No errors"
                    convertToMachineButton.isEnabled = true
                }
            } else {
                if realtimeSwitch.isOn {
                    errorTextField.textColor = UIColor.black
                    errorTextField.text = errorsToErrorText(errors: errors)
                }
                convertToMachineButton.isEnabled = false
            }
        }
    }
}



extension ViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// COPIED CODE
// COPIED CODE
// COPIED CODE

// MAIN SUBROUTINES
func getAssemblyCodeErrors(assemblyCode: String) -> [Int: String] {
    let assemblyCodeArray = seperateByLfToArray(text: assemblyCode.uppercased())
    
    var errors: [Int: String] = [:]
    
    // get all the branches that have been created by a colon and show any applicable error
    var branches: [String] = []
    for currentIndex in assemblyCodeArray.startIndex..<assemblyCodeArray.endIndex where seperateBySpaceToArray(text: assemblyCodeArray[currentIndex]).count == 1 && seperateBySpaceToArray(text: assemblyCodeArray[currentIndex])[0].last == ":" {
        let labelName = String(assemblyCodeArray[currentIndex].dropLast())
        branches.append(labelName)

    }
    
    
    // check line by line
    for line in assemblyCodeArray {
        var lineNumber: Int? = nil
        if let index = assemblyCodeArray.firstIndex(of: line) {
            lineNumber = assemblyCodeArray.distance(from: assemblyCodeArray.startIndex, to: index)
        }
        // notes that the line below will cause a crash if line has not been found in code
        let checkedLineResults = checkOneLineOfCode(line: line, branches: branches, lineNumber: lineNumber!)
        let valid = checkedLineResults.valid
        let message = checkedLineResults.message
        
        // here we add an error by its line number to the array of errors
        if !(valid) {
            errors[lineNumber!] = message
        }
    }
    return errors
}

func checkOneLineOfCode(line: String, branches: [String], lineNumber: Int) -> (valid: Bool, message: String?) {
    if line == "" {
        return (true, nil)
    }
    if line[line.startIndex] == "@" {
        return (true, nil)
    }
    
    
    
    let lineAsArray = seperateBySpaceToArray(text: line)
    let function = lineAsArray[0]
    
    // check that line is not too long
    if lineAsArray.count > 4 {
        return (false, "error on line \(lineNumber): too many arguments")
    }
    
    // either check functional syntax (LDR, STR, B, BEQ are functions) or introduce new branch
    let lastCharacter = String(lineAsArray[0].dropFirst(lineAsArray[0].count - 1)) // drops all but the last character
    if !(lineAsArray.count == 1 && lastCharacter == ":") {
        // this is functional syntax
        // check that only required arguments are given for specific function
        let appropriateArguments = ["registerMemory": ["LDR", "STR"],
                                    "registerRegisterOperand": ["ADD", "SUB", "AND", "ORR", "EOR", "LSL", "LSR"],
                                    "registerOperand": ["MOV", "CMP", "MVN"],
                                    "label": ["B", "BEQ", "BNE", "BLT", "BGT"],
                                    "none": ["HALT"]]
        var foundInAppropriateArguments = false
        for (key, values) in appropriateArguments {
            if values.contains(function) {
                // uses seperate function to check for specific correctness
                if !(checkFunctionArguments(funcType: key, lineAsArray: lineAsArray)) {
                    return (false, "error on line \(lineNumber): invalid functional syntax for function \(function)\"")
                }
                foundInAppropriateArguments = true
            }
        }
        if !(foundInAppropriateArguments) {
            // this is executed if not a label: or a recognised function
            return (false, "error on line \(lineNumber): unrecognised function \"\(function)\"")
        }
        
        if appropriateArguments["label"]?.contains(function) ?? false {
            // check branching
            let branchLabel = lineAsArray[1]
            if !(branches.contains(branchLabel)) {
                return (false, "error on line \(lineNumber): attempted branch where no such branch exists")
            }
        }
    } else {
        // this is the declaration of a label (with ':') and so has already been checked
    }
    return (true, nil)
}

func assemblyToMachine(assemblyCode: String) -> String {
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
    
    
    
    let extraction = extractLabelsFromAssemblyCode(assemblyCode: assemblyCode.uppercased()) // also removes blank lines and labels that are succeeded by colons
    let labels = extraction.labels
    let newAssemblyCode = extraction.newAssemblyCode
    
    
    let assemblyCodeArray = seperateByLfToArray(text: newAssemblyCode)
    var machineCode: String = ""
    for line in assemblyCodeArray {
        var machineCodeLine: String = ""
        
        if line.count == 0 {
            machineCode += "\n"
            continue
        }
        
        if line[line.startIndex] == "@" {
            machineCode += "\n"
            continue
        }
        
        // Operation
        let lineAsArray = seperateBySpaceToArray(text: line)
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
            // any acompanying Rs or #s are ignored and only the number stored
            for operand in lineAsArray.dropFirst() {
                if operand[operand.startIndex] == "R" || operand[operand.startIndex] == "#" {
                    let newOperandRange = operand.index(operand.startIndex, offsetBy: 1)..<operand.endIndex
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
    
    return machineCode
}

// END OF MAIN SUBROUTINES

func checkAssemblyTextLength(assemblyCode: String) -> Bool {
    let assemblyCodeArray = seperateByLfToArray(text: assemblyCode)
    var lineCount: Int = 0
    for line in assemblyCodeArray where line.count != 0 {
        let firstCharacter = line[line.startIndex]
        let lastCharacter = line[line.index(line.endIndex, offsetBy: -1)]
        if !(firstCharacter == "@" || (lastCharacter == ":" && firstCharacter != ":")) {
            lineCount += 1
        }
    }
    
    if lineCount < 4194304 {
        return true
    }
    return false
}
    
    
    
func errorsToErrorText(errors: [Int:String]) -> String {
    
    var errorText = ""
//    for (_, errorMessege) in errors {
//        errorText += "\(errorMessege)\n"
//    }
    let sortedKeys: [Int] = Array(errors.keys).sorted()
    for key in sortedKeys {
        errorText += "\(errors[key] ?? "ERROR MESSEGE NOT FOUND")\n"
    }
    
    if !(errorText.isEmpty) {
        let rangeExcludingLastLF = errorText.startIndex...errorText.index(errorText.endIndex, offsetBy: -2)
        errorText = String(errorText[rangeExcludingLastLF])
    }
    
    return errorText
}

//func labelToBinaryRepresentation(label: String) -> String {
//    var binaryLabelRepresentation = ""
//    for character: Character in label {
//        let unicodePosition = character.unicodeScalarCodePoint()
//        let alphabetPosition = unicodePosition - 64
//        let binaryCharacterRepresentation: String = decimalToBinary(value: alphabetPosition, maxBitLength: 5)!
//        binaryLabelRepresentation += binaryCharacterRepresentation
//    }
//    return binaryLabelRepresentation
//}

func extractLabelsFromAssemblyCode(assemblyCode: String) -> (labels: [(lineNumber: Int, labelName: String)], newAssemblyCode: String) {
    var labels = [(lineNumber: Int, labelName: String)]()
    let assemblyCodeSeperatedByLF = seperateByLfToArray(text: assemblyCode)
    
    var newAssemblyCode = ""
    var lineNumber = 1
    for line in assemblyCodeSeperatedByLF where !(line.isEmpty) {
        if line.last == ":" {
            let labelNameRange = line.startIndex...line.index(line.endIndex, offsetBy: -2)
            let labelName = String(line[labelNameRange])
            labels.append((lineNumber: lineNumber, labelName: labelName))
        } else {
            newAssemblyCode += line + "\n"
            lineNumber += 1
        }
    }
    // to remove the last blank line
    newAssemblyCode = String(newAssemblyCode.dropLast())
    
    return (labels, newAssemblyCode)
}

func removeComments(assemblyCode: String) -> String {
    let assemblyCodeSeperatedByLF = seperateByLfToArray(text: assemblyCode)
    
    var assemblyCodeNoComments = ""
    for line in assemblyCodeSeperatedByLF where line[line.startIndex] != "@" {
        assemblyCodeNoComments += line
    }
    
    print(assemblyCodeNoComments)
    return assemblyCodeNoComments
}

func checkFunctionArguments(funcType: String, lineAsArray: [String]) -> Bool {
    switch funcType {
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
        // there me be a better way
        return false
    
    }
    
    return true
}

func seperateBySpaceToArray(text: String) -> [String] {
    var characterArray: [String] = []
    for char in text {
        characterArray.append(String(char))
    }
    
    var array: [String] = [""]
    for i in 0..<characterArray.count {
        if characterArray[i] != " " {
            array[array.count - 1] += characterArray[i]
        }
        else {
            array.append("")
        }
    }
    // This part removes commas at the end of any words in the middle of the array
    if array.count == 1 || array.count == 2 {
    }
    else if array.count == 3 {
        array[1] = String(array[1].dropLast())
    }
    else if array.count == 4 {
        for i in 1...2 {
            array[i] = String(array[i].dropLast())
        }
    }
    
    // remove empty string to prevent error in a line such as "ADD R1, R2, " becuase checkIsRegister fails on ""
    if array.last!.isEmpty {
        array = array.dropLast()
    }
 
    return array
}

func seperateByLfToArray(text: String) -> [String] {
    var array: [String] = [""]
    for character in text {
        if character != "\n" {
            array[array.count - 1] += String(character)
        } else {
            array.append("")
        }
    }
    
    return array
}

func decimalToBinary(value: Int, maxBitLength: Int) -> String? {
    // returns nil if not possible to deliberatly cause an error
    
    if value < 0 {
        return nil
    }
    
    let largestPossibleValueGivenBitLength = Double(2) ** Double(maxBitLength) - 1
    if Double(value) < largestPossibleValueGivenBitLength {
        var binaryValue: String = ""
        var workingValue = value
        for subtract in 0...(maxBitLength - 1) {
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

// LITTLE SUBROUTINES
func checkIsRegister(value: String) -> Bool {
    //sleep(10)
    let firstCharacter = value.dropLast(value.count - 1)
    let suffix = value.dropFirst()
    if firstCharacter == "R" && Int(suffix) != nil {
        return true
    }
    return false
}

func checkIsMemory(value: String) -> Bool {
    if Int(value) != nil {
        return true
    }
    return false
}

func checkIsOperand(value: String) -> Bool {
    if checkIsRegister(value: value) {
        return true
    }
    let firstCharacter = value.dropLast(value.count - 1)
    let suffix = value.dropFirst()
    if firstCharacter == "#" && Int(suffix) != nil {
        return true
    }
    return false
}

// END OF LITTLE SUBROUTINES


infix operator ** : MultiplicationPrecedence
func ** (base: Double, index: Double) -> Double {
    return pow(base, index)
}

//extension Character {
//    func unicodeScalarCodePoint() -> Int {
//        let characterString = String(self)
//        let scalars = characterString.unicodeScalars
//
//        return Int(scalars[scalars.startIndex].value)
//    }
//}
