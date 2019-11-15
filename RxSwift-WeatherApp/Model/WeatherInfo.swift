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

struct Weather: Decodable {
    let temp: Double
    let humidity: Double
}
