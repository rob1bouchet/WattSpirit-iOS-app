//
//  ConsumptionData.swift
//  WattSpiritiOS
//
//  Created by Robin Bouchet on 17/05/2025.
//

import Foundation

struct ConsumptionData: Codable {
    let consumption: [Consumption]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var consumptions: [Consumption] = []

        while !container.isAtEnd {
            var inner = try container.nestedUnkeyedContainer()
            let time = try inner.decode(TimeInterval.self)
            let value = try inner.decode(Int.self)
            consumptions.append(Consumption(time: time, value: value))
        }

        self.consumption = consumptions
    }
}

struct Consumption: Codable {
    let time: TimeInterval
    let value: Int
}

struct LoginResponse: Codable {
    let token: String
}
