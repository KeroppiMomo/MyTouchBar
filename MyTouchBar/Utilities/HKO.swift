//
//  HKO.swift
//  MyTouchBar
//
//  Created by Moses Mok on 17/5/2020.
//  Copyright © 2020 Moses Mok. All rights reserved.
//

import Foundation

/// The response data from HKO API of current weather report (`dataType=rhrread`).
///
/// The included fields are not complete due to my lazyness.
/// If I intend to use more data from the API response, check
/// out the following links:
///
/// - [HKO API Documentation (English)](https://www.hko.gov.hk/en/weatherAPI/doc/files/HKO_Open_Data_API_Documentation.pdf)
/// - [HKO API Documentation (Chinese)](https://www.hko.gov.hk/tc/weatherAPI/doc/files/HKO_Open_Data_API_Documentation_tc.pdf)
/// - [Request to HKO Current Weather Report API](https://data.weather.gov.hk/weatherAPI/opendata/weather.php?dataType=rhrread&lang=tc)
struct HKOCurrentResponse: Decodable {
    var icon: [Int]
    var temperature: RecordTimeResponse
    var humidity: RecordTimeResponse
    
    struct RecordTimeResponse: Decodable {
        var data: [DistrictResponse]
        var recordTime: String
        
        struct DistrictResponse: Decodable {
            var unit: String
            var value: Int
            var place: String
        }
    }
}

/// The response data from HKO API of weather warning summary (`dataType=rhrread`).
///
/// The included fields are not complete due to my lazyness.
/// If I intend to use more data from the API response, check
/// out the following links:
///
/// - [HKO API Documentation (English)](https://www.hko.gov.hk/en/weatherAPI/doc/files/HKO_Open_Data_API_Documentation.pdf)
/// - [HKO API Documentation (Chinese)](https://www.hko.gov.hk/tc/weatherAPI/doc/files/HKO_Open_Data_API_Documentation_tc.pdf)
/// - [Request to HKO Current Weather Report API](https://data.weather.gov.hk/weatherAPI/opendata/weather.php?dataType=rhrread&lang=tc)
struct HKOWarningResponse: Decodable {
    var WFIRE: SingleWarningResponse?
    var WFROST: SingleWarningResponse?
    var WHOT: SingleWarningResponse?
    var WCOLD: SingleWarningResponse?
    var WMSGNL: SingleWarningResponse?
    var WRAIN: SingleWarningResponse?
    var WFNTSA: SingleWarningResponse?
    var WL: SingleWarningResponse?
    var WTCSGNL: SingleWarningResponse?
    var WTMW: SingleWarningResponse?
    var WTS: SingleWarningResponse?

    var warnings: [SingleWarningResponse] {
        get {
            return [WFIRE, WFROST, WHOT, WCOLD, WMSGNL, WRAIN, WFNTSA, WL, WTCSGNL, WTMW, WTS].compactMap { $0 }
        }
    }

    struct SingleWarningResponse: Decodable {
        /// Category of warning. 
        ///
        /// Value is one of the following:
        /// - WFIRE
        /// - WFROST
        /// - WHOT
        /// - WCOLD
        /// - WMSGNL
        /// - WRAIN
        /// - WFNTSA
        /// - WL
        /// - WTCSGNL
        /// - WTMW
        /// - WTS
        var name: String?
        /// Code of warning.
        ///
        /// Value is one of the following:
        /// - WFIREY
        /// - WFIRER
        /// - WFROST
        /// - WHOT
        /// - WCOLD
        /// - WMSGNL
        /// - WRAINA
        /// - WRAINR
        /// - WRAINB
        /// - WFNTSA
        /// - WL
        /// - TC1
        /// - TC3
        /// - TC8NE
        /// - TC8SE
        /// - TC8NW
        /// - TC8SW
        /// - TC9
        /// - TC10
        /// - WTMW
        /// - WTS
        var code: String?
        /// Action of the warning.
        ///
        /// Value is one of the following:
        /// - ISSUE
        /// - REISSUE
        /// - CANCEL
        /// - EXTEND
        /// - UPDATE
        var actionCode: String?
    }
}

class HKO {
    static let shared = HKO()
    
