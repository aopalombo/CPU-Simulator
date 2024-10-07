//
//  InstructionSetView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 25/02/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import SwiftUI

struct InstructionSetView: View {
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text("Instruction Set")
					.font(.largeTitle)
					.bold()
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
				Image("InstructionSet")
					.resizable()
					.aspectRatio(contentMode: .fit)
			}
		}
	}
}

struct InstructionSetView_Previews: PreviewProvider {
	static var previews: some View {
		InstructionSetView()
	}
}
