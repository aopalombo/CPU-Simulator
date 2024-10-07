//
//  CPU_Simulator_FrameworkTests.swift
//  CPU Simulator FrameworkTests
//
//  Created by Andrew Palombo on 06/12/2019.
//  Copyright © 2019 Andrew Palombo. All rights reserved.
//

import XCTest
@testable import CPU_Simulator_Framework

class CPU_Simulator_FrameworkTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
	
	func testCPUSimulatorStringSlicing() {
		XCTAssertEqual(CPUSimulatorString(text: "").separateBySpaceToArray(removeAssemblyCommas: true), [""])
		XCTAssertEqual(CPUSimulatorString(text: "HALT").separateBySpaceToArray(removeAssemblyCommas: true), ["HALT"])
		XCTAssertEqual(CPUSimulatorString(text: "B LABEL").separateBySpaceToArray(removeAssemblyCommas: true), ["B", "LABEL"])
		XCTAssertEqual(CPUSimulatorString(text: "LDR R5, 27").separateBySpaceToArray(removeAssemblyCommas: true), ["LDR", "R5", "27"])
		XCTAssertEqual(CPUSimulatorString(text: "ADD R0, R1, #3").separateBySpaceToArray(removeAssemblyCommas: true), ["ADD", "R0", "R1", "#3"])
		XCTAssertEqual(CPUSimulatorString(text: "").separateBySpaceToArray(removeAssemblyCommas: false), [""])
		XCTAssertEqual(CPUSimulatorString(text: "ADD R0, R1, #3").separateBySpaceToArray(removeAssemblyCommas: false), ["ADD", "R0,", "R1,", "#3"])
		
		XCTAssertEqual(CPUSimulatorString(text: "").separateByLFToArray(), [""])
		XCTAssertEqual(CPUSimulatorString(text: "\n").separateByLFToArray(), ["", ""])
		XCTAssertEqual(CPUSimulatorString(text: " the\nquick\n").separateByLFToArray(), [" the", "quick", ""])
	}
	
	func testAssemblyCodeGetErrors() {
		XCTAssertEqual(AssemblyCode(text: "").getAssemblyCodeErrors(), [:])
		XCTAssertEqual(AssemblyCode(text: "\n\n\n").getAssemblyCodeErrors(), [:])
		XCTAssertEqual(AssemblyCode(text: "1").getAssemblyCodeErrors(), [:])
		XCTAssertEqual(AssemblyCode(text: "1, 2, 3").getAssemblyCodeErrors(), [:])
		XCTAssertEqual(AssemblyCode(text: "0, 2097152, 4194303").getAssemblyCodeErrors(), [:])
		XCTAssertEqual(AssemblyCode(text: "HALT\nB LABEL\nLDR R5, 27\nLABEL:\nADD R0, R1, #3").getAssemblyCodeErrors(), [:])
		XCTAssertEqual(AssemblyCode(text: "HALT\nB LABEL\nLDR R5, 27\nLABEL:\n\t\tADD R0, R1, #3").getAssemblyCodeErrors(), [:])
		XCTAssertEqual(AssemblyCode(text: "1, 2, 3\nHALT\nB LABEL\nLDR R5, 27\nLABEL:\nADD R0, R1, #3").getAssemblyCodeErrors(), [:])
		XCTAssertEqual(AssemblyCode(text: "1, 2, 3\nHALT\nB LABEL\nLDR R5, 27\nLABEL:\n@MY COMMENT\nADD R0, R1, #3").getAssemblyCodeErrors(), [:])
		XCTAssertEqual(AssemblyCode(text: "12THREE4:").getAssemblyCodeErrors(), [:])
		XCTAssertEqual(AssemblyCode(text: "HALT").getAssemblyCodeErrors(), [:])
		XCTAssertEqual(AssemblyCode(text: "LDR R5, 27").getAssemblyCodeErrors(), [:])
		XCTAssertEqual(AssemblyCode(text: "ADD R0, R1, #3").getAssemblyCodeErrors(), [:])
		
		
		XCTAssertEqual(AssemblyCode(text: "-1, 2097152, 4194304").getAssemblyCodeErrors(), [0: "Line 0: incorrect use of commas."])
		XCTAssertEqual(AssemblyCode(text: "2097152, 4194304").getAssemblyCodeErrors(), [0: "Line 0: incorrect use of commas."])
		XCTAssertEqual(AssemblyCode(text: "LABEL:\nLABEL:").getAssemblyCodeErrors(), [1:"Line 1: redeclaration of 'LABEL'."])
		XCTAssertEqual(AssemblyCode(text: "1, 2, 3\nLABEL:\nB LABEL\nLABEL:").getAssemblyCodeErrors(), [3:"Line 3: redeclaration of 'LABEL'."])
		XCTAssertEqual(AssemblyCode(text: "HALT\nB LABEL\nLDR R5, 27\n\nADD R0, R1, #3").getAssemblyCodeErrors(), [1:"Line 1: the label 'LABEL' is not defined."])
		XCTAssertEqual(AssemblyCode(text: "HALT\nB LABEL\nLDR R5, 27\nLABE:\nADD R0, R1, #3").getAssemblyCodeErrors(), [1:"Line 1: the label 'LABEL' is not defined."])
		XCTAssertEqual(AssemblyCode(text: "HALT\nB LABEL\nLDR R5, 27\nLABEL\nADD R0, R1, #3").getAssemblyCodeErrors(), [1:"Line 1: the label 'LABEL' is not defined.", 3:"Line 3: unrecognised function 'LABEL'."])
		XCTAssertEqual(AssemblyCode(text: "1, 2, 3\nHALT\nB LABEL\nLDR R5, 27\nLABEL\nADD R0, R1, #3").getAssemblyCodeErrors(), [2:"Line 2: the label 'LABEL' is not defined.", 4:"Line 4: unrecognised function 'LABEL'."])
		XCTAssertEqual(AssemblyCode(text: "123*:").getAssemblyCodeErrors(), [0:"Line 0: label is not alphanumeric."])
		XCTAssertEqual(AssemblyCode(text: "LA*BEL:").getAssemblyCodeErrors(), [0:"Line 0: label is not alphanumeric."])
		XCTAssertEqual(AssemblyCode(text: "LABEL*:").getAssemblyCodeErrors(), [0:"Line 0: label is not alphanumeric."])
		XCTAssertEqual(AssemblyCode(text: "LDT R5, 27").getAssemblyCodeErrors(), [0:"Line 0: unrecognised function 'LDT'."])
		XCTAssertEqual(AssemblyCode(text: "1, 2, 3\n123").getAssemblyCodeErrors(), [1:"Line 1: unrecognised function '123'."])
		XCTAssertEqual(AssemblyCode(text: "HALT\nOR R0, R1, R2").getAssemblyCodeErrors(), [1:"Line 1: unrecognised function 'OR'."])
		XCTAssertEqual(AssemblyCode(text: "halt\nORr R0, R1, R2").getAssemblyCodeErrors(), [0:"Line 0: unrecognised function 'halt'.", 1:"Line 1: unrecognised function 'ORr'."])
		XCTAssertEqual(AssemblyCode(text: "HALT ").getAssemblyCodeErrors(), [0:"Line 0: too many spaces."])
		XCTAssertEqual(AssemblyCode(text: "\t HALT").getAssemblyCodeErrors(), [0:"Line 0: too many spaces."])
		XCTAssertEqual(AssemblyCode(text: "HALT\t").getAssemblyCodeErrors(), [0:"Line 0: too many spaces."])
		XCTAssertEqual(AssemblyCode(text: "1, 2,  3").getAssemblyCodeErrors(), [0:"Line 0: too many spaces."])
		XCTAssertEqual(AssemblyCode(text: "LDR R5,  27").getAssemblyCodeErrors(), [0:"Line 0: too many spaces."])
		XCTAssertEqual(AssemblyCode(text: "LDR R5, 27 ").getAssemblyCodeErrors(), [0:"Line 0: too many spaces."])
		XCTAssertEqual(AssemblyCode(text: "LDR R5,\t27").getAssemblyCodeErrors(), [0:"Line 0: too many spaces."])
		XCTAssertEqual(AssemblyCode(text: "\t\t").getAssemblyCodeErrors(), [0:"Line 0: tab(s) must be followed by code."])
		
		XCTAssertEqual(AssemblyCode(text: "ADD, R0, R1, #3").getAssemblyCodeErrors(), [0:"Line 0: incorrect use of commas."])
		XCTAssertEqual(AssemblyCode(text: "ADD R0,, R1, #3").getAssemblyCodeErrors(), [0:"Line 0: incorrect use of commas."])
		XCTAssertEqual(AssemblyCode(text: "ADD R0, R1, #3,").getAssemblyCodeErrors(), [0:"Line 0: incorrect use of commas."])
		XCTAssertEqual(AssemblyCode(text: "ADD R0, R1, R2, R3").getAssemblyCodeErrors(), [0:"Line 0: too many arguments."])
		XCTAssertEqual(AssemblyCode(text: "ADD R0, R-1, #3").getAssemblyCodeErrors(), [0:"Line 0: number given is outside of range 0 to 127."])
		XCTAssertEqual(AssemblyCode(text: "ADD R0, R1, #128").getAssemblyCodeErrors(), [0:"Line 0: number given is outside of range 0 to 127."])
	}
	
	func testAssemblyCodeToMachine() {
		XCTAssertEqual(AssemblyCode(text: "").assemblyToMachine(), "")
		XCTAssertEqual(AssemblyCode(text: "1, 2, 3").assemblyToMachine(), "")
		XCTAssertEqual(AssemblyCode(text: "\n\n").assemblyToMachine(), "")
		
		XCTAssertEqual(AssemblyCode(text: "HALT").assemblyToMachine(), "100010000000000000000000000\n")
		XCTAssertEqual(AssemblyCode(text: "1, 2, 3\nHALT").assemblyToMachine(), "\n100010000000000000000000000\n")
		XCTAssertEqual(AssemblyCode(text: "LDR R5, 27").assemblyToMachine(), "000000000010100110110000000\n")
		XCTAssertEqual(AssemblyCode(text: "ADD R0, R1, #3").assemblyToMachine(), "000101000000000000010000011\n")
		XCTAssertEqual(AssemblyCode(text: "ADD R0, R1, R3").assemblyToMachine(), "000100000000000000010000011\n")
		XCTAssertEqual(AssemblyCode(text: "B LABEL\nLABEL:\nHALT").assemblyToMachine(), "001100000000000000000000001\n\n100010000000000000000000000\n")
		XCTAssertEqual(AssemblyCode(text: "B LABEL\nLABEL:").assemblyToMachine(), "001100000000000000000000001\n\n")
		XCTAssertEqual(AssemblyCode(text: "1, 2, 3\nB LABEL\nLABEL:").assemblyToMachine(), "\n001100000000000000000000010\n\n")
	}
	
//	func testGenerateSteps() {
//		var runThrough = RunThrough()
//		let assemblyCode = AssemblyCode(text: "")
//		let machineCode = assemblyCode.assemblyToMachine()
//		runThrough.generateSteps(assemblyCode: assemblyCode, machineCode: machineCode)
//		XCTAssertEqual(runThrough.steps, [(description: "", lineNo: 0, performChanges: {})])
//	}
	
	func testDecimalToBinary() {
		XCTAssertEqual(RunThrough().decimalToBinary(decimal: 4, minBitLength: 0), "")
		XCTAssertEqual(RunThrough().decimalToBinary(decimal: -1, minBitLength: 7), "")
		XCTAssertEqual(RunThrough().decimalToBinary(decimal: 0, minBitLength: 1), "0")
		XCTAssertEqual(RunThrough().decimalToBinary(decimal: 0, minBitLength: 7), "0000000")
		XCTAssertEqual(RunThrough().decimalToBinary(decimal: 5, minBitLength: 7), "0000101")
		XCTAssertEqual(RunThrough().decimalToBinary(decimal: 16, minBitLength: 4), "10000")
		XCTAssertEqual(RunThrough().decimalToBinary(decimal: 97, minBitLength: 7), "1100001")
	}
}
