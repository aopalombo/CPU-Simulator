//
//  GPView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 26/02/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import SwiftUI
import CPU_Simulator_Framework

struct GPView: View {
	@EnvironmentObject var documentData: ContentDescription
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				HStack {
					Text("General Purpose Registers")
						.bold()
						.font(.title)
						.padding()
					Spacer()
					Button(action: {
						self.presentationMode.wrappedValue.dismiss()
					}) {
						Image(systemName: "xmark.circle.fill")
							.foregroundColor(.secondary)
							.font(.system(size: 25, weight: .bold))
							.padding()
					}
				}
				ScrollView {
					ForEach(0 ..< documentData.runThrough.generalPurposeRegisters.count, id: \.self) {
						GPViewLine(gpRegisterNumber: $0).environmentObject(self.documentData)
					}
				}
			}
			.padding()
			Spacer()
		}
	}
}

struct GPViewLine: View {
	@EnvironmentObject var documentData: ContentDescription
	
	var gpRegisterNumber: Int
	
	var body: some View {
		Group {
			if documentData.runThrough.generalPurposeRegisters[gpRegisterNumber].isRecentlyUsed {
				if documentData.preferences.base == "Hexadecimal" {
					Text("R\(gpRegisterNumber): \(documentData.runThrough.generalPurposeRegisters[gpRegisterNumber].cellContentsInHexadecimal)")
						.font(.system(size: 12, weight: .light, design: .monospaced))
						.bold()
				} else if documentData.preferences.base == "Decimal" {
					Text("R\(gpRegisterNumber): \(documentData.runThrough.generalPurposeRegisters[gpRegisterNumber].cellContentsInDecimal)")
						.bold()
				} else {
					Text("R\(gpRegisterNumber): \(documentData.runThrough.generalPurposeRegisters[gpRegisterNumber].cellContents)")
						.font(.system(size: 12, weight: .light, design: .monospaced))
						.bold()
				}
			} else {
				if documentData.preferences.base == "Hexadecimal" {
					Text("R\(gpRegisterNumber): \(documentData.runThrough.generalPurposeRegisters[gpRegisterNumber].cellContentsInHexadecimal)")
						.font(.system(size: 12, weight: .light, design: .monospaced))
				} else if documentData.preferences.base == "Decimal" {
					Text("R\(gpRegisterNumber): \(documentData.runThrough.generalPurposeRegisters[gpRegisterNumber].cellContentsInDecimal)")
						.font(.system(size: 12, weight: .light, design: .monospaced))
				} else {
					Text("R\(gpRegisterNumber): \(documentData.runThrough.generalPurposeRegisters[gpRegisterNumber].cellContents)")
						.font(.system(size: 12, weight: .light, design: .monospaced))
				}
			}
		}
	}
}

struct GPView_Previews: PreviewProvider {
	static var previews: some View {
		GPView()
	}
}
