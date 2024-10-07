//
//  AssemblyCodeView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 24/02/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import SwiftUI
import CPU_Simulator_Framework

struct AssemblyCodeView: View {
	@EnvironmentObject var documentData: ContentDescription
	
	@State private var showingWebView = false
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text("IDE")
					.font(.title)
					.padding(.leading, 16)
					.padding(.trailing, 16)
					.padding(.top, 16)
					.padding(.bottom, 4)
				Spacer()
				if UIDevice.current.userInterfaceIdiom == .phone {
					Button(action: {
						UIApplication.shared.endEditing()
					}) {
						Text("Hide Keyboard")
							.padding(.trailing, 25)
							.foregroundColor(.CPURed)
					}
				}
			}
			ScrollView {
				HStack(alignment: .top) {
					VStack {
						Text("")
							.padding(.top, 2)
						ForEach(0...(documentData.assemblyCode.separateByLFToArray().count - 1), id: \.self) {
							LineNumberView(lineNumber: $0)
						}
					}.padding(8)
					TextView()
						.frame(idealWidth: 1000, minHeight: 300)
						.cornerRadius(10)
						.padding(.all, 18)
						.padding(.leading, -25)
				}
				.padding(.bottom, 200)
			}
			
			AssemblyErrorsView()
				.frame(height: 150)
				.frame(idealWidth: 1000, alignment: .leading)
				.environmentObject(self.documentData)
				.padding(.bottom)
		}
	}
}

struct LineNumberView: View {
	@EnvironmentObject var documentData: ContentDescription
	
	var lineNumber: Int
	
	var body: some View {
		Group {
			if documentData.assemblyCodeErroneousLineNos.contains(lineNumber) {
				Text("\(lineNumber)")
					.font(.system(size: 14.75, weight: .heavy))
					.foregroundColor(.red)
			} else {
				Text("\(lineNumber)")
					.font(.system(size: 14.75, weight: .heavy))
			}
		}
	}
}

extension UIApplication {
	func endEditing() {
		sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}

struct AssemblyCodeView_Previews: PreviewProvider {
	static var previews: some View {
		AssemblyCodeView()
	}
}
