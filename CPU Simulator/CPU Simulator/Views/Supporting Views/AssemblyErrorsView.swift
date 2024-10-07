//
//  AssemblyErrorsView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 24/02/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import SwiftUI
import CPU_Simulator_Framework

struct AssemblyErrorsView: View {
	@EnvironmentObject var documentData: ContentDescription
	
	var body: some View {
		VStack(alignment: .leading) {
			Text("Errors")
				.font(.system(size: 18, weight: .heavy))
				.bold()
				.padding([.leading, .trailing, .top], 16)
				.padding(.top, -10)
			if documentData.assemblyCodeErrorsAsString != "" {
				ScrollView {
					Text(documentData.assemblyCodeErrorsAsString)
						.frame(idealWidth: 1000, alignment: .leading)
				}
				.padding(.leading, 16)
				.frame(idealWidth: 1000, alignment: .leading)
			} else {
				Text("No errors")
					.padding(.leading, 16)
			}
		}
	}
}

struct AssemblyErrorsView_Previews: PreviewProvider {
	static var previews: some View {
		AssemblyErrorsView()
	}
}
