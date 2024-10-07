//
//  OnboardingView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 26/03/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
	var onDismiss: () -> Void
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		VStack {
			Spacer()
			Text("Welcome to CPU Simulator")
				.font(.largeTitle)
				.fontWeight(.bold)
				.multilineTextAlignment(.center)
				.minimumScaleFactor(0.8)
				.padding([.leading, .trailing])
			Spacer()
			Group {
				HStack {
					Image("CodeIcon")
						.resizable()
						.frame(width: 50, height: 50)
					VStack(alignment: .leading) {
						Text("Code")
							.font(.headline)
							.minimumScaleFactor(0.01)
						Text("Write your own assembly code in the AQA Assembly Language.")
							.font(.body)
							.foregroundColor(Color.gray)
							.minimumScaleFactor(0.01)
					}
				} .padding()
				HStack {
					Image("ReviewIcon")
						.resizable()
						.frame(width: 50, height: 50)
					VStack(alignment: .leading) {
						Text("Review")
							.font(.headline)
							.minimumScaleFactor(0.01)
						Text("View errors and machine code - these update automatically.")
							.font(.body)
							.foregroundColor(Color.gray)
							.minimumScaleFactor(0.01)
					}
				} .padding()
				HStack {
					Image("RunIcon")
						.resizable()
						.frame(width: 50, height: 50)
					VStack(alignment: .leading) {
						Text("Run")
							.font(.headline)
							.minimumScaleFactor(0.01)
						Text("Run or step through your code as registers, buses and descriptions change.")
							.font(.body)
							.foregroundColor(Color.gray)
							.minimumScaleFactor(0.01)
					}
				} .padding()
				HStack {
					Image("HarvardIcon")
						.resizable()
						.frame(width: 50, height: 50)
					VStack(alignment: .leading) {
						Text("Harvard Architecture")
							.font(.headline)
							.minimumScaleFactor(0.01)
						Text("Instructions and data are stored in separate memories.")
							.font(.body)
							.foregroundColor(Color.gray)
							.minimumScaleFactor(0.01)
					}
				} .padding()
			}
			.frame(minWidth: 100, idealWidth: 300, maxWidth: 400, alignment: .leading)
			.padding([.leading, .trailing])
			Spacer()
			Button(action: {
				self.onDismiss()
				self.presentationMode.wrappedValue.dismiss()
			}) {
				Text("Continue")
					.frame(width: 300.0, height: 50.0)
					.background(Color.CPURed)
					.accentColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
					.font(.headline)
					.cornerRadius(15)
					.padding()
					.padding(.bottom, 30)
			}
		}
	}
}

struct OnboardingView_Previews: PreviewProvider {
	static var previews: some View {
		OnboardingView(onDismiss: {print("dismiss tapped")})
	}
}
