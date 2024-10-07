//
//  AboutView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 03/12/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import SwiftUI

struct AboutView: View {
	var dismiss: () -> Void
	
	@State private var showingOnboarding = false
	
    var body: some View {
		VStack {
			HStack {
				Spacer()
				Button(action: {dismiss()}) {
					Image(systemName: "xmark.circle.fill")
						.foregroundColor(.secondary)
						.font(.system(size: 25, weight: .bold))
						.padding([.top, .trailing])
				}
			}
				Text("About CPU Simulator")
					.font(.largeTitle)
					.fontWeight(.bold)
					.foregroundColor(.CPURed)
					.minimumScaleFactor(0.8)
					.padding([.bottom, .leading, .trailing])
				Spacer()
				Form {
					Section {
						Link("App Support", destination: URL(string: "https://aopalombo.wixsite.com/cpusimulator/app-support")!)
							.accentColor(.CPURed)
					}
					Section {
						Link("Privacy Policy", destination: URL(string: "https://aopalombo.wixsite.com/cpusimulator/privacy-policy")!)
							.accentColor(.CPURed)
					}
					Section {
						Button(action: {
							self.showingOnboarding.toggle()
						}) {
							Text("Show Onboarding")
								.accentColor(.CPURed)
						}.sheet(isPresented: $showingOnboarding, content: {
							OnboardingView(onDismiss: {})
						})
					}
					Section {
						Text("© Andrew Palombo")
					}
				}
		}
		.background(Color(UIColor.systemGray6))
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
		AboutView(dismiss: {print("dismiss tapped")})
    }
}
