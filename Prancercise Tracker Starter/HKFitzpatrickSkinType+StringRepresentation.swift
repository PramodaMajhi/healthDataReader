//
//  HKFitzpatrickSkinType+StringRepresentation.swift
//  Health Data Reader-Writer
//
//  Created by Patrick Holmes on 7/31/18.


import HealthKit

extension HKFitzpatrickSkinType {
    
    var stringRepresentation: String {
        switch self {
            case .notSet: return "Unknown"
            case .I: return "I"
            case .II: return "II"
            case .III: return "III"
            case .IV: return "IV"
            case .V: return "V"
            case .VI: return "VI"
        }
    }
}

