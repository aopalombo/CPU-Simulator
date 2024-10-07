//
//  TextView.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 24/02/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

// CREDIT for creation of multi line text view: Meo Flute

import SwiftUI
import CPU_Simulator_Framework

struct TextView: UIViewRepresentable {
	@EnvironmentObject var documentData: ContentDescription
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	func makeUIView(context: Context) -> UITextView {
		
		let textView = UITextView()
		textView.delegate = context.coordinator
		
		textView.font = UIFont(name: "CourierNewPSMT", size: 15.5)
		textView.isScrollEnabled = false
		textView.isEditable = true
		textView.isUserInteractionEnabled = true
		textView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
		textView.autocapitalizationType = .allCharacters
		textView.allowsEditingTextAttributes = false
		textView.autocorrectionType = .no
		
		textView.text = "Enter assembly code here"
		textView.textColor = .placeholderText
		
		return textView
	}
	
	func updateUIView(_ uiView: UITextView, context: Context) {
		if !(documentData.assemblyCode.text.isEmpty) {
			uiView.text = documentData.assemblyCode.text
			uiView.textColor = .label
		}
	}
	
	class Coordinator : NSObject, UITextViewDelegate {
		
		var parent: TextView
		
		init(_ uiTextView: TextView) {
			self.parent = uiTextView
		}
		
		func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
			return true
		}
		
		func textViewDidChange(_ textView: UITextView) {
			var currentLines = CPUSimulatorString(text: textView.text).separateByLFToArray()
			for i in 0 ..< currentLines.count where currentLines[i].count > 28 {
				let acceptableRange = currentLines[i].startIndex ..< currentLines[i].index(currentLines[i].startIndex, offsetBy: 28)
				currentLines[i] = String(currentLines[i][acceptableRange])
			}
			var newText = ""
			for line in currentLines {
				newText += line + "\n"
			}
			if newText.last == "\n" {
				newText = String(newText.dropLast())
			}
			textView.text = newText
			
			self.parent.documentData.restartExecution()
			if textView.text != "Enter assembly code here" && textView.text != "" {
				self.parent.documentData.assemblyCode.text = textView.text
				self.parent.documentData.updateAssemblyCodeErrors()
				if self.parent.documentData.assemblyCodeErrors == [:] {
					self.parent.documentData.machineCode = self.parent.documentData.assemblyCode.assemblyToMachine()
				} else {
					self.parent.documentData.machineCode = ""
				}
			} else if textView.text == "" {
				self.parent.documentData.assemblyCode.text = textView.text
				self.parent.documentData.updateAssemblyCodeErrors()
				self.parent.documentData.machineCode = ""
			}
		}
		
		func textViewDidBeginEditing(_ textView: UITextView) {
			if textView.text == "Enter assembly code here" {
				textView.text = ""
				textView.textColor = .label
			}
		}
		
		func textViewDidEndEditing(_ textView: UITextView) {
			if textView.text == "" {
				textView.text = "Enter assembly code here"
				textView.textColor = .placeholderText
			} else if self.parent.documentData.assemblyCodeIsValid {
				self.parent.documentData.generateSteps()
			}
		}
	}
}


//to preview:
//struct ContentView: View {
//     @State var text = ""
//
//       var body: some View {
//        VStack {
//            Text("text is: \(text)")
//            TextView(
//                text: $text
//            )
//                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//        }
//
//       }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//	}
//}
