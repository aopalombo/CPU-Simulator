//
//  EditSimulation.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 06/12/2019.
//  Copyright © 2019 Andrew Palombo. All rights reserved.
//

import UIKit
import CPU_Simulator_Framework

enum DocumentError: Error {
    case unrecognisedContent
    case corruptDocument
    case archivingFailure
    
    //localised description gives an appropriate localised error message to the user, depending on error type
    var localizedDescription: String {
        switch self {
        case .unrecognisedContent:
            return NSLocalizedString("File is an unrecognised format", comment: "")
        case .corruptDocument:
            return NSLocalizedString("File could not be read", comment: "")
        case .archivingFailure:
            return NSLocalizedString("File could not be saved", comment: "")
        }
    }
}


// UIDocument is vended by UIDocumentBrowserViewController, multiple instances can be created. It allows more than one simulation to be saved and run in the app. It is an abstract base class that must be subclassed and have functionality added.
class CPUSimulatorDocument: UIDocument {
    
    //static let defaultSimulationName = "untitled"
    static let filenameExtension = "cpusimulation"
    
    var CPUSimulation = ContentDescription() {
        didSet {
            // acts as an auto-save by telling the instance of UIDocument that a change has been 'done'/made
            updateChangeCount(.done)
        }
    }
    
    // Called when document is saved or closed. It's purpose is to get the appropriate data needed to save the file.
    override func contents(forType typeName: String) throws -> Any {
		// Encode your document with an instance of NSData or NSFileWrapper
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		let data = try encoder.encode(CPUSimulation)
		print(String(data: data, encoding: .utf8) ?? "not encoded")
		
        return data
    }
    
    // Called when a document is being opened. It's purpose is provide the encoded data in 'contents'.
    // contents is a Data (binary blob object), not a FileWrapper (bundled data).
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
		// Load your document from contents
		print("decoding")
        // verify that contents is of type data
        guard let data = contents as? Data else {
          throw DocumentError.unrecognisedContent
        }

        // unarchive that data
		let decoder = JSONDecoder()
		var decodedContent: ContentDescription? = ContentDescription()
		do {
			decodedContent = try decoder.decode(ContentDescription.self, from: data) }
			catch  {
				print("throwing corruptDocument")
				print(decodedContent!)
				throw DocumentError.corruptDocument
			}

		// decodedContent can return nil
        guard let content = decodedContent else {
          throw DocumentError.corruptDocument
        }

        // store unarchived data for use throughout the module
		print(content)
        CPUSimulation = content
    }
}
