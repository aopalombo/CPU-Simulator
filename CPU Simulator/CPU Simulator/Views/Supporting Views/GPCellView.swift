//
//  GPCellView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 26/02/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import SwiftUI
import CPU_Simulator_Framework // for class register

struct GPCellView: View {
	@EnvironmentObject var documentData: ContentDescription
	
	@State private var showingGP = false
	
	var body: some View {
		Color.gray
			.opacity(0.5)
			.cornerRadius(20)
			.overlay(
				HStack {
					if documentData.runThrough.generalPurposeRegistersIsRecentlyChanged {
						Circle()
							.fill(Color.CPURed)
							.frame(width: 30, height: 30)
							.padding(.all, 10.0)
							.padding(.leading, 11)
					} else {
						Circle()
							.fill(Color.gray)
							.opacity(0)
							.frame(width: 30, height: 30)
							.padding(.all, 10.0)
							.padding(.leading, 11)
					}
					
					VStack(alignment: .leading) {
						Text("General Purpose Registers")
							.font(.headline)
						Button(action: {
							self.showingGP.toggle()
						}) {
							Text("View General Purpose Registers")
								.foregroundColor(.CPURed)
						}.sheet(isPresented: $showingGP, content: {
							GPView().environmentObject(self.documentData)
						})
					}
					Spacer()
				}
				.padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 7.0))
	}
}

//struct GPView_Previews: PreviewProvider {
//    static var previews: some View {
//		Group {
//			GPCellView(cell: exampleRegister)
//				.previewLayout(.fixed(width: 350, height: 120))
//			GPView(cell: exampleRegister)
//				.previewDevice(PreviewDevice(rawValue: "iPhone 11"))
//		}
//    }
//}
