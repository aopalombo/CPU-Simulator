//
//  SimulationView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 10/09/2019.
//  Copyright © 2019 Andrew Palombo. All rights reserved.
//

import UIKit
import SwiftUI
import CPU_Simulator_Framework

extension Color {
	static let CPURed = Color(red: 195 / 255, green: 42 / 255, blue: 5 / 255)
}

struct SimulationView: View {
	var document: CPUSimulatorDocument
	var dismiss: () -> Void
	
	@EnvironmentObject var documentData: ContentDescription
	
	@State var toggleToRefreshView = true
	
	var body: some View {
		VStack(alignment: .leading, spacing: 2) {
			
			FileNameView(document: document, dismiss: dismiss)
				.environmentObject(self.documentData)
			
			TopButtonsView()
				.environmentObject(self.documentData)
			
			ZStack {
				CellsListView()
					.environmentObject(self.documentData)
				
				VStack {
					Spacer()
					if UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0 > 0 {
						ExecutionView()
							.environmentObject(self.documentData)
					} else {
						ExecutionView()
							.environmentObject(self.documentData)
							.padding(.bottom, 10)
					}
				}
			}
		}
	}
}

struct FileNameView: View {
	var document: CPUSimulatorDocument
	var dismiss: () -> Void
	
	@EnvironmentObject var documentData: ContentDescription
	
	var body: some View {
		HStack(spacing: 20) {
			Text(document.localizedName)
				.bold()
				.font(.title)
				.frame(maxHeight: 70)
				.padding([.leading, .trailing, .top])
			Spacer()
			Button(action: {
				self.documentData.stop(); self.dismiss(); self.document.updateChangeCount(.done)
			}) {
				Image(systemName: "xmark.circle.fill")
					.foregroundColor(.secondary)
					.font(.system(size: 25, weight: .bold))
					.padding()
			}
		}
	}
}

struct TopButtonsView: View {
	
	@EnvironmentObject var documentData: ContentDescription
	
	@State private var showingCode = false
	@State private var showingOptions = false
	
//	private var pointerSupport: Bool {
//		if #available(iOS 13.4, *) {
//			return true
//		}
//		return false
//	}
	
	var body: some View {
		HStack(spacing: 20) {
			if documentData.runThrough.currentStep == documentData.runThrough.steps.count - 1  && documentData.assemblyCodeIsValid {
				Button("Restart", action: {
					self.documentData.restartExecution()
				})
					.accentColor(.CPURed)
					.padding()
			} else if documentData.preferences.runSpeed == "Stepped" {
				Button("Next Step", action: {
					self.documentData.advanceStep()
				})
					.accentColor(.CPURed)
					.padding()
			} else if documentData.runThrough.isRunning {
				Button("Stop", action: {
					self.documentData.stop()
				})
					.accentColor(.CPURed)
					.padding()
			} else {
				Button("Run", action: {
					self.documentData.run()
				})
					.accentColor(.CPURed)
					.padding()
			}
			
			Spacer()
			
			Button(action: {
				self.showingCode.toggle()
				self.documentData.stop()
			}) {
				Text("Edit Code")
			}.sheet(isPresented: $showingCode, content: {
				CodeView().environmentObject(self.documentData)
			})
				.accentColor(.CPURed)
				.padding()
			
			Spacer()
			
			Button(action: {
				self.showingOptions.toggle()
				self.documentData.stop()
			}) {
				Text("Options")
			}.sheet(isPresented: $showingOptions, content: {
				OptionsView().environmentObject(self.documentData)
			})
				.accentColor(.CPURed)
				.padding()
		}
	}
}

//extension View {
//	func safeHoverEffect() -> AnyView {
//		if ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 13, minorVersion: 4, patchVersion: 0)) {
//			print("13.4+")
//			
//			if #available(iOS 13.4, *) {
//				return AnyView(hoverEffect(.highlight))
//			}
//			else {
//				return AnyView(self)
//			}
//		}
//		else {
//			print("<13.4")
//			return AnyView(self)
//		}
//	}
//}

//struct ContentView: View {
//    var body: some View {
//        Text("Tap me!")
//            .font(.largeTitle)
//            .hoverEffect(.lift)
//            .onTapGesture {
//                print("Text tapped")
//            }
//    }
//}

//struct DocumentView_Previews: PreviewProvider {
//    static var previews: some View {
//		DocumentView(document: exampleDocument, dismiss: {})
//    }
//}
