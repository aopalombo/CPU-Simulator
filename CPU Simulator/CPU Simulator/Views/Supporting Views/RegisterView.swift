//
//  RegisterView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 23/02/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import SwiftUI
import CPU_Simulator_Framework // for class register

struct RegisterView: View {
	@EnvironmentObject var documentData: ContentDescription
	
	var cell: Cell
	
	var body: some View {
		Color.gray
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
							.fill(Color.gray)
							.opacity(0)
							.frame(width: 30, height: 30)
							.padding(.all, 10.0)
							.padding(.leading, 11)
					}
					
					VStack(alignment: .leading) {
						Text(cell.name)
							.font(.headline)
						HStack {
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
							if cell.cellType == .statusRegister {
								Text("[EQ][NE][GT][LT][OV]")
									.font(.footnote)
							}
						}
					}
					
					Spacer()
				}
				.padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 7.0))
	}
}

//struct RegisterView_Previews: PreviewProvider {
//    static var previews: some View {
//		Group {
//			RegisterView(cell: exampleRegister)
//				.previewLayout(.fixed(width: 350, height: 120))
//			RegisterView(cell: exampleRegister)
//				.previewDevice(PreviewDevice(rawValue: "iPhone 11"))
//		}
//    }
//}
