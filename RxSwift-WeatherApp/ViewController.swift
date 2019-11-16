//
//  ViewController.swift
//  RxSwift-WeatherApp
//
//  Created by kawaharadai on 2019/11/13.
//  Copyright © 2019 kawaharadai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Keys

class ViewController: UIViewController {

    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!

    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        cityNameTextField.rx.value
            .orEmpty // nilなら流さないアンラップ
            .subscribe(onNext: { [weak self] text in
                if text.isEmpty {
                    self?.displayWeatherInfo(nil)
                } else {
                    self?.requestWeatherInfo(by: text)
                }
            }).disposed(by: disposeBag)
    }

    /// 気候情報を受け取ってラベルの値を更新する
    /// - Parameter weather: 気候情報
    func displayWeatherInfo(_ weather: Weather?) {
        DispatchQueue.main.async { [weak self] in
            if let weather = weather {
                self?.temperatureLabel.text = "\(weather.temp) °F"
                self?.humidityLabel.text = "\(weather.humidity) "
            } else {
                self?.temperatureLabel.text = "None"
                self?.humidityLabel.text = ""
            }
        }
    }

    /// 都市名をparameterとして天候情報をリクエストする
    /// - Parameter city: 都市名
    func requestWeatherInfo(by city: String) {
        let createRequest = { (cityEncoded: String) -> URL? in
            let requestURLString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityEncoded)&appid=\(RxSwiftWeatherAppKeys().apiKey)"
            return URL(string: requestURLString)
        }

        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let url = createRequest(cityEncoded) else {
                return
        }

        let resource = Resource<WeatherInfo>(url: url)

        URLRequest.load(resource: resource)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                self?.displayWeatherInfo(result?.main)
                },
                       onError: { [weak self] error in
                        self?.displayWeatherInfo(nil)
            }).disposed(by: disposeBag)
    }

}