    let CURRENT_REQUEST_URL = URL(string: "https://data.weather.gov.hk/weatherAPI/opendata/weather.php?dataType=rhrread&lang=tc")!
    let WARNING_REQUEST_URL = URL(string: "https://data.weather.gov.hk/weatherAPI/opendata/weather.php?dataType=warnsum&lang=tc")!
    // let WARNING_REQUEST_URL = URL(fileURLWithPath: "/Users/Moses/Documents/Xcode Projects/MyTouchBar/test.txt")

    var currentResponse: HKOCurrentResponse?
    var warningResponse: HKOWarningResponse?

    var warningNotificationEnabled = false
    
    private init() { }
    
    func requestCurrent(completion: @escaping (HKOCurrentResponse) -> Void) {
        URLSession.shared.dataTask(with: CURRENT_REQUEST_URL) { (data, res, err) in
            guard err == nil else {
                print("Error while GETing HKO API:")
                print(err!)
                return
            }
            
            guard let data = data else {
                print("No response from HKO API")
                return
            }
            
            let decoder = JSONDecoder()
            guard let response = try? decoder.decode(HKOCurrentResponse.self, from: data) else {
                print("Failed to decode the response from HKO API")
                return
            }
            
            self.currentResponse = response
            completion(response)
        }.resume()
    }
    func requestWarning(completion: @escaping (HKOWarningResponse) -> Void) {
        // warningResponse = HKOWarningResponse()
        // warningResponse!.WRAIN = HKOWarningResponse.SingleWarningResponse()
        // warningResponse!.WRAIN!.code = "WTMW"

        // completion(warningResponse!)

        URLSession.shared.dataTask(with: WARNING_REQUEST_URL) { (data, res, err) in
            guard err == nil else {
                print("Error while GETing HKO API:")
                print(err!)
                return
            }
            
            guard let data = data else {
                print("No response from HKO API")
                return
            }
            
            let decoder = JSONDecoder()
            guard let response = try? decoder.decode(HKOWarningResponse.self, from: data) else {
                print("Failed to decode the response from HKO API")
                return
            }
            
            if self.warningNotificationEnabled {
                self.notifyWarningChanges(self.warningResponse, response)
            }

            self.warningResponse = response
            completion(response)
        }.resume()
    }

    func notifyWarningChanges(_ oriResponse: HKOWarningResponse?, _ curResponse: HKOWarningResponse) {
        if let oriWarns = oriResponse?.warnings.compactMap { $0.code } {
            let oriWarnsSet = Set(oriWarns)
            let curWarnsSet = Set(curResponse.warnings.compactMap { $0.code })
            
            let issuedWarns = curWarnsSet.subtracting(oriWarnsSet)
            let cancelledWarns = oriWarnsSet.subtracting(curWarnsSet)
            
            for warn in issuedWarns {
                let userNotification = NSUserNotification()
                userNotification.title = "⚠️ 【生效】\(curResponse.warnings.filter { $0.code == warn }.first!.name!)"
                userNotification.subtitle = "香港天文台"
                userNotification.setValue(NSImage(named: warn)!, forKey: "_identityImage")
                NSUserNotificationCenter.default.deliver(userNotification)
            }
            for warn in cancelledWarns {
                let userNotification = NSUserNotification()
                userNotification.title = "❎ 【取消】\(oriResponse!.warnings.filter { $0.code == warn }.first!.name!)"
                userNotification.subtitle = "香港天文台"
                userNotification.setValue(NSImage(named: warn)!, forKey: "_identityImage")
                NSUserNotificationCenter.default.deliver(userNotification)
            }
        }
    }
    
    func getIcon(of indicies: [Int]) -> NSImage {
        let index = indicies.max { a, b -> Bool in
            if a / 10 != b / 10 {
                // 5 < 7 < 6
                if a / 10 == 5 { return true }
                if b / 10 == 5 { return false }
                return a > b
            } else {
                return b > a
            }
        }!

        let imageName = [
            50: "sunny",
            51: "partly_sunny",
            52: "partly_cloudy",
            53: "showers",
            54: "showers",
            60: "cloudy",
            61: "cloudy",
            62: "drizzle",
            63: "rain",
            64: "heavy_rain",
            65: "rain_with_thunder",
            70: "night_clear",
            71: "night_clear",
            72: "night_clear",
            73: "night_clear",
            74: "night_clear",
            75: "night_clear",
            76: "night_cloudy",
            77: "night_partly_cloudy",
            80: "windy",
        ][index]!
        
        return NSImage(named: imageName)!
    }

    func getWarningImage(code: String) -> NSImage? {
        return NSImage(named: code)
    }
}
