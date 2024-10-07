//
//  Preferences.swift
//  CPU Simulator Framework
//
//  Created by Andrew Palombo on 21/02/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import UIKit

public class Preferences: Codable {
	
	public static let runSpeeds = ["Stepped", "0.5Hz", "1Hz", "2Hz", "5Hz", "0.1GHz"]
	public static let bases = ["Binary", "Hexadecimal", "Decimal"]
	
	public var runSpeedIndex: Int = 0
	public var runSpeed: String {
		get {
			Preferences.runSpeeds[runSpeedIndex]
		}
		set {
			runSpeedIndex = Preferences.runSpeeds.firstIndex(of: newValue)!
		}
	}
	
	public var baseIndex: Int = 0
	public var base: String {
		get {
			Preferences.bases[baseIndex]
		}
		set {
			baseIndex = Preferences.bases.firstIndex(of: newValue)!
		}
	}

	public init() {
		// initialisation when creating file. does nothing
	}
	
	private enum CodingKeys: CodingKey {
		case runSpeedInteger
		case baseInteger
	}
	
	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		runSpeedIndex = try container.decode(Int.self, forKey: .runSpeedInteger)
		baseIndex = try container.decode(Int.self, forKey: .baseInteger)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(runSpeedIndex, forKey: .runSpeedInteger)
		try container.encode(baseIndex, forKey: .baseInteger)
	}
	
}
