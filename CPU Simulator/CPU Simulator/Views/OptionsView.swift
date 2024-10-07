//
//  OptionsView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 24/02/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import SwiftUI
import CPU_Simulator_Framework

struct OptionsView: View {
	@EnvironmentObject var documentData: ContentDescription
	
	@State private var selectedRunSpeed = 0
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		VStack {
			NavigationView {
				Form {
					Section {
						Button("Restart Execution", action:{
							self.documentData.restartExecution()
						})
							.accentColor(.CPURed)
					}
					Section {
						Picker(selection: $documentData.preferences.runSpeedIndex, label: Text("Run Speed")) {
							ForEach(0 ..< Preferences.runSpeeds.count) {
								Text(Preferences.runSpeeds[$0])
							}
						}
					}
					Section {
						Picker(selection: $documentData.preferences.baseIndex, label: Text("Base")) {
							ForEach(0 ..< Preferences.bases.count) {
								Text(Preferences.bases[$0])
							}
						}
					}
					OptionsViewSupplemental()
				}.navigationBarTitle("Options")
					.navigationBarItems(trailing:
						Button(action: {
							self.presentationMode.wrappedValue.dismiss()
						}) {
							Image(systemName: "xmark.circle.fill")
								.foregroundColor(.secondary)
								.font(.system(size: 25, weight: .bold))
					})
			}
			.navigationViewStyle(StackNavigationViewStyle())
			.accentColor(.CPURed)
		}
	}
}

struct OptionsViewSupplemental: View {
	
	@EnvironmentObject var documentData: ContentDescription
	
	@State private var showingInstructionSet: Bool = false
	
	var body: some View {
		Section {
			Button(action: {
				self.showingInstructionSet.toggle()
			}) {
				Text("Show Instruction Set")
			}.sheet(isPresented: $showingInstructionSet, content: {
				InstructionSetView()
			})
				.accentColor(.CPURed)
		}
	}
}

struct OptionsView_Previews: PreviewProvider {
	static var previews: some View {
		OptionsView()
	}
}
