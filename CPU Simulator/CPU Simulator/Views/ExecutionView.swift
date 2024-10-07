//
//  ExecutionView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 24/02/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import SwiftUI
import CPU_Simulator_Framework

struct ExecutionView: View {
	@EnvironmentObject var documentData: ContentDescription
	
	var body: some View {
		ZStack(alignment: .topLeading) {
			RoundedRectangle(cornerRadius: 25)
				.fill(Color.CPURed)
				.shadow(color: Color.black.opacity(0.7), radius: 15)
			
			VStack(alignment: .leading) {
				if documentData.runThrough.inExecution {
					Text("Executing Line \(documentData.runThrough.executingLineNo)")
						.font(.system(size: 20, weight: .heavy))
						.padding(.all, 5)
						.padding(.leading, 8)
				} else {
					Text("Not Executing")
						.font(.system(size: 20, weight: .heavy))
						.padding(.all, 5)
						.padding(.leading, 8)
				}
				
				HStack {
					Text("Code:")
						.font(.system(size: 16, weight: .bold))
					if documentData.runThrough.inExecution && documentData.assemblyCodeIsValid {
						Text(documentData.assemblyCode.separateByLFToArray()[documentData.runThrough.executingLineNo])
							.font(.system(.body, design: .monospaced))
					}
				}
				.padding(.all, 5)
				.padding(.leading, 8)
				
				Text("Description:")
					.font(.system(size: 16, weight: .bold))
					.padding(.leading, 13)
					.padding(.top, 0)
					.padding(.bottom, 0)
				ScrollView {
					if !(self.documentData.assemblyCodeIsValid) {
						// no valid code
						Text("No valid assembly code provided.")
					} else if !(self.documentData.runThrough.inExecution) {
						// valid code and speed selected but not running
						Text("Tap 'Run' or 'Next Step' to begin.")
					} else if self.documentData.runThrough.currentDescription == "EXECUTE: The program has halted." {
						//show description in bold
						Text(self.documentData.runThrough.currentDescription)
							.font(.system(size: 15, weight: .bold))
					} else {
						// showing current description
						Text(self.documentData.runThrough.currentDescription)
					}
				}
				.padding(.top, -5)
				.padding(.bottom, 5)
				.padding(.leading, 13)
				.padding(.trailing, 13)
			}
			.padding(8)
		}
		.frame(height: 150)
		.padding([.leading, .trailing], 10)
	}
}

struct ExecutionView_Previews: PreviewProvider {
	static var previews: some View {
		ExecutionView()
	}
}
