//
//  Register.swift
//  CPU Simulator Framework
//
//  Created by Andrew Palombo on 20/12/2019.
//  Copyright © 2019 Andrew Palombo. All rights reserved.
//

import UIKit

public class Cell: Codable, ObservableObject {

	// conformance to String gives raw values as strings for encoding/decoding
	// is not shown in view so is not published
	public enum CellType: String, Codable {
		case bus
		case register
		case statusRegister
		case clock
		case alu
	}

	@Published public var cellType: CellType
	@Published public var name: String
	@Published public var cellContents: String
    @Published public var isRecentlyUsed: Bool
	
	public var cellContentsInHexadecimal: String {
		get {
			if self.cellType == .bus || self.cellType == .register {
				return String(Int(self.cellContents, radix: 2)!, radix: 16)
			} else {
				return self.cellContents
			}
		}
	}
	public var cellContentsInDecimal: String {
		get {
			if self.cellType == .bus || self.cellType == .register {
				print(self.cellContents)
				return String(Int(self.cellContents, radix: 2)!)
			} else {
				return self.cellContents
			}
		}
	}

	public init(cellType: CellType, name: String) {
		self.cellContents = ""
		self.cellType = cellType
		self.name = name
		self.isRecentlyUsed = false
		
		if self.cellType == .bus || self.cellType == .register {
			for _ in 0 ..< 27 {
				cellContents += "0"
			}
		} else if self.cellType == .statusRegister {
			for _ in 0 ..< 5 {
				cellContents += "0"
			}
		} else if self.cellType == .clock {
			cellContents = "[Not Running]"
		} else { //alu
			cellContents = "No Operation"
		}
        
    }
	
	private enum CodingKeys: CodingKey {
		case cellType
		case name
		case cellContents
		case isRecentlyUsed
	}
	
	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		cellType = try container.decode(CellType.self, forKey: .cellType)
		name = try container.decode(String.self, forKey: .name)
		cellContents = try container.decode(String.self, forKey: .cellContents)
		isRecentlyUsed = try container.decode(Bool.self, forKey: .isRecentlyUsed)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		//try container.encode(name, forKey: .name)
		try container.encode(cellType, forKey: .cellType)
		try container.encode(name, forKey: .name)
		try container.encode(cellContents, forKey: .cellContents)
		try container.encode(isRecentlyUsed, forKey: .isRecentlyUsed)
	}
}
