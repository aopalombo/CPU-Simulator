//
//  CodeView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 24/02/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import SwiftUI
import CPU_Simulator_Framework

struct CodeView: View {
	@EnvironmentObject var documentData: ContentDescription
	
	@State private var viewMode = 0
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text("View & Edit Code")
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
			Picker(selection: $viewMode, label: Text("View Mode")) {
				Text("Assembly").tag(0)
				Text("Machine").tag(1)
			}.pickerStyle(SegmentedPickerStyle())
				.padding(.leading, 20)
				.padding(.trailing, 20)
			if viewMode == 0 {
				AssemblyCodeView()
					.environmentObject(self.documentData)
			} else {
				MachineCodeView()
					.environmentObject(documentData)
			}
		}
	}
}

struct CodeView_Previews: PreviewProvider {
	static var previews: some View {
		CodeView()
	}
}
