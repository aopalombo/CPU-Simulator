//
//  BusView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 19/02/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import SwiftUI
import CPU_Simulator_Framework // for class register

struct BusView: View {
	@EnvironmentObject var documentData: ContentDescription
	
	var cell: Cell //reference type - connected to documentData in parent view
	
	var body: some View {
		
		Color.blue
			.opacity(0.5)
			.cornerRadius(20)
			.overlay(
				HStack {
					if cell.isRecentlyUsed {
						Circle()
							.fill(Color.CPURed)
							.frame(width: 30, height: 30)
							.padding(.all, 10.0)
							.padding(.leading, 11)
					} else {
						Circle()
							.fill(Color.blue)
							.opacity(0)
							.frame(width: 30, height: 30)
							.padding(.all, 10.0)
							.padding(.leading, 11)
					}
					
					VStack(alignment: .leading) {
						Text(cell.name)
							.font(.headline)
						if documentData.preferences.base == "Hexadecimal" {
							Text(cell.cellContentsInHexadecimal)
								.font(.footnote)
						} else if documentData.preferences.base == "Decimal" {
							Text(cell.cellContentsInDecimal)
								.font(.footnote)
						} else {
							Text(cell.cellContents)
								.font(.footnote)
						}
					}
					Spacer()
				}
				.padding(.all, 7.0))
	}
}

//struct BusView_Previews: PreviewProvider {
//    static var previews: some View {
//		Group {
//			BusView(cell: exampleRegister)
//				.previewLayout(.fixed(width: 350, height: 120))
//			BusView(cell: exampleRegister)
//				.previewDevice(PreviewDevice(rawValue: "iPhone 11"))
//		}
//    }
//}
