//
//  DocumentBrowserViewController.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 10/09/2019.
//  Copyright © 2019 Andrew Palombo. All rights reserved.
//

import UIKit
import SwiftUI
import CPU_Simulator_Framework

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
	
	// delegate properties
	private var presentationHandler: ((URL?, Error?) -> Void)?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		delegate = self
		
		allowsDocumentCreation = true
		allowsPickingMultipleItems = false
		view.tintColor = UIColor(red: 195 / 255, green: 42 / 255, blue: 5 / 255, alpha: 1)
		
		additionalLeadingNavigationBarButtonItems.append(UIBarButtonItem(title: "About", style: .plain, target: self, action: #selector(presentAboutView)))
		
		// Specify the allowed content types of your application via the Info.plist.
		
		// Do any additional setup after loading the view.
		self.installPresentationHandler()
		
		//ONBOARDING
		let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
		//as described in documentation the above method returns false when unset
		if !launchedBefore  {
			let onboardingView = OnboardingView(onDismiss: {self.dismiss(animated: true); UserDefaults.standard.set(true, forKey: "launchedBefore")})
			let onboardingViewController = UIHostingController(rootView: onboardingView)
			onboardingViewController.isModalInPresentation = true //can't be dismissed with swipe down
			self.present(onboardingViewController, animated: true)
		}
	}
	
	@objc func presentAboutView() -> Void {
		let aboutView = AboutView(dismiss: {self.dismiss(animated: true)})
		let aboutViewController = UIHostingController(rootView: aboutView)
		self.present(aboutViewController, animated: true)
	}
	
	// MARK: UIDocumentBrowserViewControllerDelegate
	
	// called when 'new document' is pressed
	func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
		// creates a 'template' document and a disposable url for this (application cache)
		let cacheURL = createNewDocumentURL()
		let newDoc = CPUSimulatorDocument(fileURL: cacheURL)
		// uses the UIDocument method to save the file to the given url
		newDoc.save(to: cacheURL, for: .forCreating) { saveSuccess in // closure
			// cancels save request on failure
			guard saveSuccess else {
				importHandler(nil, .none)
				return
			}
			// closes the document, cancels closure on failure
			newDoc.close() { closeSuccess in
				guard closeSuccess else {
					importHandler(nil, .none)
					return
				}
				importHandler(cacheURL, .move)
			}
		}
	}
	
	// called when the user selects an existing file in the browser
	func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
		//guard let sourceURL = documentURLs.first else { return }
		
		// Present the Document View Controller for the first document that was picked.
		// If you support picking multiple items, make sure you handle them all.
		//presentDocument(at: sourceURL)
		print("document selected")
		guard let pickedURL = documentURLs.first else {
			print("escaping")
			return
		}
		presentationHandler?(pickedURL, nil)
		
	}
	
	// informs the delegate that a new document has been imported
	func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
		// Present the Document View Controller for the new newly created document
		presentationHandler?(destinationURL, nil)
	}
	
	// informs the delegate that there has been an error importing a file
	func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
		// Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
		presentationHandler?(documentURL, error)
	}
	
	
	// MARK: Document Presentation
	
	func presentDocument(at documentURL: URL) {
		let document = CPUSimulatorDocument(fileURL: documentURL)
		// Access the document
		document.open() { success in
			if success {
				// Display the content of the document:
				let view = SimulationView(document: document, dismiss: {
					self.closeDocument(document)
					}).environmentObject(document.CPUSimulation)
				
				let documentViewController = UIHostingController(rootView: view)
				documentViewController.modalPresentationStyle = .fullScreen
				self.present(documentViewController, animated: true, completion: nil)
			} else {
				// Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
				//document could not open
			}
		}
	}
	
	private func closeDocument(_ document: CPUSimulatorDocument) {
		dismiss(animated: true) {
			document.close(completionHandler: nil)
		}
	}
	
	private func installPresentationHandler() {
		self.presentationHandler = { [weak self] url, error in

			guard error == nil else {
				//present error to user e.g UIAlertController
				//there was en error importing the file
				return
			}

			if let url = url, let self = self {
				//self.openDocument(url: url)
				self.presentDocument(at: url)
			}
		}
	}
}


extension DocumentBrowserViewController {
	
//	static let newDocNumberKey = "newDocNumber"
	
	private func getDocumentName() -> String {
		//let newDocNumber = UserDefaults.standard.integer(forKey: DocumentBrowserViewController.newDocNumberKey)
		//  return "Untitled \(newDocNumber)"
		
		let now = Date()
		let formatter = DateFormatter()
		// dateFormat could also be "E, d MMM y HH:mm:ss"
		formatter.dateFormat = "E, d MMM y"
		let docTitle = formatter.string(from: now)
		return docTitle
	}
	
	private func createNewDocumentURL() -> URL {
		let docsPath = UIApplication.cacheDirectory() //from starter project
		let newName = getDocumentName()
		let stubURL = docsPath
			.appendingPathComponent(newName)
			.appendingPathExtension(CPUSimulatorDocument.filenameExtension)
		//incrementNameCount()
		return stubURL
	}
	
//	private func incrementNameCount() { // not currently used
//		let newDocNumber = UserDefaults.standard.integer(forKey: DocumentBrowserViewController.newDocNumberKey) + 1
//		UserDefaults.standard.set(newDocNumber, forKey: DocumentBrowserViewController.newDocNumberKey)
//	}
}
