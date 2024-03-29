//
//  ApiManager.swift
//  LoginExample
//
//  Created by SeungMin on 2022/07/24.
//

import Foundation
import Alamofire
import NaverThirdPartyLogin

class ApiManager {
    func getNaverLoginInfo(
        loginInstance: NaverThirdPartyLoginConnection?,
        completion: @escaping ((Naver) -> ())
    ) {
        guard let isValidAccessToken = loginInstance?.isValidAccessTokenExpireTimeNow(), isValidAccessToken else { return }
        
        guard let tokenType = loginInstance?.tokenType else { return }
        guard let accessToken = loginInstance?.accessToken else { return }
        guard let url = URL(string: "https://openapi.naver.com/v1/nid/me") else { return }
        
        let authorization = "\(tokenType) \(accessToken)"
        
        let request = AF.request(
            url,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: ["Authorization": authorization]
        )
        
        request.responseString {
            if $0.response?.url == nil { return }
            
            guard let status = $0.response?.statusCode, (200...299).contains(status) else { return }
            
            guard let data = $0.data, $0.error == nil else { return }
            
            let decoder = JSONDecoder()
            let naverInfo = try! decoder.decode(Naver.self, from: data)
            completion(naverInfo)
        }
    }
}

func getKakoLoginInfo() {
    
}

func getAppleLoginInfo() {
    
}
