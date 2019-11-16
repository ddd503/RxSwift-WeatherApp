//
//  WeatherInfo.swift
//  RxSwift-WeatherApp
//
//  Created by kawaharadai on 2019/11/16.
//  Copyright © 2019 kawaharadai. All rights reserved.
//

import Foundation

struct WeatherInfo: Decodable {
    let main: Weather
}

extension WeatherInfo {
    static let empty = WeatherInfo(main: Weather(temp: 0, humidity: 0))
}

struct Weather: Decodable {
    let temp: Double
    let humidity: Double
}
