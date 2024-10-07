//
//  MachineCodeCompositionView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 04/03/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import SwiftUI

struct MachineCodeCompositionView: View {
	@Environment(\.presentationMode) var presentationMode
	
    var body: some View {
        VStack(alignment: .leading) {
			HStack {
				Text("Machine Code Composition")
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
				Image("MachineCodeComposition")
					.resizable()
					.aspectRatio(contentMode: .fit)
			}
		}
    }
}

struct MachineCodeCompositionView_Previews: PreviewProvider {
    static var previews: some View {
        MachineCodeCompositionView()
    }
}
