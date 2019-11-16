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

        // 編集完了後のみrequestを流す（完了イベント自体を購読する）
        cityNameTextField.rx.controlEvent(.editingDidEndOnExit)
            .asObservable()
            .map { self.cityNameTextField.text ?? "" }
            .subscribe(onNext: { [weak self] text in
                self?.requestWeatherInfo(by: text)
            })
            .disposed(by: disposeBag)

        // これだと変更の度にrequestが走ってしまう
        //        cityNameTextField.rx.value
        //            .orEmpty // nilなら流さないアンラップ (Control相手なら使える)
        //            .subscribe(onNext: { [weak self] text in
        //               self?.requestWeatherInfo(by: text)
        //            }).disposed(by: disposeBag)
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
        // 検索結果を持ったobservable
        let result = URLRequest.load(resource: resource)
            .catchError({ (error) -> Observable<WeatherInfo> in
                // 発生したエラーをハンドリングしてエラーレスポンスを確認する
                if let rxURLError = error as? RxCocoaURLError {
                    switch rxURLError {
                    case .httpRequestFailed(let response, let data):
                        print(response)
                        print(data as Any)
                    default: break
                    }
                } else {
                    // RxCocoaURLError以外のエラー
                    print(error.localizedDescription)
                }
                return Observable.just(WeatherInfo.empty)
            })
            .asDriver(onErrorJustReturn: WeatherInfo.empty)

        // 個別に値を取り出して、ラベル毎にbindする
        result
            .map { "\($0.main.temp) °F" }
            .drive(self.temperatureLabel.rx.text )
            .disposed(by: disposeBag)

        result
            .map { "\($0.main.humidity)" }
            .drive(self.humidityLabel.rx.text )
            .disposed(by: disposeBag)
    }

}

