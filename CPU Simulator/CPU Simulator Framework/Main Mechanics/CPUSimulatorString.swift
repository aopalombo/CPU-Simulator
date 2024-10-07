//
//  CPUSimulatorString.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 11/12/2019.
//  Copyright © 2019 Andrew Palombo. All rights reserved.
//

import UIKit

//A string with additional methods, stores assembly code
public class CPUSimulatorString: Codable {

	// not published as assembly code is only used in a UIKit View
    public var text: String {
        didSet {
            text = text.uppercased()
        }
    }

	private enum CodingKeys: CodingKey {
		case text
	}
	
    public init(text: String) {
        self.text = text
    }

	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		text = try container.decode(String.self, forKey: .text)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(text, forKey: .text)
	}

	func separateBySpaceToArray(removeAssemblyCommas: Bool) -> [String] {
        var characterArray = [String]()
		var codeBegan = false //true at end of initial tabs
        for char in self.text {
			if !codeBegan && char == "\t" {
				continue
			} else {
				codeBegan = true
				characterArray.append(String(char))
			}
        }

        var array = [""]
        for char in characterArray {
			if char == " " {
				array.append("")
			} else if char == "\t" {
				array.append("")
				array.append("")
			} else {
				array[array.count - 1] += char
			}
        }
        // Removes commas at the end of any words in a line of assembly code
		if removeAssemblyCommas {
			if array.count == 1 || array.count == 2 {
			}
			else if array.count == 3 {
				array[1] = String(array[1].dropLast())
			}
			else if array.count == 4 {
				for i in 1 ... 2 {
					array[i] = String(array[i].dropLast())
				}
			}
		}
        return array
    }

    public func separateByLFToArray() -> [String] {
        var array = [""]
        for char in self.text {
            if char != "\n" {
                array[array.count - 1] += String(char)
            } else {
                array.append("")
            }
        }
        return array
    }
}
