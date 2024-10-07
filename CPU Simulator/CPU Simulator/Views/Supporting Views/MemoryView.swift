//
//  MemoryView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 26/02/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import SwiftUI
import CPU_Simulator_Framework

struct MemoryView: View {
	@EnvironmentObject var documentData: ContentDescription
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text("Data Memory")
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
				ForEach(0 ..< documentData.runThrough.memoryValues.count, id: \.self) {
					MemoryLineView(memLoc: $0).environmentObject(self.documentData)
				}
			}.padding()
		}
	}
}

struct MemoryLineView: View {
	@EnvironmentObject var documentData: ContentDescription
	
	var memLoc: Int
	
	var body: some View {
		Group {
			if documentData.preferences.base == "Hexadecimal" {
				Text("MemLoc \(memLoc): \(self.documentData.runThrough.memoryValuesInHexadecimal[memLoc])")
					.font(.system(size: 12, weight: .light, design: .monospaced))
			} else if documentData.preferences.base == "Decimal" {
				Text("MemLoc \(memLoc): \(self.documentData.runThrough.memoryValuesInDecimal[memLoc])")
					.font(.system(size: 12, weight: .light, design: .monospaced))
			} else {
				Text("MemLoc \(memLoc): \(self.documentData.runThrough.memoryValues[memLoc])")
					.font(.system(size: 12, weight: .light, design: .monospaced))
			}
		}
	}
}

struct MemoryView_Previews: PreviewProvider {
	static var previews: some View {
		MemoryView()
	}
}
