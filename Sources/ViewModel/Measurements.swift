//
//  Measurements.swift
//  Magnetar
//
//  Created by Charlotte Tortorella on 12/7/19.
//  Copyright © 2019 Monadic Consulting. All rights reserved.
//

import Foundation

extension TorrentViewModel {
    enum DataSizeClass: String, CaseIterable {
        case bytes
        case kibibytes
        case mebibytes
        case gibibytes
        case tebibytes
        case pebibytes
        case exbibytes
        case zebibytes
        case yobibytes
        
        var name: String {
            return rawValue
        }
        
        var prefix: Character? {
            switch self {
            case .bytes:
                return nil
            default:
                return rawValue.capitalized.first
            }
        }
        
        var abbreviation: String {
            [prefix.map { "\($0)i" }, "B"]
                .compactMap { $0 }
                .joined()
        }
        
        var standing: UInt {
            switch self {
            case .bytes:
                return 0
            case .kibibytes:
                return 1
            case .mebibytes:
                return 2
            case .gibibytes:
                return 3
            case .tebibytes:
                return 4
            case .pebibytes:
                return 5
            case .exbibytes:
                return 6
            case .zebibytes:
                return 7
            case .yobibytes:
                return 8
            }
        }
    }

    struct Speed: CustomStringConvertible {
        var bytes: UInt {
            size.bytes
        }
        var sizeClass: DataSizeClass {
            size.sizeClass
        }
        private let size: Size
        
        init(bytes: UInt) {
            size = .init(bytes: bytes)
            description = size.description + "/s"
            accessibleDescription = [size.accessibleDescription, "per", "second"]
                .joined(separator: " ")
        }
        
        var rawDescription: String {
            size.rawDescription
        }
        
        let description: String
        let accessibleDescription: String
    }
    
    struct Size: CustomStringConvertible {
        static let numberFormatter: Atomic<NumberFormatter> = {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 1
            return .init(formatter)
        }()
        let bytes: UInt
        let sizeClass: DataSizeClass
        
        init(bytes: UInt) {
            self.bytes = bytes
            let bytes = Double(bytes)
            let logged = UInt(floor(Optional(log2(bytes)).filter { $0.isFinite } ?? 0) / 10)
            sizeClass = DataSizeClass.allCases
                .first { $0.standing == logged }
                ?? .bytes
        }
        
        var rawDescription: String {
            "\(Double(bytes) / pow(2, Double(sizeClass.standing * 10)), formatter: Self.numberFormatter)"
        }
        
        var description: String {
            return [
                rawDescription,
                sizeClass.abbreviation
                ]
                .joined(separator: " ")
        }
        
        var accessibleDescription: String {
            return [
                rawDescription,
                sizeClass.name
                ]
                .joined(separator: " ")
        }
    }
}
