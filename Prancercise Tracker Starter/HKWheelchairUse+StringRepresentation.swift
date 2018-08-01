//
//  HKWheelchairUse+StringRepresentation.swift
//  Health Data Reader-Writer
//
//  Created by Patrick Holmes on 7/31/18.

import HealthKit

extension HKWheelchairUse {
    
    var stringRepresentation: String {
        switch self {
            case .notSet: return "unknown"
            case .yes: return "yes"
            case .no: return "no"
        }
    }
}
