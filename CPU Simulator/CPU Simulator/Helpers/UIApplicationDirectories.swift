//
//  UIApplicationDirectories.swift
//  CPU Simulator
//
//  Created by Andrew Palombo on 10/01/2020.
//  Copyright © 2020 Andrew Palombo. All rights reserved.
//

import UIKit

extension UIApplication {
    
    static func cacheDirectory() -> URL {
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("unable to get system cache directory - serious problems")
        }
        
        return cacheURL
    }
    
    static func documentsDirectory() -> URL {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
          fatalError("unable to get system docs directory - serious problems")
        }
        
        return documentsURL
    }
    
}
