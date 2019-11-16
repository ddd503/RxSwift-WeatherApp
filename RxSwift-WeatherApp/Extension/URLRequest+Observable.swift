//
//  URLRequest+Observable.swift
//  RxSwift-WeatherApp
//
//  Created by kawaharadai on 2019/11/16.
//  Copyright © 2019 kawaharadai. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct Resource<T: Decodable> {
    let url: URL
}

extension URLRequest {
    static func load<T>(resource: Resource<T>) -> Observable<T> {
        // 非同期処理を同期的に行い返す（urlRequest作成→リクエスト実行→レスポンスをparse→observableで流す）
        // flatMapは非Observableが流れてきた時
        // mapはObservableが流れてきた時
        // エラー時は通信系のエラー用observableを返す
        return Observable.just(resource.url)
            .flatMap { url -> Observable<(response: HTTPURLResponse, data: Data)> in
                let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5.0)
                return URLSession.shared.rx.response(request: request)
        }
        .map { (response, data) in
            // ここは通信自体が成功したときにしかこない（通信失敗は直接onErrorに入る）
            // 発生したエラーはcatchErrorで拾える
            if 200..<300 ~= response.statusCode {
                return try JSONDecoder().decode(T.self, from: data)
            } else {
                throw RxCocoaURLError.httpRequestFailed(response: response, data: data)
            }
        }
        .asObservable()
    }
}
