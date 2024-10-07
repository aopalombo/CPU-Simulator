//
//  MachineCodeView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 24/02/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import SwiftUI
import CPU_Simulator_Framework

struct MachineCodeView: View {
	@EnvironmentObject var documentData: ContentDescription
	
	@State private var showingMachineCodeComposition: Bool = false
	
	private var lineNumbers: String {
		let highestLineNo = self.documentData.machineCode.components(separatedBy: "\n").count - 2
		var output = ""
		for lineNo in 0 ... highestLineNo {
			output += "\(lineNo)\n"
		}
		return output
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			Text("Machine Code")
				.font(.title)
				.padding(16)
			Text("(Stored in Instruction Memory)")
				.font(.subheadline)
				.padding()
				.padding(.top, -16)
			//documentData.machineCode = documentData.assemblyCode.assemblyToMachine()
			if documentData.machineCode == "" {
				Text("No machine code was produced because either there was no assembly code or the assembly code contains an error.")
					.padding()
			} else {
				ScrollView {
					HStack {
						Text(lineNumbers)
							.font(.system(size: 16, weight: .light, design: .monospaced))
							.padding()
						if documentData.preferences.base == "Hexadecimal" {
							Text(documentData.machineCodeInHexadecimal)
								.font(.system(size: 16, weight: .light, design: .monospaced))
								.padding()
						} else if documentData.preferences.base == "Decimal" {
							Text(documentData.machineCodeInDecimal)
								.font(.system(size: 16, weight: .light, design: .monospaced))
								.padding()
						} else {
							Text(documentData.machineCode)
								.font(.system(size: 16, weight: .light, design: .monospaced))
								.padding()
						}
					}
				}
				
			}
			Spacer()
			HStack {
				Spacer()
				Button(action: {
					self.showingMachineCodeComposition.toggle()
				}) {
					Text("Machine Code Composition")
				}.sheet(isPresented: $showingMachineCodeComposition, content: {
					MachineCodeCompositionView()
				})
					.accentColor(.CPURed)
					.padding()
				Spacer()
			}
		}
	}
}

struct MachineCodeView_Previews: PreviewProvider {
	static var previews: some View {
		MachineCodeView()
	}
}
