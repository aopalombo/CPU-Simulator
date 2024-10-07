//
//  CellsListView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 23/02/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import SwiftUI
import CPU_Simulator_Framework

struct CellsListView: View {
	@EnvironmentObject var documentData: ContentDescription
	
	@State private var showingMemory = false
	
	var body: some View {
		List {
			Button(action: {
				self.showingMemory.toggle()
			}) {
				Text("View Data Memory")
					.foregroundColor(.CPURed)
			}.sheet(isPresented: $showingMemory, content: {
				MemoryView().environmentObject(self.documentData)
			})
			Text("Buses")
			BusView(cell: documentData.runThrough.addressBus).frame(height: 70).environmentObject(documentData)
			BusView(cell: documentData.runThrough.dataBus).frame(height: 70).environmentObject(documentData)
//			BusView(cell: documentData.runThrough.controlBus).frame(height: 70).environmentObject(documentData)
			Text("Clock")
			RegisterView(cell: documentData.runThrough.clock).frame(height: 70).environmentObject(documentData)
			
			Text("Control Unit")
			CellsListViewSupplement()
		}
	}
}

// workaround: a view builder does not take in more than ten views so some views must be nested, this works as an extension
struct CellsListViewSupplement: View {
	@EnvironmentObject var documentData: ContentDescription
	
	var body: some View {
		Group {
			RegisterView(cell: documentData.runThrough.programCounter).frame(height: 70).environmentObject(documentData)
			RegisterView(cell: documentData.runThrough.currentInstructionRegister).frame(height: 70).environmentObject(documentData)
			Text("Special Purpose Registers")
			RegisterView(cell: documentData.runThrough.memoryAddressRegister).frame(height: 70).environmentObject(documentData)
			RegisterView(cell: documentData.runThrough.memoryBufferRegister).frame(height: 70).environmentObject(documentData)
			GPCellView().frame(height: 70).frame(height: 70).environmentObject(documentData)
			Text("ALU and Status Register")
			RegisterView(cell: documentData.runThrough.alu).frame(height: 70).environmentObject(documentData)
			RegisterView(cell: documentData.runThrough.statusRegister).frame(height: 70).environmentObject(documentData)
			Spacer(minLength: 150)
		}
	}
}

struct CellsList_Previews: PreviewProvider {
	static var previews: some View {
		CellsListView()
	}
}
