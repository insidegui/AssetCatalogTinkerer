//
//  Preferences.swift
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 22/02/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import Foundation

final class Preferences {
    
    enum Key: String {
        case distinguishCatalogsAndThemeStores
        case ignorePackedAssets
    }
    
    static let shared = Preferences()
    
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
    }
    
    subscript(key: Key) -> Bool {
        get {
            return defaults.bool(forKey: key.rawValue)
        }
        set {
            defaults.set(newValue, forKey: key.rawValue)
        }
    }
    
}
