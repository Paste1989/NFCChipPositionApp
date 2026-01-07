//
//  NFCChipPositionViewModel.swift
//  NFCChipPositionDemoApp
//
//  Created by Saša Brezovac on 30.10.2025..
//

import Foundation
import Combine
import SwiftUI
import UIKit

enum NFCPosition: String {
    case top = "TOP"
    case noNFC = "NO NFC"
}

@MainActor
final class NFCChipPositionViewModel: ObservableObject {
    @Published var deviceInfo = DeviceInfo()
    @Published var machine: String = ""
    @Published var marketingName: String = ""
    @Published var nfcPosition: NFCPosition = .top
    @Published var animateOffset: CGFloat = 0
    
    func refresh() {
        let machineString = DeviceInfo.machineString()
        machine = machineString
        marketingName = DeviceInfo.marketingName(for: machineString)
        nfcPosition = DeviceInfo.nfcPosition(for: machineString)
        
        switch nfcPosition {
        case .top:
            animateOffset = -120
        case .noNFC:
            animateOffset = 0
        }
    }
}

// MARK: - Device utilities
struct DeviceInfo {
    static func machineString() -> String {
#if targetEnvironment(simulator)
        if let simModel = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"],
           !simModel.isEmpty {
            return simModel
        }
        return "iOS-Simulator"
#else
        var sysinfo = utsname()
        uname(&sysinfo)
        let mirror = Mirror(reflecting: sysinfo.machine)
        var identifier = ""
        for child in mirror.children {
            if let value = child.value as? Int8, value != 0 {
                identifier.append(Character(UnicodeScalar(UInt8(value))))
            }
        }
        return identifier
#endif
    }

    private static func loadModelMap() -> [String: String] {
        guard let url = Bundle.main.url(forResource: "DeviceModels", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String]
        else {
            return [:]
        }
        return dict
    }
    
    static func marketingName(for machineString: String) -> String {
        let map = loadModelMap()
        if let iPhone = map[machineString] {
            return iPhone
        }
        if machineString.contains("iPad") {
            return "iPad"
        }
        return "iPhone"
    }
    
    static func nfcPosition(for machine: String) -> NFCPosition {
        if machine.hasPrefix("iPad") { return NFCPosition.noNFC }
        return NFCPosition.top
    }
    
    
    static func supportsNFCReading(for machine: String) -> Bool {
#if targetEnvironment(simulator)
        return false
#else
        if machine.hasPrefix("iPad") { return false }
        if machine.hasPrefix("iPhone6,") { return false } // 6/6 Plus: Apple Pay only
        if machine.hasPrefix("iPhone7") || machine.hasPrefix("iPhone8") || machine.hasPrefix("iPhone9") || machine.hasPrefix("iPhone10") || machine.hasPrefix("iPhone11") || machine.hasPrefix("iPhone12") || machine.hasPrefix("iPhone13") || machine.hasPrefix("iPhone14") || machine.hasPrefix("iPhone15") || machine.hasPrefix("iPhone16") {
            return true
        }
        return false
#endif
    }
}
